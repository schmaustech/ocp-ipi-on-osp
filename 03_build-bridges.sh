#!/bin/bash
# Build the bridges on provisioning node

export PROV_CONN="eth0"
sudo nmcli connection add ifname provisioning type bridge con-name provisioning
sudo nmcli con add type bridge-slave ifname "$PROV_CONN" master provisioning
sudo nmcli connection modify provisioning ipv4.addresses 172.22.0.1/24 ipv4.method manual
sudo nmcli con down provisioning
sudo nmcli con up provisioning
export MAIN_CONN="eth1"
sudo nmcli connection add ifname baremetal type bridge con-name baremetal
sudo nmcli con add type bridge-slave ifname "$MAIN_CONN" master baremetal
sudo nmcli con down "Wired connection 1";sudo pkill dhclient;sudo dhclient baremetal
sudo nmcli connection modify baremetal ipv4.addresses 10.20.0.5/24 ipv4.method manual
sudo nmcli connection modify baremetal ipv4.gateway 10.20.0.1
sudo nmcli con down baremetal; sudo nmcli con up baremetal
