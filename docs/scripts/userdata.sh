#!/bin/bash
sudo yum install amazon-efs-utils git unzip httpd -y
sudo mkdir -p /var/www/html/img
echo "fs-0a72ce2d515a0eb47:/ /var/www/html/img efs _netdev,noresvport,tls,accesspoint=fsap-0453c8a3be354327b 0 0" >> /etc/fstab
sudo mount -a
sudo systemctl start httpd
sudo systemctl enable httpd
sudo git clone https://github.com/shaikabida/wave-cafe-static-website.git
sudo cp -r wave-cafe-static-website/* /var/www/html/
sudo systemctl restart httpd
