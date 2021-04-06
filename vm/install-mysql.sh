#!/usr/bin/env bash

dir="$(dirname $0)"

MYSQL_ROOT_PASSWORD=""

# Install MySQL 5.7
echo "mysql-server-5.7 mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | sudo debconf-set-selections
sudo apt-get install -y mysql-server

# Cleanup
sudo mysql -u root <<EOF
CREATE USER 'root'@'%' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root';
DELETE FROM mysql.user WHERE user = 'root' AND host NOT IN ('%');
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

# Configure with priority
sudo cp $dir/config/mysql/custom.cnf /etc/mysql/mysql.conf.d/mysqld_custom.cnf

sudo service mysql restart
