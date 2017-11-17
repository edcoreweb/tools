## Install a dual php configuration

See https://gist.github.com/edcoreweb/866d57a1251fbf31ca30705b06cf327a

## Performance improvements

### Edit the following files

```
sudo vim /etc/php/7.1/fpm/pool.d/www.conf
sudo vim /etc/php/5.6/fpm/pool.d/www.conf
```

### Comment with ; the following config lines

 + `pm.start_servers`
 + `pm.min_spare_servers`
 + `pm.max_spare_servers`

### Modify the following options

 + `pm = ondemand`
 + `pm.max_children = 50`
 + `pm.max_requests = 500`
 + `php_admin_value[memory_limit] = 1000M`


### Verify settings for errors

```
php-fpm7.1 -t
php-fpm5.6 -t
```

### Restart

```
sudo service php7.1-fpm restart
sudo service php5.6-fpm restart
sudo service apache2 restart
```
