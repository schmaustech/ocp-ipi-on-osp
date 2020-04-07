#!/bin/bash
sudo cp ./dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
sudo systemctl enable dhcpd --now
sudo cp ./named/named.conf /etc/named.conf
sudo chmod 640 /etc/named.conf
sudo chown root:named /etc/named.conf
sudo restorecon -RFv /etc/named.conf
sudo cp ./named/0.20.10.in-addr.arpa /var/named
sudo cp ./named/schmaustech.com.zone /var/named
sudo systemctl enable named --now
sudo echo "nameserver 10.20.0.5" > /etc/resolv.conf