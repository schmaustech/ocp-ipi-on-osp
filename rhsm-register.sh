#!/bin/bash
# Register subscriptions
sudo subscription-manager register
sudo subscription-manager attach --pool=8a85f99c6c8b9588016c8be0f1b50ec1
sudo subscription-manager repos --disable=*
sudo subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms --enable=rhel-8-for-x86_64-appstream-rpms --enable=ansible-2-for-rhel-8-x86_64-rpms
sudo subscription-manager repos --enable=openstack-15-tools-for-rhel-8-x86_64-rpms --enable=openstack-15-for-rhel-8-x86_64-rpms
sudo yum -y install ipmitool libvirt jq libguestfs virt* qemu* bind-utils bind dhcp-server python3-openstackclient
sudo yum -y upgrade
