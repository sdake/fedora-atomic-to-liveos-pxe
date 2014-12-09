#!/bin/bash
# License: ASL2.0
# Converts Fedora Cloud Atomic image into files usable for Ironic PXE booting

IMAGE=Fedora-Cloud-Atomic-20141203-21.x86_64.qcow2
IMAGE_TARGET=fedora-atomic
BOOT_TARGET=`mktemp -d /var/tmp/boot_taget.XXXXXXXXX`
ROOT_TARGET=`mktemp -d /var/tmp/root_target.XXXXXXXXXX`
BOOT_IMAGES_BASE=$BOOT_TARGET/ostree/fedora-atomic-a002a2c2e44240db614e09e82c7822322253bfcaad0226f3ff9befb9f96d315f

echo "Mounting boot and root filesystems."

sudo guestmount -a $IMAGE -m /dev/sda1 $BOOT_TARGET
sudo guestmount -a $IMAGE -m /dev/atomicos/root $ROOT_TARGET

echo "Done mounting boot and root filesystems."

echo "Removing boot from /etc/fstab."

FSTAB_ORIG=$ROOT_TARGET/ostree/deploy/fedora-atomic/deploy/ba7ee9475c462c9265517ab1e5fb548524c01a71709539bbe744e5fdccf6288b.0/etc/fstab
FSTAB_CONVERT=`mktemp /var/tmp/fstab.XXXXXXXXX`
sudo cat $FSTAB_ORIG | grep -v boot > $FSTAB_CONVERT
sudo cp $FSTAB_CONVERT $FSTAB_ORIG

echo "Done removing boot from /etc/fstab."

echo "Extracting kernel to ${IMAGE_TARGET}-kernel"
sudo cp $BOOT_IMAGES_BASE/initramfs-3.17.4-301.fc21.x86_64.img $IMAGE_TARGET-kernel

echo "Extracting ramdisk to ${IMAGE_TARGET}-ramdisk"
sudo cp $BOOT_IMAGES_BASE/vmlinuz-3.17.4-301.fc21.x86_64 $IMAGE_TARGET-ramdisk

echo "Unmounting boot and root."
sudo umount $BOOT_TARGET
sudo umount $ROOT_TARGET

echo "Creating a RAW image from QCOW2 image."

sudo qemu-img convert $IMAGE ${IMAGE_TARGET}.raw

echo "Extracting base image to ${IMAGE_TARGET}-base."
sudo sfdisk -l -uS ${IMAGE_TARGET}.raw | grep LVM | cut -field 2
DD_SKIP=`sudo sfdisk -l -uS ${IMAGE_TARGET}.raw | grep LVM | cut -b23-34 | tr -d ' '`
dd if=${IMAGE_TARGET}.raw of=${IMAGE_TARGET}-base skip=$DD_SKIP

echo "Removing raw file."

sudo rm -f ${IMAGE_TARGET}.raw
