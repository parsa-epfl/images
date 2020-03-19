
# How to use the sample Matrix Multiplication checkpoint
#### This readme provides instructions on how to setup the matrix multiplication benchmark for the QFlex [tutorial](https://qflex.epfl.ch/download/).

Checkout this [matmul](https://github.com/parsa-epfl/images/tree/matmul) branch, and fetch all the files using git lfs.  
($home is the directory containing the main qflex folder)
```
cd $home/qflex/images
git checkout matmul
git lfs fetch
git lfs pull
```

Decompress the ubuntu16.tar.gz and matmul.tar.gz files.
```
tar -xvf ubuntu16.tar.gz
tar -xvf matmul.tar.gz
```

Now, the ubuntu16 folder contains the base Ubuntu image, while the matmul folder contains two checkpoints created using our external snapshots feature.  
Move the two checkpoints to the ubuntu16 folder for simplicity
```
mv matmul/* ubuntu16/
```

We have provided two checkpoints
1. ramp_c1: containing a booted up Ubuntu image with some packages installed.
2. matmul: containing the matrix multiplication benchmark. 
The matmul checkpoint is based on the ramp_c1 checkpoint, so please make sure that both are present.

In order to use the benchmarks, you first need to replace the image path present in the images according to your setup.  
This can be done by using the following script.
```
$home/qflex/qemu/scripts/snap-manager.py --qemu-img-cmd-path $home/qflex/qemu update $home/qflex/images/ubuntu16/ubuntu.qcow2
```

For all the checkpoints placed in the ubuntu16 folder, this command should change the paths and connect them to the base ubuntu16/ubuntu.qcow2 file.
Please note that this command can only be run when qemu is configured for the emulation mode.

Now these checkpoints are ready to use.  
Please further follow the instruction [here](https://qflex.epfl.ch/download/).
To use the captain scripts, modify the following parameters to reflect the machine configuration used in these checkpoints
```
qemu_core_count=1
memory_size=4096
starting_snapshot=matmul
```

Note:

(If required) The corresponding absolute QEMU command to launch the checkpoint is
```
$home/qflex/qemu/aarch64-softmmu/qemu-system-aarch64 --machine virt,gic-version=3 -cpu cortex-a57 -smp 1 -m 4096 \
-rtc clock=vm -nographic \
-global virtio-blk-device.scsi=off -device virtio-scsi-device,id=scsi \
-drive if=none,file=$home/qflex/images/ubuntu16/ubuntu.qcow2,id=hd0 \
-pflash $home/qflex/images/ubuntu16/flash0.img \
-pflash $home/qflex/images/ubuntu16/flash1.img \
-device scsi-hd,drive=hd0 \
-netdev user,id=net1,hostfwd=tcp::2230-:22 \
-device virtio-net-device,mac=52:54:00:00:00:00,netdev=net1 \
-exton -loadext matmul
```

The matrix multiplication benchmark used in this image is taken from https://github.com/attractivechaos/matmul.  
And -mcpu=cortex-a57+nofp argument is used in compilation to avoid floating point and SIMD instructions.  
For the same, all `float` keywords are replaced with `int` in the matmul.c file, and the fprintf calls for float variables are removed.
This is done because current QFlex KnottyKraken simulator does not model SIMD or FP instructions.
