
# How to create an Ubuntu ARM image

My image: ubuntu 16.04 LTS (64-bit)
Make sure the ubuntu ISO you download is for ARM 64-bit
Here is the [link](https://cdimage.ubuntu.com/releases/16.04/release/ubuntu-16.04.7-server-arm64.iso).

### - Create a QEMU disk image (preferably large so that we don't need to resize).
```
qemu-img create -f qcow2 100G
```

### - Find an appropirate EFI binary:
```
sudo apt-get install qemu-system-arm qemu-efi
dd if=/dev/zero of=flash0.img bs=1M count=64
dd if=/usr/share/qemu-efi/QEMU_EFI.fd of=flash0.img conv=notrunc
dd if=/dev/zero of=flash1.img bs=1M count=64
```

### - Run QEMU:
```
export MYISO=<your iso>
export MYIMAGE=<your image>

qemu-system-aarch64 \
-M virt -m 1G -cpu cortex-a57 -smp 4 \
-global virtio-blk-device.scsi=off -device virtio-scsi-device,id=scsi -rtc driftfix=slew -nographic \
-drive file=$MYISO,id=cdrom,if=none,media=cdrom \
-pflash flash0.img \
-pflash flash1.img \
-drive if=none,file=$MYIMAGE,id=hd0 \
-device scsi-hd,drive=hd0 -device virtio-scsi-device \
-device scsi-cd,drive=cdrom \
-netdev user,id=net1,hostfwd=tcp::2220-:22 -device virtio-net-device,mac=52:54:00:00:02:12,netdev=net1
```

### Issues
Basically, when I ran QEMU to install the image on disk, I was getting an error indicating that the install cannot locate the CD-ROM. turns out this was an ubuntu bug and has been fixed by installing the "debian-installer" package.
[BUG](https://bugs.launchpad.net/ubuntu/+source/debian-installer/+bug/1605407)

After this I managed to install the image. It took really a long time for me to go through the install, so be patient.

### Useful webpages:
- https://designprincipia.com/virtualize-uefi-on-arm-using-qemu/
- http://snapshots.linaro.org/components/kernel/leg-virt-tianocore-edk2-upstream/latest


# How to use this image

Basically, remove the CD-ROM drive and device from the above command:


```
qemu-system-aarch64 \
-M virt -m 1G -cpu cortex-a57 -smp 4 \
-global virtio-blk-device.scsi=off -device virtio-scsi-device,id=scsi -rtc driftfix=slew -nographic \
-pflash flash0.img \
-pflash flash1.img \
-drive if=none,file=$MYIMAGE,id=hd0 \
-device scsi-hd,drive=hd0 -device virtio-scsi-device \
-netdev user,id=net1,hostfwd=tcp::2220-:22 -device virtio-net-device,mac=52:54:00:00:02:12,netdev=net1
```


Remember to setup your network when you first boot if you want to always keep having internet.

One solution is [THIS](https://askubuntu.com/questions/193074/have-to-run-sudo-dhclient-eth0-automatically-every-boot) - Also, dont forget to set permissions for that file:
```
sudo chmod 755 /etc/rc.local
```

