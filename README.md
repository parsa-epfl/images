
# How to create an Ubuntu ARM image

My image: ubuntu 20.04 LTS Server (64-bit)

### - Create QEMU disk images

NOTE: The script `run-make-ubuntu20.04-img.sh` does all these steps

1. Install dependencies
```
sudo apt-get install qemu-efi-aarch64 qemu-system-aarch64 cloud-image-utils qemu-utils git-lfs
```

2. Create ARM binary images

```
dd if=/dev/zero of=flash0.img bs=1M count=64
dd if=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd of=flash0.img conv=notrunc
dd if=/dev/zero of=flash1.img bs=1M count=64
```

3. Transform the to modern format (qcow2)
```
qemu-img convert -f raw -O qcow2 flash0.img flash0.qcow2
qemu-img convert -f raw -O qcow2 flash1.img flash1.qcow2
rm -f flash0.img flash1.img
```

4. Create a base image for the OS

```
qemu-img create ubuntu20LTS.qcow2 4T -f qcow2

```

4. Download Ubuntu ISO for ARM 64-bit (aarch64)
Make sure the ubuntu ISO you download is for ARM 64-bit.
Here is the [link](https://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04.3-live-server-arm64.iso).
```
wget 'https://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04.3-live-server-arm64.iso'
```

### - Boot the image and install the OS (takes a long time)

1.  Boot the installation disk:

NOTE: script `run-install-image.sh` has this command.

```
qemu-system-aarch64 \
	-cpu max -M virt,gic-version=3 \
	-smp 4 -m 8G \
	-nographic \
	-rtc clock=vm \
	--accel tcg,thread=multi \
    -global virtio-blk-device.scsi=off \
    -device virtio-scsi-device,id=scsi0 \
    -device virtio-scsi-device,id=scsi1 \
    -device virtio-scsi-pci,id=scsi2 \
    -device scsi-hd,drive=hd0 \
    -netdev user,id=net0,hostfwd=tcp::2240-:22 \
	-cdrom ubuntu-20.04.3-live-server-arm64.iso \
    -device virtio-net-device,netdev=net0,mac=52:54:00:00:01:00 \
    -drive file=flash0.qcow2,format=qcow2,if=pflash \
    -drive file=flash1.qcow2,format=qcow2,if=pflash \
    -drive file=ubuntu20LTS.qcow2,format=qcow2,id=hd0,if=none \
```

2. Follow instructions

The image created in previous section is of 4TB, which should be more than enough for any workload.

By default it should make the root drive a partition with LVM enabled, this will allow for the disk 
drive to automatically expand so that you never run out of VM disk space and you don't start creating 
a 4T image.

### Issues

### Useful webpages:
- https://designprincipia.com/virtualize-uefi-on-arm-using-qemu/
- http://snapshots.linaro.org/components/kernel/leg-virt-tianocore-edk2-upstream/latest


# How to use this image

Basically, remove the CD-ROM drive and device from the above command:


```
qemu-system-aarch64 \
	-cpu max -M virt,gic-version=3 \
	-smp 4 -m 8G \
	-nographic \
	-rtc clock=vm \
	--accel tcg,thread=multi \
    -global virtio-blk-device.scsi=off \
    -device virtio-scsi-device,id=scsi0 \
    -device virtio-scsi-device,id=scsi1 \
    -device virtio-scsi-pci,id=scsi2 \
    -device scsi-hd,drive=hd0 \
    -netdev user,id=net0,hostfwd=tcp::2240-:22 \
    -device virtio-net-device,netdev=net0,mac=52:54:00:00:01:00 \
    -drive file=flash0.qcow2,format=qcow2,if=pflash \
    -drive file=flash1.qcow2,format=qcow2,if=pflash \
    -drive file=ubuntu20LTS.qcow2,format=qcow2,id=hd0,if=none \

	#-cdrom ubuntu-20.04.3-live-server-arm64.iso \ # Removed line
```


Remember to setup your network when you first boot if you want to always keep having internet.

One solution is [THIS](https://askubuntu.com/questions/193074/have-to-run-sudo-dhclient-eth0-automatically-every-boot) - Also, dont forget to set permissions for that file:
```
sudo chmod 755 /etc/rc.local
```

