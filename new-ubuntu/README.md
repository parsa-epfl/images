# QEMU In UEFI Mode
Quick documentation for how I made a full new QEMU image from a stock Ubuntu ISO, without extracting initrd.

### Building EDK2
1. First, need to build and specify the QEMU bootloader for AARCH64. See these guides: 
    - https://wiki.ubuntu.com/UEFI/EDK2
    - https://wiki.linaro.org/LEG/UEFIforQEMU
   
### Setup your Images
2. Then, get your ubuntu server image (server is nice because it's headless, doesn't install Gnome or KDE)
    - http://cdimage.ubuntu.com/releases/16.04.3/release/ubuntu-16.04.3-server-arm64.iso

3. Create the raw disk that QEMU will install on.
```bash
$ qemu-img create -f qcow2 ./images/new-ubuntu/ubuntu-16.04-efi-blank.qcow2 16G
```

### Install
4. Boot qemu-system-aarch64 and make sure to specify the iso as a CDROM, and the drive you created as an HDD. This is my command:
```bash
$./qemu/aarch64-softmmu/qemu-system-aarch64 \
    -bios ./images/new-ubuntu/QEMU_EFI.fd \
    -drive file=./images/new-ubuntu/ubuntu-16.04.3-server-arm64.iso,id=cdrom,if=none,media=cdrom \
    -device virtio-scsi-device \
    -device scsi-cd,drive=cdrom \
    -m 4096 \
    -drive file=./images/new-ubuntu/ubuntu-16.04-efi-blank.qcow2,id=rootimg,cache=unsafe,if=none \
    -device scsi-hd,drive=rootimg \
    -serial pty \
    -monitor stdio \
    -machine virt \
    -cpu cortex-a57 \
    -netdev user,id=net1,hostfwd=tcp::2220-:22 \
    -device virtio-net-device,mac=52:54:00:00:00:00,netdev=net1
```
    - In order to get the output, you will need to use screen or another terminal to attach to the pty... eg.
    ```bash
    $screen /dev/pts/2
    ```
5. Before you boot into "Install Ubuntu Server", press 'e' and go to the command line configs.
    - Replace "quiet ---" with "console=ttyAMA0" to get the kernel to dump its output onto the emulated serial port

6. Go through the install, and be careful.

### Re-bootup (TODO)
7. Now we need to make the bootloader persistent so Step 8 will stick across reboots, using QEMU support for -pflash. Run the following:
- first create a new flash0.img from QEMU-EFI.fd (this is because they have to be EXACTLY 64MB):
```bash
$ cat QEMU_EFI.fd /dev/zero | dd iflag=fullblock bs=1M count=64 of=flash0.img 
```
-now a blank flash1.img
```bash
$ dd if=/dev/zero of=flash1.img bs=1M count=64
```
- Now, your next QEMU command should exchange "-bios" with two "-pflash" args, such as:
```bash
$ /qemu/aarch64-softmmu/qemu-system-aarch64 -pflash /path/to/flash0.img -pflash /path/to/flash1.img
```
- With this, any arguments you change will stick and be stored in "flash1.img".

8. When you go into the bootloader, it probably will not have recognized the EFI... You will have to go into "boot from file" and then navigate the drive to find the entry called "grubaarch64.efi". Add that as a boot entry and then bring it up to the top of the boot order. 
9. When you see the options titled "ubuntu", press 'e' and append:
```bash
$ console="ttyS0" console="ttyAMA0"
```
10. Boot and enjoy. My QEMU command currently looks like:
```bash
$ ./qemu/aarch64-softmmu/qemu-system-aarch64 \
    -drive file=./images/new-ubuntu/flash0.img,if=pflash,format=raw,unit=0,readonly=on \
    -drive file=./images/new-ubuntu/flash1.img,if=pflash,format=raw,unit=1,readonly=on \
    -m 2048 \
    -device virtio-scsi-device,id=scsi \
    -drive file=./images/new-ubuntu/ubuntu-16.04-efi-blank.qcow2,id=rootimg,cache=unsafe,if=none \
    -device scsi-hd,drive=rootimg \
    -machine virt \
    -cpu cortex-a57 \
    -netdev user,id=net1,hostfwd=tcp::2220-:22 \
    -device virtio-net-device,mac=52:54:00:00:00:00,netdev=net1 \
    -nographic
```

