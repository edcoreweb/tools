#!/usr/bin/env bash

MYSQL_ROOT_PASSWORD=""

# Install MySQL 5.7
echo "mysql-server-5.7 mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
sudo apt-get install -y mysql-server

# Cleanup
sudo mysql -u root <<EOF
UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root';
DELETE FROM mysql.user WHERE user = '';
DELETE FROM mysql.user WHERE user = 'root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE db = 'test' OR db = 'test\\_%';
FLUSH PRIVILEGES;
EOF

# Configure with priority
sudo cp ./config/mysql/custom.cnf /etc/mysql/mysql.conf.d/mysqld_custom.cnf

sudo service mysql restart
