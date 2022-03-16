#!/usr/bin/env bash

dir="$(dirname $0)"

# Download
MYSQL_8="$(wget -qO- https://dev.mysql.com/downloads/repo/apt/ | grep -oP 'mysql-apt-config[^)]+(?=\))' | head -n 1)"
wget -c "https://dev.mysql.com/get/${MYSQL_8}"

# Set config
MYSQL_ROOT_PASSWORD=""
sudo debconf-set-selections <<EOF
mysql-apt-config mysql-apt-config/select-server select mysql-8.0
mysql-community-server mysql-community-server/root-pass password ${MYSQL_ROOT_PASSWORD}
mysql-community-server mysql-community-server/re-root-pass password ${MYSQL_ROOT_PASSWORD}
EOF

# Install MySQL
export DEBIAN_FRONTEND=noninteractive
sudo -E dpkg -i ${MYSQL_8}
sudo apt update
sudo -E apt install -y mysql-server

# Cleanup
sudo mysql -u root <<EOF
CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
DELETE FROM mysql.user WHERE user = 'root' AND host NOT IN ('%');
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

# Configure with priority
sudo cp $dir/config/mysql/custom.cnf /etc/mysql/mysql.conf.d/mysqld_custom.cnf

sudo service mysql restart
