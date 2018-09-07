#!/usr/bin/env bash

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update
apt-cache policy docker-ce

sudo apt-get install -y docker-ce
