#!/bin/bash
sudo podman stop httpd poc-registry
sudo podman rm httpd poc-registry
sudo podman pod rm ironic-pod
sudo rm -r -f /opt/registry/*
sudo rm -r -f /opt/ocp/*
cp $(pwd)/install-config.yaml.orig $(pwd)/install-config.yaml
