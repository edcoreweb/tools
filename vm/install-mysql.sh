#!/usr/bin/env bash

MYSQL_ROOT_PASSWORD=""

#instance size options for mysql and php (based on the bitnami numbers)

#micro (query_cache_size innodb_buffer_pool_size)
#mysql_configs=( '8M' '16M' )
mysql_configs=( '16M' '32M' ) #try a bit bigger
#small
#mysql_configs=( '128M' '256M' )
#medium
#mysql_configs=( '128M' '256M' )
#large
#mysql_configs=( '256M' '2048M' )
#xlarge
#mysql_configs=( '256M' '2048M' )
#2xlarge
#mysql_configs=( '512M' '4096M' )

#install mysql 5.7
echo "mysql-server-5.7 mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
sudo apt-get install -y mysql-server

#harden default mysql installation
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

#configure mysql
cat << EOF | sudo tee /etc/mysql/mysql.conf.d/ubuntu-my.cnf > /dev/null
[mysqladmin]
user=root
[mysqld]
local-infile=0
max_allowed_packet=512M
sql_mode = ""
bind_address=0.0.0.0
character-set-server=UTF8
collation-server=utf8_general_ci
long_query_time = 1
query_cache_limit=2M
query_cache_type=1
#micro size bitnami numbers
query_cache_size=${mysql_configs[0]}
innodb_buffer_pool_size=${mysql_configs[1]}
#
[client]
default-character-set=UTF8
EOF

sudo systemctl restart mysql
