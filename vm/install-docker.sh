#!/usr/bin/env bash

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update
apt-cache policy docker-ce

sudo apt-get install -y docker-ce

# non-sudo permissions
sudo usermod -aG docker fps

[ ! -d "/home/fps/.docker" ] && \
sudo mkdir "/home/fps/.docker"

sudo chown fps:fps /home/fps/.docker -R
sudo chmod g+rwx /home/fps/.docker -R

# Install docker-compose
COMPOSE_VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
