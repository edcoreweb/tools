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

# Limit memory usage
sudo sed -i "s/## -Xms4g/-Xms512m/" /etc/elasticsearch/jvm.options
sudo sed -i "s/## -Xmx4g/-Xmx512m/" /etc/elasticsearch/jvm.options

# Enable Start Elasticsearch
#sudo systemctl enable elasticsearch.service
#sudo service elasticsearch start

# Install Kibana
sudo apt-get -y install kibana
sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml

# Enable Start Kibana
#sudo systemctl enable kibana.service
#sudo service kibana start
