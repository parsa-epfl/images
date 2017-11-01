# QEMU In UEFI Mode
Quick documentation for how I made a full new QEMU image from a stock Ubuntu ISO, without extracting initrd.

### Building EDK2
1. First, need to build and specify the QEMU bootloader for AARCH64. See this guide (I've already added a submodule for edk2): 
    - https://wiki.ubuntu.com/UEFI/EDK2
   
### Setup your Images
2. Then, get your ubuntu server image (server is nice because it's headless, doesn't install Gnome or KDE)
    - http://cdimage.ubuntu.com/releases/16.04.3/release/ubuntu-16.04.3-server-arm64.iso

3. Create the raw disk that QEMU will install on.
```bash
qemu-img create -f qcow2 ./images/new-ubuntu/ubuntu-16.04-efi-blank.qcow2 16G
```

### Install
4. Boot qemu-system-aarch64 and maek sure to specify the iso as a CDROM, and the drive you created as an HDD. This is my command:
```bash
/qemu/aarch64-softmmu/qemu-system-aarch64 -bios ./images/new-ubuntu/QEMU_EFI.fd -drive file=./images/new-ubuntu/ubuntu-16.04.3-server-arm64.iso,id=cdrom,if=none,media=cdrom -device virtio-scsi-device -device scsi-cd,drive=cdrom -m 4096 -nographic -drive file=./images/new-ubuntu/ubuntu-16.04-efi-blank.qcow2,id=rootimg,cache=unsafe,if=none -device scsi-hd,drive=rootimg -serial pty -monitor stdio -machine virt -cpu cortex-a57 -netdev user,id=net1,hostfwd=tcp::2220-:22 -device virtio-net-device,mac=52:54:00:00:00:00,netdev=net1
```
    - In order to get the output, you will need to use screen or another terminal to attach to the pty... eg.
    ```bash
    screen /dev/pts/2
    ```
5. Before you boot into "Install Ubuntu Server", press 'e' and go to the command line configs.
    - Replace "quiet ---" with "console=ttyAMA0" to get the kernel to dump its output onto the emulated serial port

6. Go through the install, and be careful.

### Re-bootup (TODO)
7. I am still doing this part. :)
