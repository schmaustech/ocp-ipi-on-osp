#!/bin/bash
export OSP_PROJECT=smoketes-7df4-project
for NODE in $( openstack --os-cloud=$OSP_PROJECT server list|egrep "worker|master"|cut -d\| -f3|sed 's/ //g' )
do
 NAME=$(echo $NODE|sed 's/.$//')
 NUMBER=$(echo $NODE|sed 's/[^0-9]*//g')
 PXEMAC=$(openstack --os-cloud=$OSP_PROJECT  port list --network schmaustech-pxe-network|grep $NAME|grep "\-$NUMBER\-"|cut -d\| -f 4|sed 's/ //g')
 IPMIPORT=$(openstack --os-cloud=$OSP_PROJECT server show $NODE|grep port|cut -d\| -f3|cut -d, -f5|cut -d\' -f2)
 echo "$NODE $PXEMAC $IPMIPORT"
done

