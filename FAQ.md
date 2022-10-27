<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

Frequently asked questions

---

- [Tools (GHDL, GTKWave, Modelsim, Vivado)](#tools--ghdl--gtkwave--modelsim--vivado-)
  * [How can I install GHDL and GTKWave under macOS, and use them to simulate my VHDL model?](#how-can-i-install-ghdl-and-gtkwave-under-macos--and-use-them-to-simulate-my-vhdl-model-)
  * [I am not comfortable with the Command Line Interface (CLI), is there a way to compile and simulate with a Graphical User Interface (GUI)?](#i-am-not-comfortable-with-the-command-line-interface--cli---is-there-a-way-to-compile-and-simulate-with-a-graphical-user-interface--gui--)
  * [When trying to compile/simulate/synthesize I get a `command not found` error, why?](#when-trying-to-compile-simulate-synthesize-i-get-a--command-not-found--error--why-)
  * [Why do I get `CRITICAL WARNING: [IP_Flow 19-5655]` when synthesizing my design with Vivado?](#why-do-i-get--critical-warning---ip-flow-19-5655---when-synthesizing-my-design-with-vivado-)
  * [Why do I get `ERROR: [DRC UCIO-1] Unconstrained Logical Port` when synthesizing my design with Vivado?](#why-do-i-get--error---drc-ucio-1--unconstrained-logical-port--when-synthesizing-my-design-with-vivado-)
  * [Why do I get `ERROR: [DRC NSTD-1] Unspecified I/O Standard` when synthesizing my design with Vivado?](#why-do-i-get--error---drc-nstd-1--unspecified-i-o-standard--when-synthesizing-my-design-with-vivado-)
- [How to generate a `ssh` key pair?](#how-to-generate-a--ssh--key-pair-)
- [The `git` server asks for a password, how can I avoid this?](#the--git--server-asks-for-a-password--how-can-i-avoid-this-)
- [The VHDL language](#the-vhdl-language)
  * [I got a compilation error about wait statement and sensitivity list, what does it mean?](#i-got-a-compilation-error-about-wait-statement-and-sensitivity-list--what-does-it-mean-)
- [Terminal emulators](#terminal-emulators)
  * [What is a terminal emulator?](#what-is-a-terminal-emulator-)
  * [What terminal emulator can I use?](#what-terminal-emulator-can-i-use-)
  * [How can I know which logical device on my computer corresponds to the Zybo board?](#how-can-i-know-which-logical-device-on-my-computer-corresponds-to-the-zybo-board-)
  * [How can I attach the terminal emulator to the logical device of the Zybo board?](#how-can-i-attach-the-terminal-emulator-to-the-logical-device-of-the-zybo-board-)
- [The DHT11 sensor](#the-dht11-sensor)
  * [I saw an Arduino software library for the DHT11 sensor, does it mean that Arduino boards have a hardware interface like the one we designed?](#i-saw-an-arduino-software-library-for-the-dht11-sensor--does-it-mean-that-arduino-boards-have-a-hardware-interface-like-the-one-we-designed-)

---

# Tools (GHDL, GTKWave, Modelsim, Vivado)

## How can I install GHDL and GTKWave under macOS, and use them to simulate my VHDL model?

[This video](https://mediaserver.eurecom.fr/permalink/v126193e12950nece4k3/) explains all this.

## I am not comfortable with the Command Line Interface (CLI), is there a way to compile and simulate with a Graphical User Interface (GUI)?

GHDL has no GUI.
But Modelsim and Vivado have GUIs; these videos explains how to work with them:

- [Modelsim](https://mediaserver.eurecom.fr/permalink/v125f4143c20fzptvtz8/).
- [Vivado](https://mediaserver.eurecom.fr/permalink/v125f414460cccr4hu2e/).

Note, however, that GUIs tend to significantly slow down the work flow.
If you are not comfortable with the CLI it is probably time to start learning it.

## When trying to compile/simulate/synthesize I get a `command not found` error, why?

One first possible reason is that the tools are not installed on the computer.
For instance, if you connected to `ssh.eurecom.fr` from remote, you connected to the EURECOM gateway (also named `everest` or `alpes`).
These gateways are not for development, no development tools are installed on them.
You must bounce to one of the GNU/Linux desktop computers of lab room 52 (`eurecom1`, `eurecom2`, ..., `eurecom22`).
You can check to which computer you are currently connected with the `hostname` command.
You can verify if the tools are installed by listing the content of the directory in which they are supposed to be:

```bash
$ ls /packages/LabSoC/ghdl/bin
$ ls /packages/LabSoC/Mentor/Modelsim/bin
$ ls /packages/LabSoC/Xilinx/bin
```

Note: do not rely on your shell's autocompletion (e.g., `ls /packages/LabS<tab>`) to conclude that a directory is not there; they are auto-mounted and the completion can fail just because the automounter did not mount the NFS share yet.

Another possible reason is that you forgot to tell your shell where to find the command.
Your shell uses an environment variable named `PATH` that lists all directories in which commands are searched for, separated with colons (`:`).
If the tool you want to use is in `/opt/MyTool/bin`, and this directory is not already in your `PATH`, you must add it:

```bash
$ export PATH=$PATH:/opt/MyTool/bin
```

Be careful when typing these commands because if you get it wrong it could be that your shell does not find any command any more.
If it happens, just launch a new shell.
If you are working on one of the EURECOM's GNU/Linux computers use the following paths:

* GHDL (simulation): `/packages/LabSoC/ghdl/bin`
* Modelsim (simulation): `/packages/LabSoC/Mentor/Modelsim/bin`
* Vivado (simulation and synthesis): `/packages/LabSoC/Xilinx/bin`

To check the current value of your `PATH`:

```bash
$ printenv PATH
```

Note: you must run these `export` commands in each new interactive shell you launch and from which you want to run the simulation and/or synthesis tools.
But you can also make these definitions permanent by adding them at the end of your shell configuration file located at the root of your home directory: `~/.bashrc`, `~/.bashrc+` (EURECOM GNU/Linux computers only), `~/.bash_profile`, `~/.profile`...
Note that, depending on which one you use this will take effect only the next time you will launch a new shell or even the next time you log in.

## Why do I get `CRITICAL WARNING: [IP_Flow 19-5655]` when synthesizing my design with Vivado?

This warning can be safely ignored.
It just says that Vivado does not support yet the full VHDL 2008 standard that we use.
This should not be a real problem for this course.

## Why do I get `ERROR: [DRC UCIO-1] Unconstrained Logical Port` when synthesizing my design with Vivado?

You left some top-level input-outputs unspecified, Vivado does not know to which I/O pins of the Zynq core they should be routed.
Edit your `xxx.params.tcl` synthesis script and add all missing specifications to the `ios` array.
Example:

```tcl
array set ios {
	led[0]        { M14 LVCMOS33 }
	...
```

## Why do I get `ERROR: [DRC NSTD-1] Unspecified I/O Standard` when synthesizing my design with Vivado?

You left the signalling voltage and/or standard of some top-level input-outputs unspecified, Vivado does not know how to configure the corresponding I/O pins of the Zynq core.
Edit your `xxx.params.tcl` synthesis script and add all missing specifications to the `ios` array.
Example:

```tcl
array set ios {
	led[0]        { M14 LVCMOS33 }
	...
```

# How to generate a `ssh` key pair?

`ssh-keygen` is the command that generates `ssh` key pairs.
For this course I suggest that you generate a dedicated key pair and don't protect it with a passphrase; what we do is not critical and skipping the passphrase will significantly smooth your workflow (just type enter when asked twice for a passphrase):

```bash
john@mylaptop> ssh-keygen -t rsa -f ~/.ssh/gitlab
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/john/.ssh/gitlab
Your public key has been saved in /home/john/.ssh/gitlab.pub
The key fingerprint is:
SHA256:mP97zcv0/0FNzObUHVvnW8gQrP+4abvgWlurJUTq5/s john@mylaptop
The key's randomart image is:
+---[RSA 3072]----+
|           .o. .o|
|            .o =B|
|          ..  o.@|
|       o o.    =+|
|      o S ..   oo|
|       o .  . .  |
|        o = o=.. |
|         * *+=+..|
|        ..OBE+o.*|
+----[SHA256]-----+
```

Your public key is in `~/.ssh/gitlab.pub` and your private key is in `~/.ssh/gitlab`.
Of course, as the names indicate, you can (and must) disclose the former but you must keep the latter secret.
This is why `ssh` complains if your private key files have too open access permissions.

The next step consists in adding the public part to your GitLab account.
Copy the **content** of `~/.ssh/gitlab.pub` to the clipboard, visit [the User Settings / SSH Keys section of your GitLab account](https://gitlab.eurecom.fr/-/profile/keys), paste the public key and click on the `Add Key` button.

Finally, tell your local `ssh` client that this key pair shall be used to authenticate against `gitlab.eurecom.fr`.
Edit or create `~/.ssh/config` and add these two lines:

```
Host gitlab.eurecom.fr
    IdentityFile ~/.ssh/gitlab
```

Normally, you should never be asked again for a password when pulling, fetching or pushing to the git repository.

# The `git` server asks for a password, how can I avoid this?

If you are asked for a password when trying to access the remote repository (`git clone`, `git fetch`, `git pull`, `git push`...) there are several possible reasons:

1. You cloned the repository using the `https` protocol (https://gitlab.eurecom.fr/renaud.pacalet/ds.git) and your OS does not provide a `git` credential manager to handle the password for you.
Check the protocol:

   ```bash
   john@mylaptop> cd ds
   john@mylaptop> git remote -v
   origin   https://gitlab.eurecom.fr/renaud.pacalet/ds.git (fetch)
   origin   https://gitlab.eurecom.fr/renaud.pacalet/ds.git (push)
   ```

   If it is `https`, either set up a `git` credential manager or change the protocol for `ssh`:

   ```bash
   john@mylaptop> git remote set-url origin git@gitlab.eurecom.fr:renaud.pacalet/ds.git
   john@mylaptop> git remote -v
   origin   git@gitlab.eurecom.fr:renaud.pacalet/ds.git (fetch)
   origin   git@gitlab.eurecom.fr:renaud.pacalet/ds.git (push)
   ```

1. You use the `ssh` protocol but you did not add your `ssh` public key to your GitLab account.
Log in to the GitLab server (https://gitlab.eurecom.fr/), visit the [_SSH Keys_ section of your _User Settings_](https://gitlab.eurecom.fr/-/profile/keys) and add your public key.
If you do not have a `ssh` key yet generate one (see _How to generate a ssh key pair?_).

1. You do not have a `ssh` agent running or your shell does not know about it.
Check:

    ```bash
    john@mylaptop> ssh-add -l
    Could not open a connection to your authentication agent.
    ```
   If you really do not have a `ssh` agent launch one:

    ```bash
    john@mylaptop> eval $(ssh-agent -s)
    ```

1. You did not add your private key to your `ssh` agent.
Do it:

    ```bash
    john@mylaptop> ssh-add               # if your ssh private key file is one of the default
    john@mylaptop> ssh-add ~/.ssh/gitlab # else
    ```

   > Note: if your private key is protected you will have to enter your pass phrase to unlock it.

# The VHDL language

## I got a compilation error about wait statement and sensitivity list, what does it mean?

If you get an error like:

- Modelsim: `(vcom-1226) A wait statement is illegal for a process with a sensitivity list`
- GHDL: `error: wait statement not allowed in a sensitized process`
- Vivado: `ERROR: [VRFC 10-1281] process cannot have both a wait statement and a sensitivity list`

the reason is that you used a `wait` statement in a process with a sensitivity list.
Example:

```vhdl
process(a, b)
begin
  wait on a, b;
  s <= a xor b;
end process;
```

This is not valid because a sensitivity list ((`(a, b)` in the example) is itself a short-hand for a **unique** `wait` statement at the end of the process.
This valid process with a sensitivity list and no `wait` statement:

```vhdl
process(a, b)
begin
  s <= a xor b;
end process;
```

is equivalent to this other valid process with a `wait` statement and no sensitivity list:

```vhdl
process
begin
  s <= a xor b;
  wait on a, b;
end process;
```

In summary, use a sensitivity list or `wait` statements but not both in the same process.

Note: because most logic synthesizers have a limited support for wait statements, we usually use only sensitivity lists in synthesizable VHDL models, while a mixture of processes with wait statements and processes with sensitivity lists are frequently used in non-synthesizable models, like simulation environments.

# Terminal emulators

## What is a terminal emulator?

The USB link between our computer and the Zybo board is used to power the Zybo but it can also be used to communicate with the operating system that runs on the ARM processor of the Zynq core.
In order to do this, if you do not have one already, you need to install a serial communication program on your computer, also frequently referred to as a _terminal emulator_.

## What terminal emulator can I use?

Under GNU/Linux and macOS `picocom` is a good option.
It is available from most GNU/Linux package managers and from MacPorts or Homebrew for macOS.
If you are under Windows, Digilent (manufacturer of the Zybo) has a [web page dedicated to installing and using the `Tera Term` terminal emulator under Windows](https://reference.digilentinc.com/learn/programmable-logic/tutorials/tera-term).

## How can I know which logical device on my computer corresponds to the Zybo board?

On EURECOM GNU/Linux computers a `udev` rule takes care of this: as soon as you connect a Zybo board and power up a `/dev/zyboUSB` symbolic link is created; use it.
Else, continue reading.

Under most operating systems many hardware components of the computer and also external peripherals connected to the computer are represented by one or several _logical devices_ (a single component or peripheral can have several interfaces, thus several logical devices).
Under GNU/Linux and macOS the logical devices are special files found in `/dev`.
Communicating with a component or a peripheral mostly consists in reading or writing its device files.
Under Window things are a bit different but the same concept of logical device applies.

Once you have a terminal emulator installed you need to know which logical devices on your computer corresponds to the Zybo.
If you power up the Zybo the logical devices should show up on your computer.

Under macOS it should be something like `/dev/cu.usbserial-210279A42E221`.
Under GNU/Linux it should be something like `/dev/ttyUSB1`.
Be careful, there are two device files with very similar names, one for the JTAG and one for the serial link.
If you pick the wrong one and nothing happens when you try to connect, try the other one.

Under Windows use the _Device Manager_ or the Graphical User Interface of your terminal emulator to explore and test the available devices.

## How can I attach the terminal emulator to the logical device of the Zybo board?

Once you found which logical device to use, launch your serial communication program (e.g. `picocom`) and attach it to the device.
Example under macOS with `picocom` if the device is `/dev/cu.usbserial-210279A42E221`:

```bash
$ picocom -b115200 /dev/cu.usbserial-210279A42E221
...
Welcome to DS (c) Telecom Paris
ds login: root
root@ds>
```

Note: the `-b115200` option of `picocom` specifies which baud rate to use (115200 symbols/s in our case).
There are other options that can be tuned but for our needs their default values should be OK.

Example under GNU/Linux with `picocom` if the device is `/dev/ttyUSB1`:

```bash
$ picocom -b115200 /dev/ttyUSB1
...
Welcome to DS (c) Telecom Paris
ds login: root
root@ds>
```

Note: under GNU/Linux if you get an error message about permissions you probably need to change the permissions of the device file which is, by default, mounted read/write for the root user only.
Example: `sudo chmod a+rw /dev/ttyUSB1`.
As the device disappears each time you disconnect the Zybo you will have to do this each time you reconnect and power up the board.
To make this permanent install a `udev` rule such that the device is always mounted with read/write permissions for all users (and in the same `udev` rule we can even create a convenient `/dev/zyboUSB` symbolic link, like on EURECOM computers):

   ```bash
   $ cat <<! > /tmp/51-usb2uartFT2232H.rules
   # USB2UART FT2232H
   ACTION=="add" \
   , ATTRS{interface}=="Digilent Adept USB Device" \
   , MODE="0666"
   ACTION=="add" \
   , ATTRS{interface}=="Digilent Adept USB Device" \
   , ATTRS{bInterfaceNumber}=="01" \
   , SYMLINK+="zyboUSB"
   !
   $ sudo cp /tmp/51-usb2uartFT2232H.rules /etc/udev/rules.d
   $ sudo udevadm control --reload-rules
   $ sudo udevadm trigger
   ```

# The DHT11 sensor

## I saw an Arduino software library for the DHT11 sensor, does it mean that Arduino boards have a hardware interface like the one we designed?

No, Arduino boards have a much simpler generic interface.
From the software we can read and write at specific addresses corresponding to the I/O pins of the board.
So the software library implements in software what we designed in hardware.
It reads and writes the I/O pin on which you plug the sensor and makes use of the internal timers of the Arduino chip to measure the time intervals between value changes.
If you study the source code of this library (recommended) you will probably recognize things that you are now familiar with.
This is the magic of microcontrollers (the Arduino chip is a microcontroller): they are not very powerful but they have plenty of I/Os, easily accessible from the software, plus timers and other useful components.
As long as performance is not an issue (and, in our case, there are no performance issues) they can be used to quickly design interfaces with many kinds of peripherals.

Note that the Zynq core of our Zybo board embeds an ARM processor with internal timers.
We could have used the same approach as the Arduino: design a very simple hardware interface to access the I/O pin of the Pmod connector with simple read/write operations from the software running on the ARM processor, and implement the complete protocol in software.
This software would be very similar to the one for Arduino.
But using a dual core ARM Cortex A9 processor running at 667 MHz just for this would be a bit overkill...

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
