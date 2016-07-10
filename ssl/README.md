## Create a self-sign certificate

To create a self-signed SSL certificate for your localhost enviroment you must do the follwing:

> Run the following commands :  

```
sudo apt-get update
```

### Activate the SSL Module

```
sudo a2enmod ssl
sudo service apache2 restart
```

### Create a Self-Signed SSL Certificate


```
sudo mkdir /etc/apache2/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
```  


> When you hit "ENTER", you will be asked a number of questions.    


```
Country Name (2 letter code) [AU] : US
State or Province Name (full name) [Some-State] : New York
Locality Name (eg, city) [] : New York City
Organization Name (eg, company) [Internet Widgits Pty Ltd] : Your Company
Organizational Unit Name (eg, section) [] : Department of Kittens
Common Name (e.g. server FQDN or YOUR name) [] : your_domain.com or *.subdomain.com for automated subdomains
Email Address [] : your_email@domain.com
```

### Configure Apache to Use SSL

```
sudo vim /etc/apache2/sites-available/default-ssl.conf
```

> Add the following lines to your vhosts entries or your default vhost:

```
<VirtualHost _default_:443>
    SSLCertificateFile /etc/apache2/ssl/apache.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache.key
</VirtualHost>
```

### Registering the cretificate in the system to be trusted by curl.

```
sudo apt-get install ca-certificates
sudo cp /etc/apache2/ssl/apache.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

### (Optional) Redirecting all traffic to HTTPS.

```
sudo vim /etc/apache2/sites-available/000-default.conf
```

> Add the following lines.

```
<VirtualHost *:80>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</VirtualHost>
```

### Done

> You have installed a self-signed SSL certificate for witch curl work without setting the verify option to false. 
