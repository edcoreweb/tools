# Installation

### 1. Get Ubuntu 18.04
[Download the server version](https://www.ubuntu.com/download/server/thank-you?version=18.04.2&architecture=amd64)

### 2. Create a vm and install it

- use `workstation` as the vm name
- use `fps/fps` as user/password

### 3. Set the vm hostname

- add `workstation` at the end of the first 2 lines from the `/etc/hosts` file [like so](https://prnt.sc/m5h9jd)

### 4. Setup the necessary files

- `git clone https://github.com/edcoreweb/tools.git`
- `cd tools`
- `sudo chmod u+x vm/*`

### 5. Run the script

- `cd vm`
- `./ubuntu-18-04-lemp.sh`

You can follow the progress by tailing the provisioning log `tail -f tools/vm/provision.log`

### 6. Install certificates

- download and install `vm/config/ssl/ca.crt`
- download and install `vm/config/ssl/local.ro.crt`

Install the certificates in the windows trusted store.

### 7. Mount the nfs share

- use [this nfs utility](https://www.hanewin.net/nfs-e.htm)
- configure it [as follows](http://prntscr.com/mao144) 
- export your share `\\?\D:\vhosts -name:vhosts -maproot:0` [like this](http://prntscr.com/mao22s)
- add a fstab entry `LOCAL_WIN_IP:/vhosts /var/www/vhosts nfs rw,rsize=32768,wsize=32768,async,timeo=14,nolock,vers=3`

### 8. Extra

- install additional supported PHP version `install-php-version.sh 7.1`
- update existing PHP version `update-php-version.sh 7.1`
