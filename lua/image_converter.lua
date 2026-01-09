-- Image Converter Module for OpenResty
-- Auto-converts JPG, JPEG, PNG to WEBP format on-the-fly
-- Uses libvips (preferred) or ImageMagick as fallback

local _M = {}

-- Cache directory for converted images
local cache_dir = "/usr/local/openresty/nginx/html/assets/.webp_cache"
local original_dir = "/usr/local/openresty/nginx/html/assets"

-- Supported image extensions
local supported_extensions = {
    jpg = true,
    jpeg = true,
    png = true
}

-- Check if file exists
local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- Get file extension
local function get_extension(filename)
    local ext = filename:match("%.([^%.]+)$")
    if ext then
        return ext:lower()
    end
    return nil
end

-- Check if browser supports WEBP
local function supports_webp()
    local accept = ngx.var.http_accept or ""
    return string.find(accept, "image/webp") ~= nil
end

-- Convert image using libvips (preferred method)
local function convert_with_vips(input_path, output_path)
    -- Remove existing file if any (to avoid permission issues)
    os.execute(string.format("rm -f '%s' 2>/dev/null", output_path))
    
    -- libvips command: vips webpsave input.jpg output.webp [--quality=85]
    local cmd = string.format("vips webpsave '%s' '%s' --quality=85 2>&1", input_path, output_path)
    local handle = io.popen(cmd)
    if handle then
        local result = handle:read("*a")
        local exit_code = handle:close()
        -- Check if conversion was successful
        -- io.popen returns true on success, or nil/false on failure
        if exit_code and file_exists(output_path) then
            return true, nil
        else
            return false, result or "vips conversion failed"
        end
    end
    return false, "Failed to execute vips command"
end

-- Convert image using ImageMagick (fallback method)
local function convert_with_imagemagick(input_path, output_path)
    -- Remove existing file if any (to avoid permission issues)
    os.execute(string.format("rm -f '%s' 2>/dev/null", output_path))
    
    -- ImageMagick command: convert input.jpg -quality 85 output.webp
    -- Use absolute path and ensure output directory is writable
    local cmd = string.format("convert '%s' -quality 85 '%s' 2>&1", input_path, output_path)
    local handle = io.popen(cmd)
    if handle then
        local result = handle:read("*a")
        local exit_code = handle:close()
        if exit_code and file_exists(output_path) then
            return true, nil
        else
            return false, result or "ImageMagick conversion failed"
        end
    end
    return false, "Failed to execute convert command"
end

-- Convert image to WEBP
local function convert_to_webp(input_path, output_path)
    -- Try libvips first (faster and more efficient)
    local success, err = convert_with_vips(input_path, output_path)
    if success then
        ngx.log(ngx.INFO, "[WEBP] Converted using libvips: ", input_path)
        return true
    end
    
    -- Fallback to ImageMagick
    ngx.log(ngx.WARN, "[WEBP] libvips failed, trying ImageMagick: ", err or "unknown error")
    success, err = convert_with_imagemagick(input_path, output_path)
    if success then
        ngx.log(ngx.INFO, "[WEBP] Converted using ImageMagick: ", input_path)
        return true
    end
    
    ngx.log(ngx.ERR, "[WEBP] Conversion failed: ", err or "unknown error")
    return false
end

-- Ensure cache directory exists
local function ensure_cache_dir()
    -- Create directory with proper permissions (777 for write access)
    -- Also ensure parent directory (assets) is writable
    local parent_dir = "/usr/local/openresty/nginx/html/assets"
    local cmd1 = string.format("chmod 777 '%s' 2>/dev/null", parent_dir)
    local cmd2 = string.format("mkdir -p '%s' && chmod -R 777 '%s' 2>/dev/null", cache_dir, cache_dir)
    os.execute(cmd1)
    local result = os.execute(cmd2)
    if result ~= 0 then
        ngx.log(ngx.ERR, "[WEBP] Failed to create cache directory: ", cache_dir)
    else
        ngx.log(ngx.DEBUG, "[WEBP] Cache directory ready: ", cache_dir)
    end
end

-- Main function to handle image conversion
function _M.convert_image(uri)
    -- Check if browser supports WEBP
    if not supports_webp() then
        return nil, "Browser does not support WEBP"
    end
    
    -- Extract filename from URI
    local filename = uri:match("([^/]+)$")
    if not filename then
        ngx.log(ngx.ERR, "[WEBP] Invalid filename from URI: ", uri)
        return nil, "Invalid filename"
    end
    
    -- Check if file extension is supported
    local ext = get_extension(filename)
    if not ext or not supported_extensions[ext] then
        return nil, "File extension not supported for conversion"
    end
    
    -- Build paths
    local original_path = original_dir .. "/" .. filename
    local webp_filename = filename:gsub("%." .. ext .. "$", ".webp")
    local webp_path = cache_dir .. "/" .. webp_filename
    
    -- Check if original file exists
    if not file_exists(original_path) then
        ngx.log(ngx.ERR, "[WEBP] Original file not found: ", original_path)
        return nil, "Original file not found: " .. original_path
    end
    
    -- Log paths for debugging
    ngx.log(ngx.DEBUG, "[WEBP] Original path: ", original_path)
    ngx.log(ngx.DEBUG, "[WEBP] WEBP path: ", webp_path)
    
    -- Ensure cache directory exists first
    ensure_cache_dir()
    
    -- Check if WEBP already exists in cache
    if file_exists(webp_path) then
        ngx.log(ngx.INFO, "[WEBP] Serving cached file: ", webp_path)
        return webp_path, nil
    end
    
    -- Convert to WEBP
    ngx.log(ngx.INFO, "[WEBP] Converting image: ", original_path, " -> ", webp_path)
    local success = convert_to_webp(original_path, webp_path)
    if success then
        -- Verify the file was created
        if file_exists(webp_path) then
            ngx.log(ngx.INFO, "[WEBP] Conversion successful: ", webp_path)
            return webp_path, nil
        else
            ngx.log(ngx.ERR, "[WEBP] Conversion reported success but file not found: ", webp_path)
            return nil, "WEBP file not created after conversion"
        end
    else
        return nil, "Conversion failed"
    end
end

-- Serve converted image
function _M.serve_webp(webp_path)
    local file = io.open(webp_path, "rb")
    if not file then
        ngx.status = ngx.HTTP_NOT_FOUND
        ngx.say("WEBP file not found")
        return
    end
    
    local content = file:read("*all")
    file:close()
    
    ngx.header.content_type = "image/webp"
    ngx.header.content_length = #content
    ngx.header.cache_control = "public, max-age=31536000" -- Cache for 1 year
    ngx.print(content)
    ngx.flush(true)
end

return _M

