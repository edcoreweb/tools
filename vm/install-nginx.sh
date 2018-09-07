#!/usr/bin/env bash

DOMAIN1="default.local.ro"
#DOMAIN2 would be the www variant - not needed here
DOMAIN2=

HOME="/var/www"
#creates HOME/www as web root with www/public_html as public web location

#nginx main location block select - default does not url re-write to index.php
#default-main-block.conf
#wp-main-block.conf
MAIN_BLOCK=default-main-block.conf

php_versions=( "5.6" "7.1" "7.2" )

#install nginx
sudo add-apt-repository ppa:nginx/development -y
sudo apt-get install nginx -y

#configure nginx (basic)
sudo sed -i -r \
-e 's/^[ \t]*user www-data;/user www-data;/' \
-e 's/^([ \t]*worker_connections ).*/\1 1024;/' \
-e '/multi_accept/ c \\tmulti_accept on;' \
-e '/keepalive_timeout/ c \\tkeepalive_timeout 15;' \
-e '/server_tokens/ c \\tserver_tokens off;' \
-e '/server_tokens/ a \\tclient_max_body_size 64m;' \
-e '/gzip_proxied/ c \\tgzip_proxied any;' \
-e '/gzip_comp_level/ c \\tgzip_comp_level 2;' \
-e 's/#[ \t]*gzip_types/gzip_types/' \
-e '/default_type/ a \\tadd_header X-Frame-Options SAMEORIGIN;' \
-e '/default_type/ a \\tclient_max_body_size 64M;' \
/etc/nginx/nginx.conf

sudo service nginx restart

#remove default site
sudo rm /etc/nginx/sites-enabled/default > /dev/null 2>&1

#add new default after all others as "not available"
sudo sed -i -r \
-e '/include \/etc\/nginx\/sites-enabled\/\*;/ a\
    #default server block\
    server{\
        listen 80 default_server;\
        server_name _;\
        return 444;\
    }' \
/etc/nginx/nginx.conf

#add additional SSL config (will currently get an A in the tests)
sudo sed -i -r \
-e '/ssl_prefer_server_ciphers on;/ a\
        ssl_ciphers  HIGH:!aNULL:!MD5;\
        ssl_session_cache shared:SSL:10m;\
        ssl_session_timeout 10m;\
        #add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";\
    ' \
/etc/nginx/nginx.conf

sudo service nginx restart

#make web root
[ ! -d "${HOME}/vhosts" ] && \
mkdir "${HOME}/vhosts"

#ensure web root is under correct ownership (if running in vagrant with mapped public_html this can get created as root)
sudo chown techcube:techcube "${HOME}/vhosts"
chmod 0755 "${HOME}/vhosts"

#set up log directory and public html root
[ ! -d "${HOME}/vhosts/default" ] && \
mkdir "${HOME}"/vhosts/default

[ ! -d "${HOME}/logs" ] && \
mkdir "${HOME}"/logs

#make directory for Lets Encrypt (used later)
[ ! -d "${HOME}/.well-known/acme-challenge" ] && \
mkdir -p "${HOME}"/.well-known/acme-challenge

#make sure web directory and file permissions are consistent
sudo find "${HOME}"/vhosts/ -type d -not -perm 0755 -exec chmod 0755 '{}' \;
sudo find "${HOME}"/vhosts/ -type f -not -perm 0644 -exec chmod 0644 '{}' \;

#make directory for extra configs to load from nginx server blocks
[ ! -d "/etc/nginx/sites-available/configs" ] && \
sudo mkdir /etc/nginx/sites-available/configs

#make self-signed dummy certs
sudo openssl req -subj "/O=TEST-DEV/C=UK/CN=${DOMAIN1}" -new -newkey rsa:2048 \
-days 365 -nodes -x509 -keyout /etc/nginx/server.key -out /etc/nginx/server.crt > /dev/null
sudo chmod 0600 /etc/nginx/server.key

#create main server config
cat << EOF | sudo tee /etc/nginx/sites-available/${DOMAIN1} > /dev/null
server {
    listen 80;
    listen 443 ssl;

    #temporary certs for testing
    ssl_certificate "/etc/nginx/server.crt";
    ssl_certificate_key "/etc/nginx/server.key";

    server_name ${DOMAIN1} ${DOMAIN2};

    access_log /var/www/logs/access.log;
    error_log /var/www/logs/error.log;

    root /var/www/vhosts/default/;
    index index.php;

    #pull in other locations and configs (eg. wordpress config)
    include sites-available/configs/extra-config.conf;

    #alias acme dir for Lets Encrypt (used later)
    location /.well-known {
        alias "/var/www/.well-known";
        #index for testing only
        index index.html;

        allow all;
    }
	#main block
    include sites-available/configs/main-location-block.conf;

    #main php (linked to php.conf unless caching added)
    include sites-available/configs/php-main.conf;
}
EOF


cat << EOF | sudo tee /etc/nginx/sites-available/localhost > /dev/null
#localhost server for ssh tunneled connections
server {
    listen 80;

    server_name localhost 127.0.0.1;

    access_log /var/www/logs/access.log;
    error_log /var/www/logs/error.log;

    root /var/www/vhosts/default/;
    index index.php;

    #pull in other locations and configs
    include sites-available/configs/local-extra-config.conf;

    location / {
        try_files \$uri \$uri/ =404;
    }

    include sites-available/configs/php7.2.conf;
}

EOF

#generic php config
for version in "${php_versions[@]}"
do
cat << EOF | sudo tee /etc/nginx/sites-available/configs/php${version}.conf > /dev/null
location ~ \.php\$ {
    try_files \$uri =404;
    #fastcgi_split_path_info ^(.+\.php)(/.+)\$;
    fastcgi_pass unix:/run/php/php${version}-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$request_filename;
    include fastcgi_params;
}
EOF
done

#main location blocks
cat << EOF | sudo tee /etc/nginx/sites-available/configs/default-main-block.conf > /dev/null
#standard main nginx location block
location / {
        try_files \$uri \$uri/ =404;
}
EOF

cat << EOF | sudo tee /etc/nginx/sites-available/configs/wp-main-block.conf > /dev/null
#wp location block
location / {
        try_files \$uri \$uri/ /index.php?\$args;
}
EOF

#link standard location block
sudo ln -s /etc/nginx/sites-available/configs/${MAIN_BLOCK} \
/etc/nginx/sites-available/configs/main-location-block.conf > /dev/null 2>&1

#link standard php
sudo ln -s /etc/nginx/sites-available/configs/php7.2.conf \
/etc/nginx/sites-available/configs/php-main.conf > /dev/null 2>&1

#add empty placemarker config file (would get filled in with wp extra config)
cat << EOF | sudo tee /etc/nginx/sites-available/configs/extra-config.conf > /dev/null
EOF

#add empty placemarker config file for localhost
cat << EOF | sudo tee /etc/nginx/sites-available/configs/local-extra-config.conf > /dev/null
EOF

#enable domain configs
sudo ln -s /etc/nginx/sites-available/${DOMAIN1} /etc/nginx/sites-enabled/${DOMAIN1} > /dev/null 2>&1
sudo ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost > /dev/null 2>&1

sudo service nginx restart
