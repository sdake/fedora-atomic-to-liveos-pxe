#!/bin/bash
KERNEL_ID=`glance image-create --name fedora-atomic-kernel --is-public True --disk-format=aki --container-format=aki --file=fedora-atomic-kernel | grep id | tr -d '| ' | cut --bytes=3-57`
echo Registered fedora-atomic-kernel\($KERNEL_ID\).
RAMDISK_ID=`glance image-create --name fedora-atomic-ramdisk --is-public True --disk-format=ari --container-format=ari --file=fedora-atomic-ramdisk | grep id |  tr -d '| ' | cut --bytes=3-57`
echo Registered fedora-atomic-ramdisk\($RAMDISK_ID\).
BASE_ID=`glance image-create --name fedora-atomic --is-public True --disk-format=ami --container-format=ami --property kernel_id=$KERNEL_ID --property ramdisk_id=$RAMDISK_ID --file=fedora-atomic-base | grep -v kernel | grep -v ramdisk | grep id | tr -d '| ' | cut --bytes=3-57`
echo Registered fedora-atomic-base\($BASE_ID\).
