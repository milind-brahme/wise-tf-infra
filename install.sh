#!/bin/bash
set -x
echo 'Starting to execute install.sh'
sleep 5
export TNS_ADMIN=/home/ec2-user/efs/milind/sqlclientBinaries
sudo yum install /home/ec2-user/efs/milind/sqlclientBinaries/oracle-instantclient-basic-21.4.0.0.0-1.el8.x86_64.rpm -y
sudo yum install /home/ec2-user/efs/milind/sqlclientBinaries/oracle-instantclient-sqlplus-21.4.0.0.0-1.el8.x86_64.rpm -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo yum install nginx-mod-stream.x86_64 -y
sudo sh -c "echo 'stream {

    server {
        listen     9090;
        #TCP traffic will be forwarded to the specified server
        proxy_pass 127.0.0.1:12346;
    }
}' >> /etc/nginx/nginx.conf "
sudo service nginx restart
