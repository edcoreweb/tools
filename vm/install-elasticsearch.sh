#!/usr/bin/env bash

# Install Java 8
sudo apt-get -y install openjdk-8-jdk

# Install Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -q update
sudo apt-get -y install elasticsearch

# Update configuration to use 'local' as the cluster
sudo sed -i "s/#cluster.name: my-application/cluster.name: local/" /etc/elasticsearch/elasticsearch.yml

# Start Elasticsearch on boot
sudo update-rc.d elasticsearch defaults 95 10

# Enable Start Elasticsearch
sudo systemctl enable elasticsearch.service
sudo service elasticsearch start

# Install Kibana
sudo apt-get -y install kibana
sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml

# Start Kibana on boot
#sudo update-rc.d kibana defaults 95 10

# Enable Start Kibana
sudo systemctl enable kibana.service
sudo service kibana start
