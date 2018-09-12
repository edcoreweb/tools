#!/usr/bin/env bash

#useful editor defaults
cat <<EOF > .nanorc
set autoindent
set morespace
set nowrap
set tabsize 4
set tabstospaces
EOF

sudo add-apt-repository universe
#it's like whack-a-mole trying to keep update and upgrade non-interactive.
#This is the best attempt so far.
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

#timezone
sudo timedatectl set-timezone Europe/Bucharest
sudo timedatectl set-ntp true
sudo apt-get install -y ntpdate
sudo ntpdate pool.ntp.org

# Install general tools
sudo apt-get install -y pwgen unzip net-tools curl tar git apt-transport-https ca-certificates software-properties-common wget gnupg vim
