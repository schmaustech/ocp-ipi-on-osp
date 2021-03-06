#!/bin/bash
: ${OSP_PROJECT:=0}
: ${GUID:=schmaustech}
sudo cp `pwd`/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf
sudo systemctl enable dhcpd --now
sudo cp `pwd`/named/named.conf /etc/named.conf
sudo chmod 640 /etc/named.conf
sudo chown root:named /etc/named.conf
sudo restorecon -RFv /etc/named.conf
sudo cp `pwd`/named/0.20.10.in-addr.arpa /var/named
sudo cp `pwd`/named/schmaustech.com.zone /var/named
sudo systemctl enable named --now
echo "search kni1.schmaustech.com"|sudo tee /etc/resolv.conf
echo "search schmaustech.com"| sudo tee -a /etc/resolv.conf
echo "nameserver 10.20.0.5"|sudo tee -a /etc/resolv.conf

openstack --os-cloud=$OSP_PROJECT subnet unset --dns-nameserver 8.8.8.8 $GUID-appnet-subnet
openstack --os-cloud=$OSP_PROJECT subnet set --dns-nameserver 10.20.0.5 $GUID-appnet-subnet
