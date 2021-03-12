#!/usr/bin/env bash

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

echo "Updating PHP ${version}..."

# Stop services
sudo service php${version}-fpm stop
sudo service php${version}-fpm-xdebug stop

# Install PHP version
sudo apt-get -y install php${version} php${version}-common \
php${version}-cgi php${version}-fpm php${version}-pgsql php${version}-cli \
php${version}-curl php${version}-gd php${version}-intl \
php${version}-mysql php${version}-readline php${version}-mbstring php${version}-sqlite3 \
php${version}-zip php${version}-xml php${version}-opcache php${version}-soap php${version}-bcmath

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
sudo apt-get -y install php-memcached php-mongodb php-memcache php-imagick php-xdebug php-redis

# Restart services
sudo service php${version}-fpm start
sudo service php${version}-fpm-xdebug start
