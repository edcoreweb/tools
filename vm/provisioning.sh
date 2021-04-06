#!/bin/bash

# This should only run once
sudo rm -f /etc/systemd/system/multi-user.target.wants/provisioning.service
sudo rm -f /etc/systemd/system/provisioning.service

start_seconds="$(date +%s)"
dir="$(dirname $0)"

$dir/init.sh
$dir/install-mysql.sh
$dir/install-mailhog.sh
$dir/install-php.sh
$dir/install-nginx.sh
$dir/install-elasticsearch.sh
$dir/install-node.sh
$dir/install-redis.sh
$dir/install-docker.sh
$dir/finish.sh

end_seconds="$(date +%s)"
echo "---------------------------------------------------------------------"
echo "Provisioning complete in "$(( end_seconds - start_seconds ))" seconds" && poweroff
