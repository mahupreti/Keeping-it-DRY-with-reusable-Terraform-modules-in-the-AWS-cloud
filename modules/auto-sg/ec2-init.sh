#!/bin/bash
apt-get update -y
apt-get install httpd -y
echo "This is the test file for standalone database"  > /var/www/html/index.html
chmod 644 /var/www/html/index.html  
service httpd start
service httpd enable