#!/usr/bin/env bash

# Mount from NFS
cat <<EOF >> /etc/fstab
_win_host:/vhosts /var/www/vhosts nfs rw,rsize=32768,wsize=32768,async,timeo=5,nolock,vers=3,noatime,bg
EOF
