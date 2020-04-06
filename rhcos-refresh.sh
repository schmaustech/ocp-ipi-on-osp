#!/bin/bash
#########################################################################################
# Pull updated rhcos image if needed							#
#########################################################################################
echo "rhcos-refresh : Begin RHCOS refresh..."
OPENSHIFT_INSTALLER=/`pwd`/openshift-baremetal-install
IRONIC_DATA_DIR=/opt/ocp/ironic
OPENSHIFT_INSTALL_COMMIT=$($OPENSHIFT_INSTALLER version | grep commit | cut -d' ' -f4)
OPENSHIFT_INSTALLER_MACHINE_OS=${OPENSHIFT_INSTALLER_MACHINE_OS:-https://raw.githubusercontent.com/openshift/installer/$OPENSHIFT_INSTALL_COMMIT/data/data/rhcos.json}
MACHINE_OS_IMAGE_JSON=$(curl "${OPENSHIFT_INSTALLER_MACHINE_OS}")
MACHINE_OS_INSTALLER_IMAGE_URL=$(echo "${MACHINE_OS_IMAGE_JSON}" | jq -r '.baseURI + .images.openstack.path')
MACHINE_OS_INSTALLER_IMAGE_SHA256=$(echo "${MACHINE_OS_IMAGE_JSON}" | jq -r '.images.openstack.sha256')
MACHINE_OS_IMAGE_URL=${MACHINE_OS_IMAGE_URL:-${MACHINE_OS_INSTALLER_IMAGE_URL}}
MACHINE_OS_IMAGE_NAME=$(basename ${MACHINE_OS_IMAGE_URL})
MACHINE_OS_IMAGE_SHA256=${MACHINE_OS_IMAGE_SHA256:-${MACHINE_OS_INSTALLER_IMAGE_SHA256}}
MACHINE_OS_INSTALLER_BOOTSTRAP_IMAGE_URL=$(echo "${MACHINE_OS_IMAGE_JSON}" | jq -r '.baseURI + .images.qemu.path')
MACHINE_OS_INSTALLER_BOOTSTRAP_IMAGE_SHA256=$(echo "${MACHINE_OS_IMAGE_JSON}" | jq -r '.images.qemu.sha256')
MACHINE_OS_BOOTSTRAP_IMAGE_URL=${MACHINE_OS_BOOTSTRAP_IMAGE_URL:-${MACHINE_OS_INSTALLER_BOOTSTRAP_IMAGE_URL}}
MACHINE_OS_BOOTSTRAP_IMAGE_NAME=$(basename ${MACHINE_OS_BOOTSTRAP_IMAGE_URL})
MACHINE_OS_BOOTSTRAP_IMAGE_SHA256=${MACHINE_OS_BOOTSTRAP_IMAGE_SHA256:-${MACHINE_OS_INSTALLER_BOOTSTRAP_IMAGE_SHA256}}
MACHINE_OS_INSTALLER_BOOTSTRAP_IMAGE_UNCOMPRESSED_SHA256=$(echo "${MACHINE_OS_IMAGE_JSON}" | jq -r '.images.qemu["uncompressed-sha256"]')
MACHINE_OS_BOOTSTRAP_IMAGE_UNCOMPRESSED_SHA256=${MACHINE_OS_BOOTSTRAP_IMAGE_UNCOMPRESSED_SHA256:-${MACHINE_OS_INSTALLER_BOOTSTRAP_IMAGE_UNCOMPRESSED_SHA256}}
CACHED_MACHINE_OS_IMAGE="${IRONIC_DATA_DIR}/html/images/${MACHINE_OS_IMAGE_NAME}"
if [ ! -f "${CACHED_MACHINE_OS_IMAGE}" ]; then
 echo "rhcos-refresh : Fetching new RHCOS image: $CACHED_MACHINE_OS_IMAGE..."
 curl -g --insecure -L -o "${CACHED_MACHINE_OS_IMAGE}" "${MACHINE_OS_IMAGE_URL}"
 echo "${MACHINE_OS_IMAGE_SHA256} ${CACHED_MACHINE_OS_IMAGE}" | tee ${CACHED_MACHINE_OS_IMAGE}.sha256sum
 sha256sum --strict --check ${CACHED_MACHINE_OS_IMAGE}.sha256sum
else
 echo "rhcos-refresh : Already cached RHCOS image: $CACHED_MACHINE_OS_IMAGE"
fi 
CACHED_MACHINE_OS_BOOTSTRAP_IMAGE="${IRONIC_DATA_DIR}/html/images/${MACHINE_OS_BOOTSTRAP_IMAGE_NAME}"
if [ ! -f "${CACHED_MACHINE_OS_BOOTSTRAP_IMAGE}" ]; then
 echo "rhcos-refresh : Fetching new RHCOS image: $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE..."
 curl -g --insecure -L -o "${CACHED_MACHINE_OS_BOOTSTRAP_IMAGE}" "${MACHINE_OS_BOOTSTRAP_IMAGE_URL}"
 echo "${MACHINE_OS_BOOTSTRAP_IMAGE_SHA256} ${CACHED_MACHINE_OS_BOOTSTRAP_IMAGE}" | tee ${CACHED_MACHINE_OS_BOOTSTRAP_IMAGE}.sha256sum
 sha256sum --strict --check ${CACHED_MACHINE_OS_BOOTSTRAP_IMAGE}.sha256sum
else
 echo "rhcos-refresh : Already cached RHCOS image: $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE"
fi
echo "rhcos-refresh : Fixing up $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE for IPv$NET..."
echo "rhcos-refresh : Unzipping $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE..."
gunzip $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE
CACHED_MACHINE_OS_BOOTSTRAP_IMAGE_UNZIPPED=`echo $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE |sed s/.gz$//g`
if [[ "$NET" == 6 ]]; then
  echo "rhcos-refresh : Editing $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE_UNZIPPED grub.cfg for IPv$NET..."
  virt-edit -a $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE_UNZIPPED -m /dev/sda1 -e "s/ip=dhcp/ip=ens3:dhcp6/g" /grub2/grub.cfg
else
  echo "rhcos-refresh : Editing $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE_UNZIPPED grub.cfg for IPv$NET..."
  virt-edit -a $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE_UNZIPPED -m /dev/sda1 -e "s/ip=ens3:dhcp6/ip=dhcp/g" /grub2/grub.cfg
fi
echo "rhcos-refresh : Generated new sha256 for $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE_UNZIPPED..."
MACHINE_OS_INSTALLER_BOOTSTRAP_IMAGE_UNCOMPRESSED_SHA256=`sha256sum $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE_UNZIPPED|awk {'print \$1'}`
echo "rhcos-refresh : Compressing $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE_UNZIPPED..."
gzip $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE_UNZIPPED
echo "rhcos-refresh : Generating sha256 for $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE..."
sha256sum $CACHED_MACHINE_OS_BOOTSTRAP_IMAGE>$CACHED_MACHINE_OS_BOOTSTRAP_IMAGE.sha256sum
echo "RHCOS_QEMU_IMAGE=$MACHINE_OS_BOOTSTRAP_IMAGE_NAME?sha256=$MACHINE_OS_INSTALLER_BOOTSTRAP_IMAGE_UNCOMPRESSED_SHA256"
echo "RHCOS_OPENSTACK_IMAGE=$MACHINE_OS_IMAGE_NAME?sha256=$MACHINE_OS_IMAGE_SHA256"
sed -i "s/RHCOS_QEMU_IMAGE/$RHCOS_QEMU_IMAGE/g" $HOME/install-config.yaml
sed -i "s/RHCOS_OPENSTACK_IMAGE/$RHCOS_OPENSTACK_IMAGE/g" $HOME/install-config.yaml
sed -i "s/RHCOS_OPENSTACK_IMAGE/$RHCOS_OPENSTACK_IMAGE/g" $HOME/metal3-config.yaml
echo "rhcos-refresh : Completed RHCOS refresh..."
