# Base image with Nginx and Lua support
FROM --platform=linux/amd64 openresty/openresty:alpine

# Install necessary tools (e.g Lua modules)
RUN apk add --no-cache curl ca-certificates unzip luarocks && \
    luarocks install lua-cjson && \
    luarocks install lua-resty-http && \
    rm -rf /var/cache/apk/*

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