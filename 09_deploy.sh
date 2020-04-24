#!/bin/bash
# Deploy Cluster
export VERSION="4.3.12"
export OPENSHIFT_RELEASE_IMAGE="registry.svc.ci.openshift.org/ocp/release:$VERSION"
export LOCAL_REG='provision.schmaustech.com:5000'
export export LOCAL_REPO='ocp4/openshift4'
export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=${LOCAL_REG}/${LOCAL_REPO}:${VERSION}

mkdir `pwd`/ocp
cp `pwd`/install-config.yaml `pwd`/ocp
`pwd`/openshift-baremetal-install --dir=ocp create manifests
cp `pwd`/metal3-config.yaml `pwd`/ocp/openshift/99_metal3-config.yaml
`pwd`/openshift-baremetal-install --dir=ocp --log-level debug create cluster
