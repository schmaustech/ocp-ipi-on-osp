#!/bin/bash
#Enable Firewalld
sudo yum -y install firewalld 
sudo systemctl --now enable firewalld
sudo systemctl status firewalld
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --add-service=http  --permanent
sudo firewall-cmd --add-port=5000/tcp  --permanent
sudo firewall-cmd --add-service=dhcp  --permanent
sudo firewall-cmd --reload
sudo systemctl restart dhcpd
