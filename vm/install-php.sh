#!/usr/bin/env bash

# All available options
# PHP_VERSIONS: "5.6" "7.0" "7.1" "7.2" "7.3"
# PHP_LIB_FOLDERS: "20131226" "20151012" "20160303" "20170718" "20180731"

PHP_VERSIONS=( "5.6" "7.1" "7.2" "7.3" )
PHP_LIB_FOLDERS=( "20131226" "20160303" "20170718" "20180731" )

# Add php repos
sudo add-apt-repository ppa:ondrej/php -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update

# Memcached with a bit more ram
sudo apt-get -y install memcached
sudo sed -i -r 's/^-m[ \t]+64[ \t]*$/-m 96/' /etc/memcached.conf

# Get certs for curl
sudo curl -s -o /etc/php/cacert.pem  https://curl.haxx.se/ca/cacert.pem

# Ensure php and xdebug log files exists and have the right perms
sudo touch /var/log/php.log
sudo chown www-data:www-data /var/log/php.log
sudo mkdir -p /var/log/xdebug/profiler
sudo chown -R www-data:www-data /var/log/xdebug

# Ensure session dir owned by same user as php
sudo chown -R www-data:www-data /var/lib/php/sessions
sudo chmod -R 0755 /var/lib/php/sessions/

# Install PHP
for version in "${PHP_VERSIONS[@]}"
do
    # Install php version
    ./install-php-version.sh ${version}
done

# Install Composer
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
