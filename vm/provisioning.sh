#!/bin/bash

# This should only run once
sudo rm -f /etc/systemd/system/multi-user.target.wants/provisioning.service
sudo rm -f /etc/systemd/system/provisioning.service

start_seconds="$(date +%s)"

./init.sh
./install-mysql.sh
./install-mailhog.sh
./install-php.sh
./install-nginx.sh
./install-elasticsearch.sh
./install-node.sh
./install-redis.sh
./install-docker.sh
./finish.sh

end_seconds="$(date +%s)"
echo "---------------------------------------------------------------------"
echo "Provisioning complete in "$(( end_seconds - start_seconds ))" seconds" && poweroff
