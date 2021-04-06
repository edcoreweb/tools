#!/usr/bin/env bash

dir="$(dirname $0)"

# All available options
# PHP_VERSIONS: "5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0"
# PHP_LIB_FOLDERS: "20131226" "20151012" "20160303" "20170718" "20180731" "20190902" "20200930"

PHP_VERSIONS=( "5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" )
PHP_LIB_FOLDERS=( "20131226" "20151012" "20160303" "20170718" "20180731" "20190902" "20200930" )

version=$1

# Make sure we can install this version
if [[ ! " ${PHP_VERSIONS[@]} " =~ " ${version} " ]]; then
    echo "Version ${version} is not supported."
    exit 1
fi

echo "Installing PHP ${version}..."

# Install PHP version
sudo apt-get -y install php${version} php${version}-common \
php${version}-cgi php${version}-fpm php${version}-pgsql php${version}-cli \
php${version}-curl php${version}-gd php${version}-intl \
php${version}-mysql php${version}-readline php${version}-mbstring php${version}-sqlite3 \
php${version}-zip php${version}-xml php${version}-opcache php${version}-soap php${version}-bcmath \
php${version}-xdebug

# 8.0 and greater include json already
if [[ $version < "8.0" ]]
then
    sudo apt-get -y install php${version}-json 
fi

# Install mcrypt only for 5.6 and 7.1
if [ $version = "5.6" ] || [ $version = "7.0" ] || [ $version = "7.1" ]
then
    sudo apt-get -y install php${version}-mcrypt
fi

# Version independent extensions
sudo apt-get -y install php-memcached php-mongodb php-memcache php-imagick php-redis php-igbinary php-msgpack

# Disable xdebug for all versions
sudo phpdismod -v ${version} -s ALL xdebug

# Configure fpm php daemon with two pools w\ xdebug
sudo rm /etc/php/${version}/fpm/pool.d/www.conf
sed "s/{version}/${version}/g" $dir/config/php/www.stub | sudo tee /etc/php/${version}/fpm/pool.d/www.conf > /dev/null

# Create xdebug version of the fpm manager and auto start it
sudo touch /etc/php/${version}/fpm/php-fpm-xdebug.conf /lib/systemd/system/php${version}-fpm-xdebug.service
sed "s/{version}/${version}/g" $dir/config/php/php-fpm-xdebug.stub | sudo tee /etc/php/${version}/fpm/php-fpm-xdebug.conf > /dev/null
sed "s/{version}/${version}/g" $dir/config/php/php-fpm-xdebug-service.stub | sudo tee /lib/systemd/system/php${version}-fpm-xdebug.service > /dev/null
sudo systemctl enable php${version}-fpm-xdebug

# Install custom config
sudo cp $dir/config/php/custom.ini /etc/php/${version}/mods-available

# Enable custom config
sudo phpenmod -v ${version} -s ALL custom

# Restart services
sudo service php${version}-fpm restart
sudo service php${version}-fpm-xdebug restart
