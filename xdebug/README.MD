# Activate remote debugging with Xdebug and PHPStorm

### Prerequisites
- `Windows host`
- `Ubuntu\Linux remote virtual server (VMWare)`
- `PHPStorm`

### Install Xdebug on the server

- `sudo apt-get install php5-xdebug`

### Activate Xdebug

> Find your php configuration file or your Xdebug configuration file.  
> Default location is in **`/etc/php5/apache2/php.ini`**      
> To find the config files :

- `find / -name 'php.ini' 2> /dev/null`
- `find / -name 'xdebug.ini' 2> /dev/null`

> Sometimes there are **.ini** files in **`/etc/php5/apache2/conf.d/`**  
> These are more important and you would want to modify these.  
> In my case they look like `20-xdebug.ini` and `20-php.ini`  
> **If you have these files follow Case II.**

#### Case I - standard activation

> Add the following lines to the end of the **php.ini** file

- `[XDebug]`  
- `zend_extension=XDEBUG_LIBRARY_PATH`  
- `xdebug.default_enable = 1`  
- `xdebug.idekey = "PHPSTORM"`  
- `xdebug.remote_enable = 1`  
- `xdebug.remote_autostart = 1`  
- `xdebug.remote_port = 9000`  
- `xdebug.remote_handler=dbgp`  
- `xdebug.remote_log="/var/log/xdebug/xdebug.log"`  
- `xdebug.remote_host=WINDOWS_LOCAL_IP`

> Replace **XDEBUG_LIBRARY_PATH** with path found by `find / -name 'xdebug.so' 2> /dev/null`  
> Replace **WINDOWS_LOCAL_IP** with your windows local ip (**cmd** `ipconfig`).

#### Case II - Separate Xdebug config file

> **Only follow this path if you have a diffrent `xdebug.ini` file**  
> Open your `xdebug.ini` file and add :

- `zend_extension=XDEBUG_LIBRARY_PATH`  
- `xdebug.default_enable = 1`  
- `xdebug.idekey = "PHPSTORM"`  
- `xdebug.remote_enable = 1`  
- `xdebug.remote_autostart = 1`  
- `xdebug.remote_port = 9000`  
- `xdebug.remote_handler=dbgp`  
- `xdebug.remote_log="/var/log/xdebug/xdebug.log"`  
- `xdebug.remote_host=WINDOWS_LOCAL_IP`

> Replace **XDEBUG_LIBRARY_PATH** with path found by `find / -name 'xdebug.so' 2> /dev/null`  
> Replace **WINDOWS_LOCAL_IP** with your windows local ip (**cmd** `ipconfig`).

### Get debugging

- Open up your PHPStorm project
- Activate **Start Listening for PHP Debug Connections** from the **Run** menu
- Set a breakpoint
- Navigate to the respective page
- The debugger should pop in

## Note

> **If your local ip changes, you'll have to set it again in the config file.**


