# Base image with Nginx and Lua support
FROM --platform=linux/amd64 openresty/openresty:latest

# Install necessary tools (e.g Lua modules)
# Install image processing libraries: libvips (preferred) and ImageMagick (fallback)
RUN apt-get update && apt-get install -y curl \
    ca-certificates curl unzip luarocks \
    libvips-tools imagemagick \
    && luarocks install lua-cjson \
    && luarocks install lua-resty-http \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/local/openresty/nginx

# Copy the nginx configuration
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Copy Lua image converter module
COPY lua/image_converter.lua /usr/local/openresty/nginx/lua/image_converter.lua

# Copy the HTML form (index.html)
COPY html /usr/local/openresty/nginx/html

# Create cache directory for converted WEBP images (after COPY to ensure assets exists)
# Set proper permissions: 755 for directories (owner: rwx, group/others: rx)
# OpenResty typically runs as root in container, so owner write is sufficient
RUN mkdir -p /usr/local/openresty/nginx/html/assets/.webp_cache && \
    chmod 755 /usr/local/openresty/nginx/html/assets && \
    chmod 755 /usr/local/openresty/nginx/html/assets/.webp_cache && \
    chown -R root:root /usr/local/openresty/nginx/html/assets

# Expose port 80 for HTTP Traffic
EXPOSE 80

# Start nginx when the container starts
CMD [ "/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;" ]