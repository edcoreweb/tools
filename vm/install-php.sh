#!/usr/bin/env bash

# All available options
# PHP_VERSIONS: "5.6" "7.0" "7.1" "7.2"
# PHP_LIB_FOLDERS: "20131226" "20151012" "20160303" "20170718"

PHP_VERSIONS=( "5.6" "7.1" "7.2" )
PHP_LIB_FOLDERS=( "20131226" "20160303" "20170718" )

# Add php repos
sudo add-apt-repository ppa:ondrej/php -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update

# Install PHP
for version in "${PHP_VERSIONS[@]}"
do
    # Install php versions
    sudo apt-get -y install php${version} php${version}-common \
        php${version}-cgi php${version}-fpm php${version}-pgsql php${version}-cli \
        php${version}-json php${version}-curl php${version}-gd php${version}-intl \
        php${version}-mysql php${version}-readline php${version}-mbstring php${version}-sqlite3 \
        php${version}-zip php${version}-xml php${version}-opcache php${version}-soap

    # Install mcrypt only for 5.6 and 7.1
    if [ $version = "5.6" ] || [ $version = "7.0" ] || [ $version = "7.1" ]
    then
        sudo apt-get -y install php${version}-mcrypt
    fi
done

# Version independent extensions
sudo apt-get -y install memcached
sudo apt-get -y install php-memcached php-mongodb php-memcache php-imagick php-xdebug php-redis

# Bit more ram
sudo sed -i -r 's/^-m[ \t]+64[ \t]*$/-m 96/' /etc/memcached.conf

# Get certs for curl
sudo curl -s -o /etc/php/cacert.pem  https://curl.haxx.se/ca/cacert.pem

# Disable xdebug for all versions
sudo phpdismod -v ALL -s ALL xdebug

# Configure fpm php daemon with two pools w\ xdebug
for version in "${PHP_VERSIONS[@]}"
do
    sudo rm /etc/php/${version}/fpm/pool.d/www.conf
    sed "s/{version}/${version}/g" ./config/php/www.stub | sudo tee /etc/php/${version}/fpm/pool.d/www.conf > /dev/null
    # Create xdebug version of the fpm manager and auto start it
    sudo touch /etc/php/${version}/fpm/php-fpm-xdebug.conf /lib/systemd/system/${version}-fpm-xdebug.service
    sed "s/{version}/${version}/g" ./config/php/php-fpm-xdebug.stub | sudo tee /etc/php/${version}/fpm/php-fpm-xdebug.conf > /dev/null
    sed "s/{version}/${version}/g" ./config/php/php-fpm-xdebug-service.stub | sudo tee /lib/systemd/system/php${version}-fpm-xdebug.service > /dev/null
    sudo systemctl enable php${version}-fpm-xdebug
done

# Install custom config
for version in "${PHP_VERSIONS[@]}"
do
    sudo cp ./config/php/custom.ini /etc/php/${version}/mods-available
done

# Enable custom config
sudo phpenmod -v ALL -s ALL custom

# Ensure php and xdebug log files exists and have the right perms
sudo touch /var/log/php.log
sudo chown www-data:www-data /var/log/php.log
sudo mkdir -p /var/log/xdebug/profiler
sudo chown -R www-data:www-data /var/log/xdebug

# Ensure session dir owned by same user as php
sudo chown -R www-data:www-data /var/lib/php/sessions
sudo chmod -R 0755 /var/lib/php/sessions/

# Restart services
for version in "${PHP_VERSIONS[@]}"
do
    sudo service php${version}-fpm restart
    sudo service php${version}-fpm-xdebug restart
done

# Install Composer
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
