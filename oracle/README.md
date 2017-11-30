## Install Oracle 11g Express edition on Ubuntu 16.04

### Download the Oracle 11gR2 express edition installer [here](http://www.oracle.com/technetwork/products/express-edition/downloads/index.html)

(You will need to create a free oracle web account if you don't already have it)

### Unzip it

```
unzip oracle-xe-11.2.0-1.0.x86_64.rpm.zip
cd Disk1
```

### Install the required packages

```
sudo apt-get install alien libaio1 unixodbc vim bc
```

### Convert the RedHat package to Ubuntu package

```
sudo alien --scripts -d oracle-xe-11.2.0-1.0.x86_64.rpm
```

### Make the installer work on Ubuntu

Create the `/sbin/chkconfig`, file and add the work-around.

```
sudo vim /sbin/chkconfig
```

```
#!/bin/bash
# Oracle 11gR2 XE installer chkconfig hack for Ubuntu
file=/etc/init.d/oracle-xe
if [[ ! `tail -n1 $file | grep INIT` ]]; then
echo >> $file
echo '### BEGIN INIT INFO' >> $file
echo '# Provides: OracleXE' >> $file
echo '# Required-Start: $remote_fs $syslog' >> $file
echo '# Required-Stop: $remote_fs $syslog' >> $file
echo '# Default-Start: 2 3 4 5' >> $file
echo '# Default-Stop: 0 1 6' >> $file
echo '# Short-Description: Oracle 11g Express Edition' >> $file
echo '### END INIT INFO' >> $file
fi
update-rc.d oracle-xe defaults 80 01
```

```
sudo chmod 755 /sbin/chkconfig
```

Set additional kernel parameters.

```
sudo vim /etc/sysctl.d/60-oracle.conf
```

```
# Oracle 11g XE kernel parameters  
fs.file-max=6815744  
net.ipv4.ip_local_port_range=9000 65000  
kernel.sem=250 32000 100 128 
kernel.shmmax=536870912
```

**Note**: kernel.shmmax = max possible value , e.g. size of physical RAM (in bytes e.g. 2048MB RAM => 2048 * 1024 * 1024 = 2147483648 bytes)

```
sudo service procps restart
```

```
sudo ln -s /usr/bin/awk /bin/awk 
mkdir /var/lock/subsys 
touch /var/lock/subsys/listener 
```

### Install Oracle 11gR2 XE

```
sudo dpkg --install oracle-xe_11.2.0-2_amd64.deb  
sudo /etc/init.d/oracle-xe configure
```

### All Oracle paths to the end of the bash config file

```
vim ~/.bashrc
```

```
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
export NLS_LANG=`$ORACLE_HOME/bin/nls_lang.sh`
export ORACLE_BASE=/u01/app/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH
```

Reload bash:

```
. ~/.profile
```

### Start the service and connect

```
sudo service oracle-xe start
sqlplus sys as sysdba
```

## References

+ http://meandmyubuntulinux.blogspot.ro/2012/05/installing-oracle-11g-r2-express.html
+ http://meandmyubuntulinux.blogspot.ro/2012/06/trouble-shooting-oracle-11g.html
+ https://askubuntu.com/questions/566734/how-to-install-oracle-11gr2-on-ubuntu-14-04
