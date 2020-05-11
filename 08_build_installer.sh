#!/bin/bash
VERSION="4.5.0-0.nightly-2020-05-11-092820"
SUBVER=`echo "${VERSION:0:3}"`
echo "Building $SUBVER openshift-baremetal-install with OpenStack hardware profile..."
cd $HOME
sudo yum -y install libvirt-devel go
wget -c https://dl.google.com/go/go1.13.10.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.13.10.linux-amd64.tar.gz
export PATH=/usr/local/go/bin:$PATH
export PATH=$PATH:$HOME/scripts
export GOPATH=/home/cloud-user/go
mkdir -p $HOME/go/src/github.com/openshift
cd $HOME/go/src/github.com/openshift
git clone --single-branch --branch release-$SUBVER https://github.com/openshift/installer.git
cd installer/
cp $HOME/profile.go vendor/github.com/metal3-io/baremetal-operator/pkg/hardware/profile.go
#vi vendor/github.com/metal3-io/baremetal-operator/pkg/hardware/profile.go 
TAGS="baremetal libvirt" hack/build.sh
cp bin/openshift-install $HOME/scripts/openshift-baremetal-install
echo "Completed $SUBVER openshift-baremetal-install with OpenStack hardware profile!"
