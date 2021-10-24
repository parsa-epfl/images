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

# Just follow the default instructions afterwards, it should be an lvm drive
