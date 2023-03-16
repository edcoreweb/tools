#!/usr/bin/env bash

# Mount from NFS
cat << EOF | sudo tee -a /etc/fstab
_win_host:/vhosts /var/www/vhosts nfs rw,rsize=32768,wsize=32768,async,timeo=5,nolock,vers=3,noatime,bg
EOF

# Uninstall cloud init
sudo apt purge cloud-init -y
sudo apt autoremove -y
sudo rm -rf /etc/cloud && sudo rm -rf /var/lib/cloud/
