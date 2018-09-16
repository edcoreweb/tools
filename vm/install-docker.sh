#!/usr/bin/env bash

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update
apt-cache policy docker-ce

sudo apt-get install -y docker-ce

# non-sudo permissions
sudo usermod -aG docker $USER

[ ! -d "/home/$USER/.docker" ] && \
sudo mkdir "/home/$USER/.docker"

sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "/home/$USER/.docker" -R

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
