## Mount a shared folder from Windows on Ubuntu

> Edit the `/etc/fstab` file and add the line :  

- `SHARED_WINDOWS_FOLDER PATH_TO_LINUX_FOLDER cifs noperm,credentials=PATH_TO_CREDENTIALS,uid=1000,gid=33,file_mode=0664,dir_mode=02775 0 0`

> Where:  

- `SHARED_WINDOWS_FOLDER` is your windows shared folder : it could be `//MYPC/vhosts`  
- `PATH_TO_LINUX_FOLDER` is the folder where you want to mount : it could be `/var/www/vhosts`  
- `PATH_TO_CREDENTIALS` is the path to your credentials file to access the share (your windows user and password) it cold be `~/credentials`

### The credentials file would have two lines:

- `username=ENTER_WINDOWS_USERNAME`
- `password=ENTER_WINDOWS_PASSWORD`

### Or without the credentials file:

- `SHARED_WINDOWS_FOLDER PATH_TO_LINUX_FOLDER cifs noperm,username=ENTER_WINDOWS_USERNAME,password=ENTER_WINDOWS_PASSWORD,uid=1000,gid=33,file_mode=0664,dir_mode=02775 0 0`

> Where:  

- `ENTER_WINDOWS_USERNAME` is your windows username  
- `ENTER_WINDOWS_PASSWORD` is your windows password  
