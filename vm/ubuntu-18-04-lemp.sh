#!/bin/bash
#ubuntu 18.04 LTS on lightsail provisioning script
#also works for ubuntu/xenial64 box on vagrant
#everything runs as user www-data (nginx, fpm etc.)
start_seconds="$(date +%s)"

#leave logfile name empty to show on screen instead
LOGFILE=provision.log
#provision-log.log

#logging
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
echo "Ubuntu server setup complete (Mysql 5.7, Nginx, PHP-FPM 7.1, PHP-FPM 5.6, PHP-FPM 7.2)."
echo "You need to log of and on again for some settings to take affect (sudo su ${USER})"

#logging: restore stdout/stderr (and close descriptors 6 and 7)
if [ ! -z "${LOGFILE}" ]; then
exec 1>&6 6>&-
exec 2>&7 7>&-
echo "Provision done. See ${LOGFILE} for details."
echo "You need to log of and on again for some settings to take affect (sudo su ${USER})"
fi

#end
