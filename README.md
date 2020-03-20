# How to use the sample Matrix Multiplication checkpoint

Checkout this [matmul](https://github.com/parsa-epfl/images/tree/matmul-knockoutkraken) branch, and fetch all the files using git lfs.  
($home is the directory containing the main qflex folder)
```
cd $home/qflex/images
git checkout matmul
git lfs fetch
git lfs pull
```

Unpack the images:
```
./unpack.sh
```

We have provided a checkpoint named testbench which contains the matrix multiplication benchmark. 
To test the image out runn the following command:

```

$ $home/qflex/qemu/aarch64-softmmu/qemu-system-aarch64 --machine virt,gic-version=3 -cpu cortex-a57 -smp 1 -m 4096 \
    -rtc clock=vm -nographic \
    -global virtio-blk-device.scsi=off -device virtio-scsi-device,id=scsi \
    -drive if=none,file=$home/qflex/images/ubuntu16/ubuntu.qcow2,id=hd0 \
    -pflash $home/qflex/images/ubuntu16/flash0.img \
    -pflash $home/qflex/images/ubuntu16/flash1.img \
    -device scsi-hd,drive=hd0 \
    -netdev user,id=net1,hostfwd=tcp::2230-:22 \
    -device virtio-net-device,mac=52:54:00:00:00:00,netdev=net1 \
    -exton -loadext testbench
```
