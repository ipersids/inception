#!/bin/sh
set -e

# Create nginx user if needed
if ! id -u nginx >/dev/null 2>&1; then
    addgroup -g 101 -S nginx
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx
fi

# Create directories and set permissions
mkdir -p /var/log/nginx /var/cache/nginx /var/run/nginx
chown -R nginx:nginx /var/log/nginx /var/cache/nginx /var/run/nginx

# Test and start NGINX
nginx -t
exec nginx -g "daemon off;"
