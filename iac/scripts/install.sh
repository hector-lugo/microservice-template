#! /bin/bash

sudo yum update
sudo yum install -y docker

sudo gpasswd -a ec2-user docker
exec sg docker

docker run --name server -p 80:80 httpd

