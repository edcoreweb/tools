#!/usr/bin/env bash

#useful editor defaults
cat <<EOF > .nanorc
set autoindent
set morespace
set nowrap
set tabsize 4
set tabstospaces
EOF

sudo add-apt-repository universe -y
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
sudo apt-get install -y pwgen unzip net-tools curl tar git apt-transport-https ca-certificates software-properties-common wget gnupg vim nfs-common ifupdown make 

# Set the windows host
IP=$(ip route get 8.8.8.8 | head -1 | awk '{print $7}')
IP_PIECES=(${IP//./ })
NEW_IP="${IP_PIECES[0]}.${IP_PIECES[1]}.${IP_PIECES[2]}.1"
echo "${NEW_IP} _win_host" | sudo tee -a /etc/hosts > /dev/null
