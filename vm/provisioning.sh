#!/bin/bash

# This should only run once
sudo systemctl disable provisioning.service
sudo rm -f /etc/systemd/system/provisioning.service

start_seconds="$(date +%s)"
LOGFILE=provision.log

# Logging
# save stdout & stderr to FD 6 & 7 so that they can be restored
# later and re-direct stout and stderr to the log file
if [ ! -z "${LOGFILE}" ]; then
exec 6>&1
exec 7>&2
exec 1> "${LOGFILE}" 2>&1
fi

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
echo "Provisioning complete in "$(( end_seconds - start_seconds ))" seconds"

# Logging: restore stdout/stderr (and close descriptors 6 and 7)
if [ ! -z "${LOGFILE}" ]; then
exec 1>&6 6>&-
exec 2>&7 7>&-
echo "Provision done. See ${LOGFILE} for details."
echo "You need to log of and on again for some settings to take affect (sudo su ${USER})"
fi

poweroff
