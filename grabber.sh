#!/bin/bash
#NODE=worker0
for NODE in $( cat list )
do
 NAME=$(echo $NODE|sed 's/.$//')
 NUMBER=$(echo $NODE|sed 's/[^0-9]*//g')
 PXEMAC=$(openstack --os-cloud=msp-b910-project  port list --network schmaustech-pxe-network|grep $NAME|grep "\-$NUMBER\-"|cut -d\| -f 4|sed 's/ //g')
 IPMIPORT=$(openstack --os-cloud=msp-b910-project server show $NODE|grep port|cut -d\| -f3|cut -d, -f5|cut -d\' -f2)
 echo "$NODE $PXEMAC $IPMIPORT"
done
