#!/bin/bash
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo "This is the test file for standalone database"  > /var/www/html/index.html
 
