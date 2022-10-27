<!--
MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

Hardware/software integration: a Linux software driver for the DHT11 controller

---

- [Conventions and requirements](#conventions-and-requirements)
- [Introduction](#introduction)
- [Environment set-up](#environment-set-up)
- [Device tree](#device-tree)
- [Linux kernel](#linux-kernel)
- [DHT11 Linux driver](#dht11-linux-driver)
- [Prepare the SD card](#prepare-the-sd-card)
- [Testing](#testing)

---

Note: before working on this lab you must complete the [AXI4 lite wrapper for the DHT11 controller](../lab08).

# Conventions and requirements

Throughout this document we use different prompts for the different contexts:

* `Laptop>` is the shell prompt of the regular user (you) on your own laptop
* `Host>` is the shell prompt of the regular user (you) on the EURECOM's desktop GNU/Linux computer.
* `hsi%` is the prompt of the `hsi` Xilinx tool in interactive command line mode
* `[root@ds]>` is the shell prompt of the `root` user on the Zybo board
* `[user@ds]>` is the shell prompt of `user`, a regular, unprivileged user on the Zybo board

For many different reasons parts of this lab cannot be done on your own laptop.
Instead, please work on a EURECOM desktop GNU/Linux computer, possibly through a `ssh` connection from your own laptop.
The most important reasons for this are:

* For these parts macOS and Windows are not supported
* The version of the Xilinx tools must be exactly 2018.3 (later versions not supported)
* We use huge git repositories that are already available on EURECOM's desktop GNU/Linux computer but would take very long to clone on your personal laptop
* Everything has been tested on EURECOM's GNU/Linux desktops.
There is a high probability that something does not work out of the box on your own laptop and we don't have much time to fix configuration issues

Please report errors and send suggestions for improvements to [renaud.pacalet@telecom-paris.fr].

# Introduction

The embedded system world sometimes looks overcomplicated to non-specialists.
But most of this complexity comes from the large number of small things that make this world, not really from the complexity of these small things themselves.
Understanding large portions of this exciting field is perfectly feasible, even without a strong background in computer sciences.
And, of course, doing things alone is probably one of the best ways to understand them.

In the following we design, build and test a complete computer system based on the Zybo board, with a custom hardware extensions (the AXI4 lite version of our DHT11 controller) and a complete GNU/Linux software stack.
We equip the software stack with a software driver for our DHT11 controller.
In Linux parlance our driver is a "_kernel module_" because it can be dynamically loaded and unloaded in the Linux kernel at run-time.
Other types of drivers are built statically into the kernel and cannot be separated from it.
Kernel modules are frequently preferred because of their better flexibility.
There are exceptions.
We also design a small C software application on top of our driver.

Finally, we test all this on the board and see how we can control the hardware extensions from the software world.
Each step is briefly explained.
Do not hesitate to search for complementary information, there are many on-line manuals and tutorials.

# Environment set-up

We must build several independent software components.
As it is always better to work out of the source tree, we use a temporary directory, which path is stored in shell variable `tmp`, with several sub-directories:

* `"$tmp"/syn`: for Vivado synthesis
* `"$tmp"/kernel`: for the Linux kernel
* `"$tmp"/dts`: for the Device Tree Sources
* `"$tmp"/C`: for the Linux Device driver

Some of these sub-directories are created automatically by the tools.
Example of set-up (adapt the suggested `tmp` path to your own preference):

```bash
Host> tmp=/tmp/$USER/ds
Host> mkdir -p "$tmp"/syn "$tmp"/C
```

During the previous lab you stored two synthesis products in a `ds_archives` directory under your home directory.
To simplify the final download of the generated files on the SD card, we continue using this directory to store the various components.

If you still do not have a working DHT11 controller or AXI4 lite wrapper of it, you can copy the provided references, instead:

```bash
Host> cp "$ds"/software/boot.bin ~/ds_archives
Host> cp "$ds"/software/dht11_ctrl_axi_wrapper.sysdef ~/ds_archives
```

# Device tree

A device tree is a textual description of the hardware platform on which the Linux kernel runs.
Before the concept of device trees have been introduced, running the same kernel on different platforms was difficult, even if the processor was the same.
It was quite common to distribute different kernel binaries for very similar platforms because the set of devices was different or because some parameters, like the hardware address at which a device is found, were different.
Thanks to device trees, the same kernel can discover the hardware architecture of the target and adapt itself during boot.
To make a long story short, we generate a textual description of the board, including our custom hardware peripheral.
This description is the device tree source or `dts`.
We then transform it into an equivalent binary form, the device tree blob or `dtb`, with `dtc`, the device tree compiler.
Finally, we add this device tree blob to the SD card.
During the boot it is loaded in memory, the Linux kernel parses this data structure and configures itself accordingly.

The Xilinx `device-tree-xlnx` git repository has already been cloned in `/packages/LabSoC/device-tree-xlnx`.
It contains templates of device tree sources for all Xilinx integrated circuits and boards.
The `dht11_ctrl_axi_wrapper.sysdef` synthesis product that we saved in `~/ds_archives` is a binary description of our design (name, interfaces...), generated last time during the synthesis.
The `hsi` Xilinx command line tool can automatically generate the device tree source from the clone of the Xilinx `device-tree-xlnx` git repository and the `dht11_ctrl_axi_wrapper.sysdef` synthesis result (ignore the warnings):

```bash
Host> cd "$tmp"
Host> hsi
hsi% set design [ open_hw_design $env(HOME)/ds_archives/dht11_ctrl_axi_wrapper.sysdef ]
hsi% set_repo_path /packages/LabSoC/device-tree-xlnx
hsi% create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
hsi% generate_target -dir dts
hsi% quit
```

A `$tmp/dts` directory has been created and populated with the device tree source.
Look at the `$tmp/dts/pl.dtsi` file (included by the `$tmp/dts/system-top.dts` top-level).
It defines one parent node named `amba_pl`.
AMBA is the generic name of the ARM bus protocols, including the AXI4 lite protocol.
PL is a short hand for Programmable Logic, the FPGA part of the Zynq core.
This `amba_pl` node corresponds to the interface between the ARM CPUs and the FPGA part of the Zynq.
The file also declares a child node of `amba_pl`, named `dht11_ctrl_axi_wrapper@40000000`.
This is our DHT11 controller, embedded in the FPGA part of the Zynq core.
Two attributes are declared for this child node:

* `compatible`, a string that the Linux kernel uses to search for a software driver compatible with this hardware peripheral.
* `reg`, a physical address range definition for the hardware peripheral.
In our case, this attribute tells the Linux kernel that all addresses in range `[0x40000000..0x40001000[` (4 kB) are mapped to our peripheral.

Remember the value of these two attributes, we will need them when designing a software driver for our peripheral.
The generated device tree makes use of the C preprocessor directives (`#include...`).
We thus first use the `cpp` C preprocessor to pre-process the device tree sources and then the `dtc` device tree compiler to generate the binary form that Linux expects (ignore the warning about a missing unit name):

```bash
Host> cd "$tmp"/dts
Host> cpp -nostdinc -undef -x assembler-with-cpp -o devicetree.dts system-top.dts
Host> dtc -I dts -O dtb -o ~/ds_archives/devicetree.dtb devicetree.dts
```

The `~/ds_archives` directory now contains `devicetree.dtb`, the binary version of the device tree (the device tree blob).
The `dtc` compiler is also a de-compiler.
Let's use this feature to dump the complete device tree source and check that our device is embedded in the device tree blob:

```bash
Host> dtc -I dtb -O dts ~/ds_archives/devicetree.dtb
```

As you can see there are many other devices.
Do you recognize some of them?
Can you find our device?

# Linux kernel

The Linux kernel is a key component of our software stack, even if it is not sufficient and would not be very useful without a root file system and all the software applications in it.
The kernel and its software device drivers are responsible for the management of our small computer.
They control the sharing of all resources (CPUs, memory, peripherals...) among the different software applications and serve as intermediates between the software and the hardware, hiding most of the low level details.
They also offer the same (software) interface, independently of the underlying hardware: thanks to the kernel and its device drivers we access the various features of our board exactly as we would do on another type of computer.
This is what is called _hardware abstraction_ in the computer world.

We already have a compiled kernel on our SD cards (and in `$ds/software/uImage`) but in order to compile our device driver we need a complete configured and compiled source tree of the Linux kernel, not just a binary image.
Never compiled the Linux kernel?
It is time to do it.
We use the version that has been customized by Xilinx for the Zynq cores.

The kernel must run on the ARM processor of the Zynq core of the Zybo, not on your laptop or desktop.
We must thus use a cross-compiler, that is, a compiler that runs on your computer (`x86_64` architecture) but produces binaries for the ARM processor.
Such a cross-compiler comes with the Xilinx tools:

```bash
Host> ls /packages/LabSoC/Xilinx/bin
...
arm-linux-gnueabihf-gcc
...
```

We just need to tell the Linux build system which compiler to use, thanks to the `CROSS_COMPILE` environment variable (beware the trailing `-`):

```bash
Host> export CROSS_COMPILE=arm-linux-gnueabihf-
Host> ${CROSS_COMPILE}gcc --version
arm-linux-gnueabihf-gcc (Linaro GCC 7.3-2018.04-rc3) 7.3.1 20180314
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

The build process also makes use of the `mkimage` utility to format the generated binary kernel for the U-Boot boot loader.
This utility is available in `/packages/LabSoC/bin`.
Add it to your `PATH`:

```bash
Host> export PATH=$PATH:/packages/LabSoC/bin
```

We are now ready to build the Linux kernel.
The first step consists in creating a fresh build tree configured for the Xilinx Zynq target in `"$tmp"/kernel`:

```bash
Host> cd /packages/LabSoC/linux-xlnx
Host> make O="$tmp"/kernel ARCH=arm xilinx_zynq_defconfig
```

We can now compile this configured kernel.
It is a time-consuming task but highly parallelizable, so let's first find how many cores you have in your computer.
Example under GNU/Linux:

```bash
Host> lscpu
...
CPU(s):              6
On-line CPU(s) list: 0-5
Thread(s) per core:  1
Core(s) per socket:  6
Socket(s):           1
...
```

`CPU(s)` is the total number of logical cores, that is, the product of _Socket(s)_ (processor chips) by _Core(s) per socket_ and by _Thread(s) per core_: $1 \times 6 \times 1 = 6$.
This gives you a reasonable degree of parallelism to expect from your computer (6 in our example).
Then compile with:

```bash
Host> cd "$tmp"/kernel
Host> make -j6 ARCH=arm LOADADDR=0x8000 uImage
```

The `-jX` option of `make` tells `make` to launch up to `X` jobs in parallel.
With a `X`-CPUs processor it speeds-up the build process by a factor of almost `X`.
**Do not try larger values than what your computer offers**, there would be a risk of overload and freeze.
Be patient, the Linux kernel is a large piece of software and its compilation takes some time.
Copy the generated image:

```bash
Host> cp "$tmp"/kernel/arch/arm/boot/uImage ~/ds_archives
```

# DHT11 Linux driver

Accessing the DHT11 hardware device using the `devmem` utility, like we did during the previous lab, is not very convenient.
In this section we create a Linux software driver for DHT11 and use it to interact more conveniently with the hardware.
The provided example can be found in the `$ds/vhdl/lab09/dht11_driver.c` source file.

The proposed driver follows a model called _platform device driver_.
To now more about this model you can read the Linux kernel documentation (`/packages/LabSoC/linux-xlnx/Documentation/driver-model/platform.txt`) and/or the corresponding header file in the Linux kernel sources (`/packages/LabSoC/linux-xlnx/include/linux/platform_device.h`).
In summary, the driver creates a device pseudo-file named `/dev/dht11` and routes all read-write accesses to this pseudo-file to our hardware peripheral.

Carefully read the source code of the `dht11_driver.c` Linux device driver, it is commented.
Try to understand as much as you can:

1. Locate the compatible string declaration (search for `YOUR COMPATIBLE STRING`) and replace the dummy value by the **exact** string we already encountered in the device tree sources.
1. Note that messages are printed by the `dht11_probe` and `dht11_remove` functions using the kernel `printk` function, not the user space `printf` function.
Replace the dummy `YOUR HELLO MESSAGE` and `YOUR BYE MESSAGE` strings by messages of your own.
1. Note that five different functions are defined:
    * `dht11_open`: called by the kernel when the device pseudo-file (`/dev/dht11`) corresponding to our peripheral is opened
    * `dht11_close`: called by the kernel when the device pseudo-file (`/dev/dht11`) corresponding to our peripheral is closed
    * `dht11_read`: called by the kernel when the device pseudo-file (`/dev/dht11`) corresponding to our peripheral is read
    * `dht11_remove`: called by the kernel when the driver is unloaded
    * `dht11_probe`: called by the kernel when the driver is loaded
1. Try to understand how `dht11_read` reads the interface register of our peripheral and copies the read value in the user space
1. Study how `dht11_remove` undoes in reverse order what has been done by `dht11_probe` when the driver has been loaded
1. Study how `dht11_probe` checks for errors at each step and, when an error is detected, uses a series of `goto` instructions to undo only what has been successfully done

To compile our driver we use the Linux kernel build system.
First copy the source code in our build directory:

```bash
Host> cp -r "$ds"/vhdl/lab09/dht11_driver.c "$tmp"/C
```

Create a very simple `Makefile` to tell the Linux kernel build system what object files are part of the driver:

```bash
Host> echo 'obj-m := dht11_driver.o' > "$tmp"/C/Makefile
```

Finally, compile the driver and copy the binary:

```bash
Host> cd "$tmp"/kernel
Host> make ARCH=arm M="$tmp"/C modules
Host> cp "$tmp"/C/dht11_driver.ko ~/ds_archives
...
```

The `$ds/vhdl/lab09` directory also contains a small test software application: `test_dht11_driver.c`.
It is a very simple C program that uses the device pseudo-file (`/dev/dht11`) created by the device driver to read the sensed data and print them.
Look at its source code and try to understand it.
Cross-compile it for the ARM processor and copy the binary:

```bash
Host> cp "$ds"/vhdl/lab09/test_dht11_driver.c "$tmp"/C
Host> cd "$tmp"/C
Host> ${CROSS_COMPILE}gcc -o test_dht11_driver test_dht11_driver.c
Host> cp "$tmp"/C/test_dht11_driver ~/ds_archives
```

# Prepare the SD card

Mount the micro SD card on your computer and define a shell variable that points to it:

```bash
Host> SDCARD=<path-to-mounted-sd-card>
```

Copy the boot image, the device tree blob, the Linux kernel image, the compiled module and the software application to the SD card:

```bash
Host> cd ~/ds_archives
Host> cp boot.bin devicetree.dtb uImage dht11_driver.ko test_dht11_driver "$SDCARD"
```

If you never did it before also copy the provided root file system:

```bash
Host> cp "$ds"/software/uramdisk.image.gz "$SDCARD"
```

Unmount the micro SD card and eject it.

# Testing

As during the previous lab, in the following we use the USB link between our computer and the Zybo board to communicate with the operating system that runs on the ARM processor of the Zynq core.

Starting from here you can work on your own laptop, if you wish.
For this, if you do not have one already, you need to install a serial communication program, also frequently referred to as a _terminal emulator_ (see the [FAQ](/FAQ.md#terminal-emulators)).
On EURECOM GNU/Linux desktop computers there are already several terminal emulators (`picocom`, `minicom`, `screen`...).

Plug the micro SD card on the Zybo.
Plug the DHT11 sensor to the Zybo and plug the male end of the wire in the `JE1` pin of the `JE` Pmod connector (if you do not remember how to connect the sensor have a look at the [_Test_ section of the previous lab](../lab08/README.md#test).
Power up.
Launch your serial communication program (e.g. `picocom`) and attach it to the serial device that corresponds to the Zybo board.
Example under EURECOM GNU/Linux desktop computers with `picocom`:

```bash
Host> picocom -b115200 /dev/zyboUSB
...
Welcome to DS (c) Telecom Paris
ds login: root
[root@ds]>
```

You are now connected as the `root` user under the GNU/Linux OS that runs on the Zynq core of the Zybo board.
The device pseudo-file corresponding to our peripheral does not exist yet:

```bash
[root@ds]> ls -l /dev/dht11
ls: /dev/dht11: No such file or directory
```

The `/proc` and `/sys` pseudo file systems contain information about the loaded modules and the device pseudo-files but nothing yet about our module:

```bash
[root@ds]> cat /proc/modules
[root@ds]> ls /sys/class/dht11
ls: /sys/class/dht11: No such file or directory
```

The SD card is mounted in `/media/sdcard`:

```bash
[root@ds]> ls /media/sdcard
boot.bin           dht11_driver.ko    uImage
devicetree.dtb     test_dht11_driver  uramdisk.image.gz
```

Insert the driver in the Linux kernel:

```bash
[root@ds]> insmod /media/sdcard/dht11_driver.ko
DHT11 module loaded
DHT11 mapped at virtual address 0xe0964000
DHT11 YOUR HELLO MESSAGE
```

The `/dev/dht11` device pseudo-file has now been created and can be used to read the interface registers of our peripheral:

```bash
[root@ds]> ls -l /dev/dht11
crw-rw-rw-    1 root     root      245,   0 Jan  1 00:00 /dev/dht11
[root@ds]> cat /proc/modules
dht11_driver 16384 0 - Live 0xbf000000 (O)
[root@ds]> ls /sys/class/dht11
dht11
[root@ds]> od -N4 -tu1 /dev/dht11
0000000  26  56   0 128
0000004
```

> Note: the `od` command reads the 4 first bytes of the device pseudo-file (`-N4`) and interprets each of them as a one-byte unsigned integer (`-tu1`).
Do you understand what you see?

Continue looking around and testing the system.
Try, for instance, to read more than 4 bytes from the device pseudo-file.
Or to write to it.
Run the software application:

```bash
[root@ds]> /media/sdcard/test_dht11_driver
Last successful acquisition:
  Relative humidity: 56%
  Temperature:       26 °C
```

Now that our device is seen as a device pseudo-file in `/dev` we do not need to know its physical address, which was one of the two main drawbacks of the `devmem` approach.
Moreover, thanks to the `mdev` configuration defined in `/etc/mdev.conf` (see the last lines), `/dev/dht11` is created with read-write access rights for all users:

```bash
[root@ds]> ls -l /dev/dht11
crw-rw-rw-    1 root     root      245,   0 Jan  1 00:00 /dev/dht11
```

Let us verify this by login in as a regular user and trying to access the device:

```bash
[root@ds]> exit

Welcome to DS (c) Telecom Paris
ds login: user
[user@ds]> od -N4 -tu1 /dev/dht11
0000000  27  54   0 128
0000004
[user@ds] /media/sdcard/test_dht11_driver
Last successful acquisition:
  Relative humidity: 54%
  Temperature:       27%
```

This solves the second main issue with the `devmem` approach that was reserved to the privileged root user.
Once you are done with your experiments, remove the module device driver (as root), unmount the SD card and properly shut down:

```bash
[user@ds]> exit

Welcome to DS (c) Telecom Paris
ds login: root
[root@ds]> rmmod dht11_driver
DHT11 module removed.
DHT11 YOUR BYE MESSAGE
[root@ds]> umount /media/sdcard
[root@ds]> poweroff
[root@ds]> Stopping network: OK
...
Requesting system poweroff
reboot: System halted
```

You can now safely power the board off.

[renaud.pacalet@telecom-paris.fr]: mailto:renaud.pacalet@telecom-paris.fr

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
