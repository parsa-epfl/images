# 1. Install dependencies
sudo apt-get install qemu-efi-aarch64 qemu-system-aarch64 cloud-image-utils qemu-utils git-lfs

# 2. Create ARM binary images
dd if=/dev/zero of=flash0.img bs=1M count=64
dd if=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd of=flash0.img conv=notrunc
dd if=/dev/zero of=flash1.img bs=1M count=64

# 3. Transform the to modern format (qcow2)
qemu-img convert -f raw -O qcow2 flash0.img flash0.qcow2
qemu-img convert -f raw -O qcow2 flash1.img flash1.qcow2
rm -f flash0.img flash1.img

# 4. Create a base image for the OS
qemu-img create ubuntu20LTS.qcow2 4T -f qcow2

wget 'https://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04.3-live-server-arm64.iso'
