#!/usr/bin/env bash

WEB_ROOT="/var/www"
PHP_VERSIONS=( "5.6" "7.1" "7.2" )

# Install nginx
sudo add-apt-repository ppa:nginx/development -y
sudo apt-get install nginx -y

# Copy default configuration files
[ ! -d "/etc/nginx/custom" ] && \
sudo mkdir /etc/nginx/custom

sudo cp ./config/nginx/index.conf /etc/nginx/conf.d
sudo cp ./config/nginx/xdebug.conf /etc/nginx/conf.d
sudo cp ./config/nginx/default-ssl.conf /etc/nginx/custom
sudo cp ./config/nginx/default-static.conf /etc/nginx/custom
sudo cp ./config/nginx/default-php.conf /etc/nginx/custom
sudo cp ./config/nginx/detect-php.conf /etc/nginx/custom
sudo cp ./config/nginx/default-security.conf /etc/nginx/custom

# Create the upstreams
for version in "${PHP_VERSIONS[@]}"
do
    sudo sed "s/{version}/${version}/g" ./config/nginx/upstream.stub >> /etc/nginx/conf.d/upstream.conf
    sudo sed -i -e '$a\' /etc/nginx/conf.d/upstream.conf
done

# Remove default site and create new one
sudo rm /etc/nginx/sites-enabled/default
sudo cp ./config/nginx/default.conf /etc/nginx/sites-available/default

# Make web root
[ ! -d "${WEB_ROOT}/vhosts" ] && \
sudo mkdir "${WEB_ROOT}/vhosts"

# Ensure web root is under correct ownership
sudo chown "{$USER}":"{$USER}" "${WEB_ROOT}/vhosts"
sudo chmod 0755 "${WEB_ROOT}/vhosts"

# Enable default config
[ ! -f "/etc/nginx/sites-enabled/default" ] && \
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Restart
sudo service nginx restart
