#!/bin/bash

#Zabbix installation
yum install -y 'http://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm'
yum install -y zabbix-agent
systemctl start zabbix-agent

sed -i 's%#\ DebugLevel=3%DebugLevel=3%g' /etc/zabbix/zabbix_agentd.conf

sed -i 's%Server=127\.0\.0\.1%Server=192.168.77.21' /etc/zabbix/zabbix_agentd.conf 
sed -i '/^Server=192\.168\.77\.21/a ListenPort=10050' /etc/zabbix/zabbix_agentd.conf
sed -i '/^ListenPort=10050/a ListenIP=0.0.0.0' /etc/zabbix/zabbix_agentd.conf
sed -i '/^ListenIP=0\.0\.0\.0/a StartAgents=3' /etc/zabbix/zabbix_agentd.conf

systemctl enable zabbix-agent
systemctl start zabbix-agent 

#Nginx installation
yum install -y nginx
sed -i '/\[\:\:\]\:80\ default_server/s/^/#/g' /etc/nginx/nginx.conf
sed -i '/^\ *location\ \/\ {/a proxy_pass    http://127.0.0.1:8080/;' /etc/nginx/nginx.conf

#Tomcat installation
yum install -y tomcat
chown -R tomcat:tomcat /var/lib/tomcat

systemctl enable nginx
systemctl start nginx

systemctl enable tomcat
systemctl start tomcat