#!/bin/bash

start_seconds="$(date +%s)"

LOGFILE=provision.log

# logging
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
echo "Ubuntu server setup complete (Mysql 8, Nginx, PHP)."

#logging: restore stdout/stderr (and close descriptors 6 and 7)
if [ ! -z "${LOGFILE}" ]; then
exec 1>&6 6>&-
exec 2>&7 7>&-
echo "Provision done. See ${LOGFILE} for details. Restarting in 10 seconds..."
fi

(sleep 10 && shutdown now) &
