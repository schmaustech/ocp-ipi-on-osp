#!/bin/bash
### Setup Default Libvirt Storage Pool
sudo systemctl --now enable libvirtd 
sudo systemctl status libvirtd
sudo usermod --append --groups libvirt cloud-user
sudo virsh pool-define-as --name default --type dir --target /var/lib/libvirt/images
sudo virsh pool-start default
sudo virsh pool-autostart default
sudo virsh pool-list
