#!/bin/bash

#MariaDB installation
yum install -y mariadb mariadb-server
/usr/bin/mysql_install_db --user=mysql
systemctl enable mariadb
systemctl start mariadb

mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin"
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'mdbpasswd'"

#Server Zabbix Installation
yum install -y http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
yum install -y zabbix-server-mysql zabbix-web-mysql 

zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pmdbpasswd zabbix

#Database configuration 
echo "DBHost=localhost" >> /etc/zabbix/zabbix_server.conf
echo "DBPassword=zabbix" >> /etc/zabbix/zabbix_server.conf

sed -i 's-# php_value date.timezone Europe/Riga-php_value date.timezone Europe/Minsk-' /etc/httpd/conf.d/zabbix.conf

systemctl enable zabbix-server
systemctl start zabbix-server
systemctl start httpd
