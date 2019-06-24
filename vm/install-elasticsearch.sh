#!/usr/bin/env bash

# Install Java 8
sudo add-apt-repository -y ppa:webupd8team/java
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer

# Install Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update
sudo apt-get -y install elasticsearch
sudo apt-get -y install kibana

# Start Elasticsearch on boot
sudo update-rc.d elasticsearch defaults 95 10

# Start Kibana on boot
sudo update-rc.d kibana defaults 95 10

# Update configuration to use 'local' as the cluster
sudo sed -i "s/#cluster.name: my-application/cluster.name: local/" /etc/elasticsearch/elasticsearch.yml

# Enable Start Elasticsearch
sudo systemctl enable elasticsearch.service
sudo service elasticsearch start

# Enable Start Kibana
sudo systemctl enable kibana.service
sudo service kibana start
