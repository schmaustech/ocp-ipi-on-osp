#!/bin/bash
# Build the bridges on provisioning node

export PROV_CONN="eth0"
nmcli connection add ifname provisioning type bridge con-name provisioning
nmcli con add type bridge-slave ifname "$PROV_CONN" master provisioning
nmcli connection modify provisioning ipv4.addresses 172.22.0.1/24 ipv4.method manual
nmcli con down provisioning
nmcli con up provisioning
export MAIN_CONN="eth1"
nmcli connection add ifname baremetal type bridge con-name baremetal
nmcli con add type bridge-slave ifname "$MAIN_CONN" master baremetal
nmcli con down "Wired connection 1";pkill dhclient;dhclient baremetal
nmcli connection modify baremetal ipv4.addresses 10.20.0.5/24 ipv4.method manual
nmcli connection modify baremetal ipv4.gateway 10.20.0.1
nmcli con down baremetal; nmcli con up baremetal