#!/bin/bash
#################################################################
# Cleanup previous deploy whether success or failure		#
#################################################################
echo "cleanup-refresh : Begin cleanup of previous deployment..."
export VM=`sudo virsh list|grep running|awk {'print \$2'}`
if [[ $VM = *bootstrap* ]]; then 
  echo "cleanup-refresh : Cleaning up left over bootstrap..."
  sudo virsh destroy $VM
  sudo virsh undefine $VM
  sudo rm -r -f /var/lib/libvirt/images/$VM
  sudo rm -r -f /var/lib/libvirt/images/$VM.ign
  sudo ls -l /var/lib/libvirt/images/
fi
echo "cleanup-refresh : Cleaning up left over cache from previous deployment..."
rm -r -f `pwd`/.kube
rm -r -f `pwd`/.cache
rm -r -f `pwd`/ocp
echo "cleanup-refresh : Turning off nodes..."
/usr/bin/ipmitool -I lanplus -H10.20.0.3 -p6200 -Uadmin -Predhat chassis power off
/usr/bin/ipmitool -I lanplus -H10.20.0.3 -p6201 -Uadmin -Predhat chassis power off
/usr/bin/ipmitool -I lanplus -H10.20.0.3 -p6202 -Uadmin -Predhat chassis power off
/usr/bin/ipmitool -I lanplus -H10.20.0.3 -p6203 -Uadmin -Predhat chassis power off
/usr/bin/ipmitool -I lanplus -H10.20.0.3 -p6204 -Uadmin -Predhat chassis power off
/usr/bin/ipmitool -I lanplus -H10.20.0.3 -p6205 -Uadmin -Predhat chassis power off
sudo  ip -s -s neigh flush all
echo "cleanup-refresh : Completed cleanup!"
