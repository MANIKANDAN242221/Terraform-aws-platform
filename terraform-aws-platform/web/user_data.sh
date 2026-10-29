#!/bin/bash
# Install and start nginx with a simple web page
dnf update -y
dnf install -y nginx

echo "<h1>Hello from $(hostname)</h1>" > /usr/share/nginx/html/index.html

systemctl enable nginx
systemctl start nginx
