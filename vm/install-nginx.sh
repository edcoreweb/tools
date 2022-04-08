#!/usr/bin/env bash

dir="$(dirname $0)"

WEB_ROOT="/var/www"
PHP_VERSIONS=( "5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" )

# Install nginx
sudo add-apt-repository ppa:nginx/stable -y
sudo apt-get install nginx -y

# Copy default ssl certificates
[ ! -d "/etc/ssl/custom" ] && \
sudo mkdir /etc/ssl/custom
sudo cp $dir/config/ssl/* /etc/ssl/custom

sudo cp $dir/config/ssl/ca.crt /usr/local/share/ca-certificates
sudo update-ca-certificates

# Copy default configuration files
[ ! -d "/etc/nginx/custom" ] && \
sudo mkdir /etc/nginx/custom

sudo cp $dir/config/nginx/index.conf /etc/nginx/conf.d
sudo cp $dir/config/nginx/gzip.conf /etc/nginx/conf.d
sudo cp $dir/config/nginx/uploads.conf /etc/nginx/conf.d
sudo cp $dir/config/nginx/xdebug.conf /etc/nginx/conf.d

sudo cp $dir/config/nginx/custom/detect-php.conf /etc/nginx/custom/detect-php.conf
sudo cp $dir/config/nginx/custom/ssl.conf /etc/nginx/custom/ssl.conf
sudo cp $dir/config/nginx/custom/static.conf /etc/nginx/custom/static.conf
sudo cp $dir/config/nginx/custom/php.conf /etc/nginx/custom/php.conf
sudo cp $dir/config/nginx/custom/security.conf /etc/nginx/custom/security.conf
sudo cp $dir/config/nginx/custom/cors.conf /etc/nginx/custom/cors.conf
sudo cp $dir/config/nginx/custom/magento2.conf /etc/nginx/custom/magento2.conf

# Create the upstreams
sudo touch /etc/nginx/conf.d/upstream.conf
for version in "${PHP_VERSIONS[@]}"
do
    sed "s/{version}/${version}/g" $dir/config/nginx/upstream.stub | sudo tee -a /etc/nginx/conf.d/upstream.conf > /dev/null
done

# Remove default site
sudo rm -f /etc/nginx/sites-available/default
sudo rm -f /etc/nginx/sites-enabled/default

# Copy the new ones
sudo cp $dir/config/nginx/sites/default.conf /etc/nginx/sites-available/default
sudo cp $dir/config/nginx/sites/search.conf /etc/nginx/sites-available/search
sudo cp $dir/config/nginx/sites/mail.conf /etc/nginx/sites-available/mail

# Enable default config
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/search /etc/nginx/sites-enabled/search
sudo ln -s /etc/nginx/sites-available/mail /etc/nginx/sites-enabled/mail

# Make web root
[ ! -d "${WEB_ROOT}/vhosts" ] && \
sudo mkdir "${WEB_ROOT}/vhosts"

# Ensure web root is under correct ownership
sudo chown fps:fps "${WEB_ROOT}/vhosts"
sudo chmod 0755 "${WEB_ROOT}/vhosts"

# Restart
sudo service nginx restart
