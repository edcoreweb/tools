# Installation

### 1. Get Ubuntu 18.04
[Download the server version](https://www.ubuntu.com/download/server/thank-you?version=18.04.1.0&architecture=amd64)

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

You can follow the progress by tailing the provisioning log `tail -f tools/vm/provisioning.log`
