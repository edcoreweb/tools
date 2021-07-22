## Create a self-sign certificate

To create a self-signed SSL certificate for your localhost enviroment you must do the follwing:


```
sudo apt-get update
sudo apt-get install ca-certificates
```

### Activate the SSL Module

```
sudo a2enmod ssl
sudo service apache2 restart
```

### Set the alterantive names

```
sudo vim /etc/ssl/openssl.cnf
```  

Modify the following lines under **[v3_ca]**
```
# Include email address in subject alt name: another PKIX recommendation
subjectAltName=DNS:*.local.test
```  

### Generate the root authority (this is required to sign the other certificates and will be added to the trusted root)

```
openssl genrsa -aes256 -out ca.key 2048
openssl req -new -x509 -days 7300 -key ca.key -sha256 -extensions v3_ca -out ca.crt
```

When you hit "ENTER", you will be asked a number of questions.    


```
Country Name (2 letter code) [AU] : US
State or Province Name (full name) [Some-State] : New York
Locality Name (eg, city) [] : New York City
Organization Name (eg, company) [Internet Widgits Pty Ltd] : Your Company
Organizational Unit Name (eg, section) [] : Department of Kittens
Common Name (e.g. server FQDN or YOUR name) [] : *
Email Address [] : your_email@domain.com
```  

### Add the root authority to the trusted certificates

```
sudo cp ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```  

### Create a Self-Signed SSL Certificate

#### Generate the domain key:

```
openssl genrsa -out local.dev.key 2048
```

#### Generate the certificate signing request

```
openssl req -sha256 -new -key local.dev.key -out local.dev.csr
```

When you hit "ENTER", you will be asked a number of questions.    

```
Country Name (2 letter code) [AU] : US
State or Province Name (full name) [Some-State] : New York
Locality Name (eg, city) [] : New York City
Organization Name (eg, company) [Internet Widgits Pty Ltd] : Your Company
Organizational Unit Name (eg, section) [] : Department of Kittens
Common Name (e.g. server FQDN or YOUR name) [] : *.local.dev
Email Address [] : your_email@domain.com
```

#### Sign the request with your root key

```
openssl x509 -sha256 -req -in local.dev.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out local.dev.crt -days 7300 -extfile /etc/ssl/openssl.cnf -extensions v3_ca
```

#### Verify the certificate:

```
openssl verify -CAfile ca.crt local.dev.crt
```


### Configure Apache to Use SSL

```
cp local.dev.crt /etc/apache2/ssl/local.dev.crt
cp local.dev.key /etc/apache2/ssl/local.dev.key
sudo vim /etc/apache2/sites-available/default-ssl.conf
```

Add the following lines to your vhosts entries or your default vhost:

```
<VirtualHost _default_:443>
    SSLCertificateFile /etc/apache2/ssl/local.dev.crt
    SSLCertificateKeyFile /etc/apache2/ssl/local.dev.key
</VirtualHost>
```

### (Optional) Redirecting all traffic to HTTPS.

```
sudo vim /etc/apache2/sites-available/000-default.conf
```

Add the following lines.

```
<VirtualHost *:80>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</VirtualHost>
```

### Done

You have installed a self-signed SSL certificate for witch curl will work without setting the verify option to false. 
