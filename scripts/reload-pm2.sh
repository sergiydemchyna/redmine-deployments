#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt-get -o Acquire::ForceIPv4=true update -y
sudo apt-get -o Acquire::ForceIPv4=true upgrade -y
echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/99force-ipv4

sudo apt install nginx -y

sudo tee /etc/nginx/sites-available/default<<EOF
upstream web_backend {
        server 1.1.1.1:3000;
        server 1.1.1.1:3000;
}
server {
listen 80;
location / {
proxy_pass http://web_backend;
}
}
EOF


sudo service nginx restart
