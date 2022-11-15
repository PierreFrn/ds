<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
https://cecill.info/licences/Licence_CeCILL_V2.1-en.html
-->

Digital Systems labs

---

- [Homeworks](#homeworks)
  * [For 2021-04-26](#for-2021-04-26)
  * [For 2021-04-12](#for-2021-04-12)
  * [For 2022-04-05](#for-2022-04-05)
  * [For 2022-03-29](#for-2022-03-29)
  * [For 2022-03-22](#for-2022-03-22)
  * [For 2022-03-15](#for-2022-03-15)
  * [For 2022-03-08](#for-2022-03-08)
- [Recommendations](#recommendations)
  * [Keep the git repository clean](#keep-the-git-repository-clean)
  * [Carefully check the synthesis results](#carefully-check-the-synthesis-results)
  * [Miscellaneous](#miscellaneous)
- [GitLab and git set-up](#gitlab-and-git-set-up)
- [Tools](#tools)
  * [The VHDL synthesizer](#the-vhdl-synthesizer)
  * [The VHDL simulator](#the-vhdl-simulator)
  * [Installing Vivado WebPack](#installing-vivado-webpack)
    + [Troubleshooting](#troubleshooting)
  * [Installing Modelsim-Intel FPGA starter edition software](#installing-modelsim-intel-fpga-starter-edition-software)
    + [Troubleshooting](#troubleshooting-1)
  * [Free and open source hardware design tools](#free-and-open-source-hardware-design-tools)
    + [VHDL simulation](#vhdl-simulation)
    + [VHDL synthesis](#vhdl-synthesis)

---

# Homeworks

## For 2021-04-26

- Finish reading the [Free Range Factory] VHDL book
- Complete the lab on the [Linux device driver for the DHT11 controller](vhdl/lab09)
   * Generate and compile the device tree
   * Configure and compile the Linux kernel
   * Understand and adapt the provided Linux driver and example software application
   * Compile the Linux driver and the example software application
   * Test on the Zybo board
   * Write your report
- Read again the specifications of the lite version of the [AXI4 lite protocol] and imagine how a hardware accelerator could act as a master to directly access the memory of a computer system.
- Edit the `/status3.md` file and fill the [third intermediate status check-list]

## For 2021-04-12

- Read chapters 8 to 9 of the [Free Range Factory] VHDL book
- Read the following parts of the documentation:
  * [Examining synthesis results]
- Complete the AXI4 lite wrapper for the `dht11_ctrl` controller:
  * Block diagram
  * State diagrams
  * VHDL coding
  * Simulation, debugging, pass automatic evaluation
  * Synthesis and test on the Zybo
- Edit the `/status2.md` file and fill the [second intermediate status check-list]

## For 2022-04-05

- Read chapters 6 to 7 of the [Free Range Factory] VHDL book
- Read the following parts of the documentation:
  * [Unconstrained types]
  * [Recursivity]
  * [Protected types]
  * [Random numbers generation]
- Complete all pending items in [first intermediate status check-list]
- Complete the DHT11 controller
  * Block diagram
  * State diagram
  * VHDL coding
  * Simulation, debugging, pass automatic evaluation
  * Synthesis and test on the Zybo
- Study the [AXI4 lite protocol specification]

## For 2022-03-29

- Complete all challenges, including synthesis and test on the Zybo
- Continue working on the block and state diagrams for the DHT11 controller
- Edit the `/status1.md` file and fill the [first intermediate status check-list]

## For 2022-03-22

- Read chapter 5 of the [Free Range Factory] VHDL book
- If you didn't already, read the following parts of the documentation:
  * [Generic parameters]
  * [Aggregate notations]
  * [Resolution functions, unresolved and resolved types]
  * [Arithmetic: which types to use?]
  * [Entity instantiations]
- Complete the 4 first labs, including synthesis and test on the Zybo
- Read the [DHT11 sensor datasheet]

## For 2022-03-15

- Complete [lab01](vhdl/lab01) and [lab02](vhdl/lab02)
- Continue learning git and Markdown ([ProGit book], [Daring Fireball], [Markdown tutorial]).
- Read chapter 4 of the [Free Range Factory] VHDL book
- Read the following parts of the documentation:
  * [Comments]
  * [Identifiers]
  * [Wait]
  * [Initial values declarations]
  * [D-flip-flops (DFF) and latches]

## For 2022-03-08

- Learn a bit of `git` ([ProGit book]). Watch the videos. Try to imagine a work flow with a protected master branch and one branch per student.
- Learn a bit of Markdown ([Daring Fireball], [Markdown tutorial]).
- Read the [Getting started with VHDL] section of the documentation. Prepare questions.
- Read the [Digital hardware design using VHDL in a nutshell] section of the documentation. Prepare questions.
- Read the [VHDL simulation] section of the documentation. Prepare questions.
- Read the first three chapters of the [Free Range Factory] VHDL book.
- Solve all technical issues
  * If you use your own laptop, be able to ssh to a EURECOM GNU/Linux computer in room 52 (for the syntheses).
  * Be able to git clone the GitLab project on your personal computer and/or a EURECOM GNU/Linux computer, create your personal branch, and push it; [GitLab and git set-up](#gitlab-and-git-set-up).
  * Be able to compile and simulate an example design, examine the waveforms; see [VHDL simulation].

# Recommendations

In order to attend the labs and get the full benefit of them you should:

* Be reasonably comfortable with a personal computer under GNU/Linux.
There are some good books available and a lot of on-line resources (manuals, tutorials, etc).
[bootlin], for instance, has a very useful one-page [memento of the most useful GNU/Linux commands]; there are even French, German and Italian versions.
Local copies can be found in the `/doc/data` directory.
Attending the _Software Development (SoftDev)_ EURECOM course or having a look at its companion material is also a very good option.
* Be able to use at least one of the text editors that can be found under GNU/Linux (`emacs`, `vim`, `nano`, `gedit`, `atom`, `sublime text`...)
* Have some knowledge of algorithm principles and basic programming skills.
Knowing a bit of the C programming language, while not needed, can help.

## Keep the git repository clean

Remember that we all share the same git repository, reason why it is important to keep it reasonably clean.
To avoid a too fast grow of the size of the repository, please:

* Avoid adding full directories; it is sometimes convenient but also the best way to add a large number of large generated files that we do not want in the repository; try to `git add` only individual files, and only files that make sense (source files, reports in Mardown format, carefully selected images used in reports...).
* Try to use the right resolution for the (carefully selected) images that you add.
* Try to run simulations and syntheses out of your local copy of the git repository; the large generated files will be kept out of the source tree and this will reduce the risk of accidental commits of unwanted files.

## Carefully check the synthesis results

The semantics of the VHDL language for simulation and synthesis are not the same.
As a consequence, it can perfectly be that your design simulates apparently as expected but that the synthesis result does not behave as expected on the target hardware.
When synthesizing with Xilinx Vivado it is thus strongly advised to carefully check the synthesis results.
The [Examining synthesis results] part of the documentation explains what should be checked and how.

## Miscellaneous

In the lab instructions you are asked to type commands.
These commands are preceded by the prompt of the current shell.
It can be a simple `$` sign, or a more informative prompt like `[user]`, `[user@host]`, `[user@host:directory]`, `[user@host:/some/current/path]`...
It is not a part of the command, do not type it.

# GitLab and git set-up

* If you never used git on your desktop or laptop, configure your name and email:

    ```bash
    [doe] git config --global user.name "John Doe"
    [doe] git config --global user.email johndoe@example.com
    ```
* Clone the project on your desktop or laptop:

    ```bash
    [doe] cd some/where
    [doe:some/where] git clone git@gitlab.eurecom.fr:renaud.pacalet/ds.git
    ```
   Note: if you did not add your SSH key to your GitLab account, you will be asked a password.
Abort and add your SSH key.
* The master branch is protected and will be used to provide instructions for the labs, code templates, documentation...
Never work in the master branch.
Create your personal branch instead.
Name it `Firstname.Lastname` where `Firstname` is your first name (or a part of it) and `Lastname` is your last name (or a part of it); please do not use pseudos or other fancy names, it is important that a branch owner is easily identified from the branch name.
Switch to your personal branch, push it to the `origin` remote and declare that the local branch will track the remote one, such that you will not have to specify the remote any more when pushing or pulling:

    ```bash
    [doe:some/where] cd ds
    [doe:some/where/ds] git branch John.Doe
    [doe:some/where/ds] git checkout John.Doe
    [doe:some/where/ds] git push origin John.Doe
    [doe:some/where/ds] git branch --set-upstream-to=origin/John.Doe John.Doe
    ```
* Remember that you will work in your personal branch.
You can check that you are on the correct branch with the `git branch` command.
* From time to time, when new material will be added to it, you will be asked to merge the master branch in your personal branch.
First fetch the remote changes and merge the master branch into your own branch:

    ```bash
    [doe:some/where/ds] git fetch
    [doe:some/where/ds] git merge origin/master
    ```
* Last but not least, do not forget to add, commit and push your own work in your personal branch.
As you declared that your personal local branch tracks the remote one, there is no need to redeclare it; simply `git push` or `git pull`.

# Tools

The course makes use of two types of tools: a VHDL simulator and a VHDL synthesizer.
The VHDL simulator allows to exercise your VHDL code, find bugs and fix them.
The VHDL synthesizer translates your VHDL code into a binary bitsream that you then use to reconfigure the FPGA circuit of the prototyping board.

If you want or must work on your own personal computer you will need to get access to these tools.
We will first look at commercial (but free) tools.
At the end of this chapter you will find some notes about free and open source alternatives.

## The VHDL synthesizer

The VHDL synthesizer we must use is constrained by the FPGA circuit that equips our prototyping board: it is a Zynq core from [Xilinx] so we must use the [Vivado] tool from Xilinx.
The most recent versions of this tool are extremely heavy (tens of gigabytes, hours or days of download).
If you absolutely want to install Vivado on your own computer (not recommended) see [below](#installing-vivado-webpack).
And of course, if you have it already installed, you can use it.

Else, Vivado is already installed on the GNU/Linux computers in the EURECOM's lab rooms.
As we do not need a Graphical User Interface the best option is thus to work on a EURECOM's computer through an `ssh` connection.
If you do not have one yet, install an `ssh` client.
Use your `ssh` client to connect to a GNU/Linux computer at EURECOM and to download the synthesis results on your laptop.

## The VHDL simulator

Different from the synthesizer the simulator can be any VHDL simulator that you can find.
And different from synthesis, for simulation a GUI really makes a difference when debugging.
And using a simulator's GUI through `ssh`, while not always impossible, is far from convenient.

If you have a VHDL simulator already (there is one in Vivado), you can use it.
Else I recommend Modelsim from [Siemens].
Intel offers the ModelSim-Intel FPGA Starter Edition Software ([see below](#installing-modelsim-intel-fpga-starter-edition-software)) free of charge.
Please do not wait the last moment to install it, it takes some time to download (you will have to download a bit more than 1GB).
Even if you also have Vivado, if you can also install Modelsim, prefer Modelsim for simulation, it is superior (full VHDL 2008 support, faster...).

The free and open source [GHDL]+[GTKWave] solution is another option.
Binaries are available for GNU/Linux, Windows and macOS and they can also be compiled from the sources.
This solution is a bit less user-friendly than Modelsim for debugging (no step-by-step, no breakpoints, etc.) but it is perfectly usable for our needs.

## Installing Vivado WebPack

Xilinx offers a free of charge version of its Vivado design suite for Windows or GNU/Linux, named the WebPack edition.
It has some limitations but they should not be a real problem for this course.
You can try to install it on your laptop but be warned:

- It is huge (about 30GB for version 2019.2) which means that downloading and installing will take time and that it will use a significant part of your disk space.
- There are Windows and GNU/Linux versions but no macOS version.
If it is your OS the best option is probably to install Vivado in a GNU/Linux virtual machine.
- It is very picky about the OS versions.
If your Windows or GNU/Linux OS is not one of the officially supported ones you will have to workaround several problems.
It can even be that it does not work at all.

If you install Vivado on your own laptop do not forget:

- To protect the installation from accidental removal or modification.
- To install the Zybo board description files from Digilent:

    ```bash
    $ cd ds
    $ cp -r zybo /path/to/Vivado/2019.2/data/boards/board_files
    ```

### Troubleshooting

On certain GNU/Linux distributions that are not officially supported by Xilinx you may encounter errors when running the `xelab` command of the simulation suite:

```bash
$ xelab foo
...
ERROR: [XSIM 43-3409] Failed to compile generated C file xsim.dir/work.foo/obj/xsim_1.c.
ERROR: [XSIM 43-3915] Encountered a fatal error. Cannot continue. Exiting...
```

If it happens first run `xelab` again with the `-mt off -v 2` options in order to get a more verbose error message:

```bash
$ xelab -mt off -v 2 foo
...
/opt/Xilinx/Vivado/.../clang: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory
ERROR: [XSIM 43-3409] Failed to compile generated C file xsim.dir/work.foo/obj/xsim_1.c.
ERROR: [XSIM 43-3915] Encountered a fatal error. Cannot continue. Exiting...
```

Search for the missing library in your Vivado installation:

```bash
$ find /opt/Xilinx/Vivado -name libncurses.so.5
/opt/Xilinx/Vivado/2019.2/lnx64/tools/gdb_v7_2/libncurses.so.5
```

Search for similar libraries in your system directories:

```bash
$ find /usr -name libncurses.so.*
/usr/lib/x86_64-linux-gnu/libncurses.so.6
/usr/lib/x86_64-linux-gnu/libncurses.so.6.1
```

And create a symbolic link in the right system directory:

```bash
$ sudo ln -s /opt/Xilinx/Vivado/2019.2/lnx64/tools/gdb_v7_2/libncurses.so.5 /usr/lib/x86_64-linux-gnu
```

## Installing Modelsim-Intel FPGA starter edition software

Under GNU/Linux or Windows install the ModelSim-Intel FPGA Starter Edition Software **lite** version for your OS.
Under macOS install a GNU/Linux virtual machine (for instance with VirtualBox) and install the ModelSim-Intel FPGA Starter Edition Software **lite** version for Linux inside the virtual machine.
The ModelSim-Intel FPGA Starter Edition Software **lite** version has several limitations compared to the regular version but they should not be a problem for this course.

Important:
- As the archive to download is quite large, before downloading it double-check that you really download the **ModelSim-Intel FPGA Starter Edition Software** (not Quartus or any other tool), that it is the **lite** version and that it is for **your operating system** (Linux or Windows).
- After installation do not forget to protect the installation from accidental removal or modification.
- The GNU/Linux version is a 32 bits version so, as your GNU/Linux OS is very likely 64 bits, you will need to install the 32 bits version of several software libraries.
The following has been tested on Debian Buster and should also work under recent Ubuntu distributions:

```bash
[doe] sudo dpkg --add-architecture i386
[doe] sudo apt-get update
[doe] sudo apt-get install libxext6:i386 libxft2:i386 libstdc++6:i386
```

1. Download the installer using the [direct link for Linux] or the [direct link for Windows].
1. If the direct link does not work:
   * Visit the [ModelSim-Intel FPGA Starter Edition Software] download page.
   * Select the **Lite** edition (not Pro or Standard)
   * Select the latest version (**20.1.1** at the time of writing).
   * Select your operating system (Windows or Linux).
   * In the **Individual Files** tab download the **ModelSim-Intel FPGA Edition (includes Starter Edition)**.

Be patient, the file is quite large.
Once it is downloaded double-click on the file's icon (Windows) or run the installer (Linux):

```bash
[doe] chmod +x ModelSimSetup-xxx-linux.run
[doe] ./ModelSimSetup-xxx-linux.run
```

Select the _Modelsim - Intel FPGA Starter Edition_ and follow the instructions.
Once the installation is finished protect the installation from accidental removal or modification.
Example under GNU/Linux (replace `/some/where` by your own install path):

```bash
[doe] chmod -r a+rX-w /some/where
```

Finally, still under GNU/Linux, add the directory containing the installed executables to your `PATH` environment variable:

```bash
$ export PATH=$PATH:/some/where/modelsim_ase/bin
```

For a permanent `PATH` definition add the same command to your shell initialization file (e.g. `~/.bashrc`):

```bash
$ echo 'export PATH=$PATH:/some/where/modelsim_ase/bin' >> ~/.bashrc
```

The tools should now work.

### Troubleshooting

At the beginning of simulations you will maybe see warnings like these:

```
# ** Warning: (vsim-3116) Problem reading symbols from /lib/i386-linux-gnu/librt.so.1 : module was loaded at an absolute address.
# ** Warning: (vsim-3116) Problem reading symbols from /lib/i386-linux-gnu/libdl.so.2 : module was loaded at an absolute address.
# ** Warning: (vsim-3116) Problem reading symbols from /lib/i386-linux-gnu/libm.so.6 : module was loaded at an absolute address.
# ** Warning: (vsim-3116) Problem reading symbols from /lib/i386-linux-gnu/libpthread.so.0 : module was loaded at an absolute address.
# ** Warning: (vsim-3116) Problem reading symbols from /lib/i386-linux-gnu/libc.so.6 : module was loaded at an absolute address.
# ** Warning: (vsim-3116) Problem reading symbols from /lib/ld-linux.so.2 : module was loaded at an absolute address.
# ** Warning: (vsim-3116) Problem reading symbols from /lib/i386-linux-gnu/libnss_files.so.2 : module was loaded at an absolute address.
```

They are apparently harmless.
If you prefer suppressing them completely edit the `/some/where/modelsim_ase/modelsim.ini` configuration file and add the following lines at the beginning of the file:

```
[msg_system]
suppress = 3116
```

## Free and open source hardware design tools

A very interesting post (in French) about free and open source hardware design tools in 2020: <https://linuxfr.org/news/la-liberation-des-fpga-et-des-asic-bien-engagee-pour-2020>.

### VHDL simulation

[GHDL] is probably the most mature free and open source VHDL simulator.
It comes in three different flavours depending on the backend used: `gcc`, `llvm` or `mcode`.
It runs under Windows, GNU/Linux and macOS.
It has no graphical user interface but waveforms can be displayed using [GTKWave].

### VHDL synthesis

There are free and open source synthesizers ([Yosys], [Icarus]) but, up to now, their native front-ends are only for the Verilog hardware description language, not VHDL.
However, there is an experimental VHDL synthesis feature in GHDL based on Yosys.

[Examining synthesis results]: doc/data/examining-synthesis-results.md
[GHDL]: https://ghdl.github.io/ghdl/about.html
[GTKWave]: https://sourceforge.net/projects/gtkwave/
[ModelSim-Intel FPGA Starter Edition Software]: https://fpgasoftware.intel.com/?edition=lite&product=modelsim_ae
[direct link for Linux]: https://download.altera.com/akdlm/software/acdsinst/20.1std.1/720/ib_installers/ModelSimSetup-20.1.1.720-linux.run
[direct link for Windows]: https://download.altera.com/akdlm/software/acdsinst/20.1std.1/720/ib_installers/ModelSimSetup-20.1.1.720-windows.exe
[Siemens]: https://eda.sw.siemens.com/
[Yosys]: https://yosyshq.net/yosys/
[ghdl-yosys-plugin]: https://github.com/ghdl/ghdl-yosys-plugin
[Icarus]: http://iverilog.icarus.com/
[Xilinx]: https://www.xilinx.com/
[Vivado]: https://www.xilinx.com/support/download.html
[bootlin]: https://bootlin.com/
[memento of the most useful GNU/Linux commands]: https://bootlin.com/doc/legacy/command-line/command_memento.pdf
[ProGit book]: doc/data/ProGitScottChacon.pdf
[Daring Fireball]: https://daringfireball.net/projects/markdown/syntax
[Markdown tutorial]: http://www.markdowntutorial.com/
[Free Range Factory]: doc/data/free_range_vhdl.pdf
[Getting started with VHDL]: doc/data/getting-started-with-vhdl.md
[Digital hardware design using VHDL in a nutshell]: doc/data/digital-hardware-design-using-vhdl-in-a-nutshell.md
[VHDL simulation]: doc/data/vhdl-simulation.md
[Comments]: doc/data/comments.md
[Identifiers]: doc/data/identifiers.md
[Wait]: doc/data/wait.md
[D-flip-flops (DFF) and latches]: doc/data/d-flip-flops-dff-and-latches.md
[Initial values declarations]: doc/data/initial-values.md
[Generic parameters]: doc/data/generics.md
[Aggregate notations]: doc/data/aggregate-notations.md
[Resolution functions, unresolved and resolved types]: doc/data/resolution-functions-unresolved-and-resolved-types.md
[Arithmetic: which types to use?]: doc/data/arithmetic-which-types-to-use.md
[Entity instantiations]: doc/data/entity-instantiations.md
[Unconstrained types]: doc/data/unconstrained-types.md
[Recursivity]: doc/data/recursivity.md
[Protected types]: doc/data/protected-types.md
[Random numbers generation]: doc/data/random-numbers-generation.md
[DHT11 sensor datasheet]: doc/data/DHT11.pdf
[first intermediate status check-list]: status1.md
[second intermediate status check-list]: status2.md
[third intermediate status check-list]: status3.md
[AXI4 lite protocol specification]: doc/data/axi.pdf

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
