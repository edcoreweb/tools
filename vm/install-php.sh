#!/usr/bin/env bash

#php_configs=( pm.max_children pm.start_servers pm.min_spare_servers pm.max_spare_servers )
#micro
php_configs=( 5 1 1 3 )
#small
#php_configs=( 10 2 2 5 )
#medium
#php_configs=( 25 4 4 10 )
#large
#php_configs=( 50 5 5 30 )
#xlarge
#php_configs=( 125 6 6 50 )
#2xlarge
#php_configs=( 250 7 7 100 )

php_versions=( "5.6" "7.1" "7.2" )
php_ini_versions=( "fpm" "cli" )

#install php
sudo add-apt-repository ppa:ondrej/php -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update

# Install PHP
for version in "${php_versions[@]}"
do
    # Install php versions
    sudo apt-get -y install php${version} php${version}-common \
        php${version}-cgi php${version}-fpm php${version}-pgsql php${version}-cli \
        php${version}-json php${version}-curl php${version}-gd php${version}-intl \
        php${version}-mysql php${version}-readline php${version}-mbstring php${version}-sqlite3 \
        php${version}-zip php${version}-xml php${version}-opcache php${version}-soap

    # Install mcrypt only for 5.6 and 7.1
    if [ $version = "5.6" ] || [ $version = "7.1" ]
    then
        sudo apt-get -y install php${version}-mcrypt
    fi
done

# Version independent extensions
sudo apt-get -y install memcached
sudo apt-get -y install php-memcached php-mongodb php-memcache php-imagick php-xdebug php-redis

#bit more ram
sudo sed -i -r 's/^-m[ \t]+64[ \t]*$/-m 96/' /etc/memcached.conf

for version in "${php_versions[@]}"
do
    #restart
    sudo service php${version}-fpm restart
done

for version in "${php_versions[@]}"
do
    #configure fpm php daemon to use the main server user
    #and set some params (micro bitnami size)
    sudo sed -i -r \
    -e '/^user =/ c user = www-data' \
    -e '/^group =/ c group = www-data' \
    -e '/^listen\.owner =/ c listen.owner = www-data' \
    -e '/^listen\.group =/ c listen.group = www-data' \
    -e '/^pm.max_children =/ c pm.max_children = '${php_configs[0]} \
    -e '/^pm.start_servers =/ c pm.start_servers = '${php_configs[1]} \
    -e '/^pm.min_spare_servers =/ c pm.min_spare_servers = '${php_configs[2]} \
    -e '/^pm.max_spare_servers =/ c pm.max_spare_servers = '${php_configs[3]} \
    -e '/^;?pm.max_requests =/ c pm.max_requests = 5000' \
    /etc/php/${version}/fpm/pool.d/www.conf
done

#get certs for curl
sudo curl -s -o /etc/php/cacert.pem  https://curl.haxx.se/ca/cacert.pem

for version in "${php_versions[@]}"
do
    #configure php defaults
    for file in "${php_ini_versions[@]}"
    do 
	    #configure php defaults
    	sudo sed -i -r \
        -e '/^max_execution_time =/ c max_execution_time = 60' \
        -e '/^post_max_size =/ c post_max_size = 64M' \
        -e '/^;cgi.fix_pathinfo=/ c cgi.fix_pathinfo=0' \
        -e '/^upload_max_filesize =/ c upload_max_filesize = 64M' \
        -e '/^;date.timezone =/ c date.timezone = "UTC"' \
        -e '/^session.use_strict_mode =/ c session.use_strict_mode = 1' \
        -e '/^session.gc_probability =/ c session.gc_probability = 100' \
        -e '/^session.gc_maxlifetime =/ c session.gc_maxlifetime = 14400' \
        -e '/^;curl.cainfo =/ c curl.cainfo = /etc/php/cacert.pem' \
        -e '/^;sendmail_path =/ c sendmail_path = /usr/local/bin/mhsendmail' \
        /etc/php/${version}/${file}/php.ini
    done
done

#ensure session dir owned by same user as php
sudo chown -R www-data:www-data /var/lib/php/sessions
sudo chmod -R 0755 /var/lib/php/sessions/

for version in "${php_versions[@]}"
do
    #restart
    sudo service php${version}-fpm restart
done

# install Composer
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
