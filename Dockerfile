# Base image with Nginx and Lua support
FROM --platform=linux/amd64 openresty/openresty:latest

# Install necessary tools (e.g Lua modules)
RUN apt-get update && apt-get install -y curl \
    ca-certificates curl unzip luarocks \
    && luarocks install lua-cjson \
    && luarocks install lua-resty-http \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/local/openresty/nginx

# Copy the nginx configuration
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Copy the HTML form (index.html)
COPY html /usr/local/openresty/nginx/html

# Expose port 3019 for HTTP Traffic
EXPOSE 80

# Start nginx when the container starts
CMD [ "/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;" ]