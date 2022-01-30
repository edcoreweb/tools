#!/usr/bin/env bash

dir="$(dirname $0)"

# All available options
# PHP_VERSIONS: "5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0"
# PHP_LIB_FOLDERS: "20131226" "20151012" "20160303" "20170718" "20180731" "20190902" "20200930"

PHP_VERSIONS=( "5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" )
PHP_LIB_FOLDERS=( "20131226" "20151012" "20160303" "20170718" "20180731" "20190902" "20200930" )

version=$1
versionNoDots=${version//./}

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

# Add upstream if it doesn't exist
upstreamExists=$(cat /etc/nginx/conf.d/upstream.conf | grep -c "upstream php${version}-fpm")

if [ $upstreamExists -eq 0 ]; then
    sed "s/{version}/${version}/g" $dir/config/nginx/upstream.stub | sudo tee -a /etc/nginx/conf.d/upstream.conf > /dev/null
fi

# Add detect if it doesn't exist
detectExists=$(cat /etc/nginx/custom/detect-php.conf | grep -c "/.php${versionNoDots}")
detectContent="$(sed -e "s/{version}/${version}/g" -e "s/{versionNoDots}/${versionNoDots}/g" $dir/config/nginx/detect.stub)"

if [ $detectExists -eq 0 ]; then
    sudo sed -i '/^set $fastcgi_pass.*/i'"$(echo -e $detectContent)" /etc/nginx/custom/detect-php.conf
fi

# Restart nginx
sudo service nginx restart
