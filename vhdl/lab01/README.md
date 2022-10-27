<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE

Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

Lab: get a Zybo board, learn about digital hardware, design a continuity tester

---

[TOC]

---

# Get a Zybo prototyping board

Once you received a Zybo kit, open a terminal, change from current directory to the clone of the git repository and check that you are really on your own personal branch:

```bash
$ git branch
* John.Doe
```

Use your favourite editor to edit the [zybo.md](/zybo.md) file:

```bash
$ vim zybo.md
```

Indicate on the first line the ID of your Zybo kit (the number on the blue case and on the sticker on the Zybo board):

```
Zybo board number: XX
...
```

For each item on the list check that it is present in your kit and corresponds to the description.
If yes replace the space between the square brackets by a `x` character.
Example: if there is a blue case **and** it contains a protection foam block:

```
* [x] one blue case with protection foam block
```

Add-commit-push the modified `zybo.md` file:

```bash
$ git add zybo.md
$ git commit -m 'Edited zybo.md'
$ git push
```

Visit the web page of the GitLab project (<https://gitlab.eurecom.fr/renaud.pacalet/ds/>), select your own branch and then click on the `zybo.md` file to see how this markdown file is rendered by the GitLab rendering engine.
Check that the Zybo ID is the correct one and that all items are properly marked.

# Introduction to digital hardware, FPGAs, VHDL (discussion)

- Introduction to digital hardware
- Field Programmable Gate Arrays (FPGAs)
- Learn a bit of the VHDL language:
  * Simulation vs. synthesis
  * Entities (section 3.1 of [Free Range Factory] book and [Digital hardware design using VHDL in a nutshell] part of the documentation)
  * Architectures (section 3.3 of [Free Range Factory] book and [Digital hardware design using VHDL in a nutshell] part of the documentation)
  * Concurrent signal assignments (section 4.3 of [Free Range Factory] book)
  * The `bit` type (a standard VHDL type with only two values: `'0'` and `'1'`; these values are not integers, do not forget the simple quotes)
  * The `bit_vector` type (another standard VHDL type which is an unconstrained one-dimension array of `bit` elements)
  * The `not` operator (if `A` is of type `bit`, `not A` evaluates as the inverse of `A`)

# Environment set-up for VHDL compilation and simulation

Your shell uses an environment variable named `PATH` that lists all directories in which commands are searched for, separated with colons (`:`).
If the tool you want to use is in `/opt/MyTool/bin`, and this directory is not already in your `PATH`, you must add it:

```bash
$ export PATH=$PATH:/opt/MyTool/bin
```

Be careful when typing these commands because if you get it wrong it could be that your shell does not find any command any more.
If it happens, just launch a new shell.
If you are working on one of the EURECOM's GNU/Linux computers you can use any of 3 different VHDL compilers/simulators: GHDL with the GTKWave waveform viewer (free and open source), Modelsim by Siemens, Vivado by Xilinx.
If you don't have any specific reason to chose one or the other prefer Modelsim, it is fast, has the best support of the VHDL standard, and offers the most powerful debugging features.
Else, prefer GHDL (and GTKWave); Vivado has the worst support of the VHDL standard and it is slow.
Their respective paths are:

* GHDL (simulation): `/packages/LabSoC/ghdl/bin`
* GTKWave (waveform viewer companion for GHDL): normally it is already installed in a standard location, no need to specify where it is; if you get an error when typing `gtkwave`, please inform the advisor
* Modelsim (simulation): `/packages/LabSoC/Mentor/Modelsim/bin`
* Vivado (simulation and synthesis): `/packages/LabSoC/Xilinx/bin`

To check the current value of your `PATH`:

```bash
$ printenv PATH
```

Note: you must run these `export` commands in each new interactive shell you launch and from which you want to run the simulation and/or synthesis tools.
But you can also make these definitions permanent by adding them at the end of your shell configuration file located at the root of your home directory: `~/.bashrc`, `~/.bashrc+` (EURECOM GNU/Linux computers only), `~/.bash_profile`, `~/.profile`...
Note that, depending on which one you use this will take effect only the next time you will launch a new shell or even the next time you log in.

## Using shell variables to simplify the typing

In order to simplify the typing of the various commands, we will use shell variables to store the absolute paths of directories.
First define a `ds` shell variable pointing to the clone of the `ds` repository:

```bash
$ ds=~/some/where/ds
$ ls $ds/zybo.md
```

## Simulating out of source tree

It is always better to compile and simulate out of the source tree.
This avoid polluting the source tree with temporary files generated by the tools.
It also reduces the risk of committing generated files and polluting the git repository.
Moreover, the generated temporary files can be huge; if you have a disk quota storing them out of your user account will limit the risk of exceeding it.

Create a temporary working directory from which we will simulate.
Assign its absolute path to another shell variable.
Example of set-up (adapt the suggested path to your own preferences):

```bash
$ sim=/tmp/$USER/ds/sim
$ mkdir -p $sim
```

Then, if you never simulated with GHDL, Modelsim or Vivado, it is time to read the [VHDL simulation] chapter of the documentation.

# Write our first VHDL model: a continuity tester for our jumper wires

The small wires that we will use to connect the DHT11 sensor to the Zybo are cheap and not 100% reliable.
This very simple exercise uses the Zybo to test the wires, as we would do with a multimeter.
The continuity tester we will design is represented on the following figure:

[![The continuity tester][1]][1]

## Interface

Edit the `$ds/vhdl/lab01/ct.vhd` file and code an entity named `ct` (for Continuity Tester) with the following input-output ports:

| Name       | Type                     | Direction | Description                                                 |
| :----      | :----                    | :----     | :----                                                       |
| `switch0`  | `bit`                    | in        | Wired to `SW0`, the rightmost user slide-switch of the Zybo |
| `wire_in`  | `bit`                    | in        | Wired to pin number 1 of the `JE` Pmod connector            |
| `wire_out` | `bit`                    | out       | Wired to pin number 2 of the `JE` Pmod connector            |
| `led`      | `bit_vector(3 downto 0)` | out       | Wired to the 4 user LEDs                                    |

## Architecture

In the same VHDL source file add a fully combinatorial architecture of `ct`, named `rtl`, that:

* sends the constant value `'1'` to `led(0)`,
* sends the constant value `'0'` to `led(1)`,
* sends the `wire_in` input to `led(2)`,
* sends the inverse of `wire_in` input to `led(3)`.
* sends the `switch0` input to the `wire_out` output,

Use 5 concurrent signal assignments.

## Compilation

Note: if you get a `command not found` error when trying to compile/simulate/synthesize, have a look at the [FAQ](/FAQ.md).

Check that your design compiles with GHDL, Modelsim or Vivado:

```bash
$ cd $sim
$ ghdl -a --std=08 $ds/vhdl/lab01/ct.vhd
```

Or:

```bash
$ cd $sim
$ vcom -2008 +acc $ds/vhdl/lab01/ct.vhd
```

Or:

```bash
$ cd $sim
$ xvhdl -2008 $ds/vhdl/lab01/ct.vhd
```

# More about Hardware Description Languages (HDL) (discussion)

- Understand the principles of event-driven simulation that underlies all Hardware Description Languages (HDL) ([Getting started with VHDL] part of the documentation)
- Signals (sections 3.4 and 10.4 of [Free Range Factory] book and [Getting started with VHDL] part of the documentation)
- Processes (section 4.6 of [Free Range Factory] book and [Getting started with VHDL] part of the documentation)
- The `wait` statement ([Getting started with VHDL] and [wait] parts of the documentation)
- The two semantics: simulation and logic synthesis.
The simulation and synthesis tools are different and they have a different _interpretation_ or _semantics_ of the VHDL code:
  * Simulation consists in exercising the VHDL model to check its functional correctness.
  * Synthesis consists in translating the VHDL model into a network of interconnected logic gates.

# Write our second VHDL model: a simulation environment for our continuity tester

We will now edit the `$ds/vhdl/lab01/ct_sim.vhd` file and code a simulation environment for `ct.rtl`.
First add a declaration of use of the `env` package of library `std`:

```vhdl
use std.env.all;
```

Add a `ct_sim` entity with no input ports and with the same output ports as `ct`.
Add a `sim` architecture of `ct_sim` with:

* two internal signal declarations for the `ct` inputs: `switch0` and `wire_in`,
* one entity instantiation of `work.ct(rtl)` named `u0` and connected to the internal signals and to the output ports,
* one single process that successively assigns all possible value combinations to the two internal signals, waits for 1 nanosecond after each assignment, replays the first combination, wait again for 1 nanosecond, and finally calls the `finish` procedure.

# Compile and simulate your design

It is time to learn how to use GHDL, Siemens Modelsim or Xilinx Vivado to compile, simulate and debug our VHDL models.
Compile and simulate your design with GHDL, Modelsim or Vivado:

```bash
$ cd $sim
$ ghdl -a --std=08 $ds/vhdl/lab01/ct_sim.vhd
$ ghdl -r --std=08 ct_sim --vcd=ct.vcd
<and use GTKWave to open the VCD file ct.vcd>
```

Or:

```bash
$ cd $sim
$ vcom -2008 +acc $ds/vhdl/lab01/ct_sim.vhd
$ vsim -voptargs="+acc" ct_sim
```

Or:

```bash
$ cd $sim
$ xvhdl -2008 $ds/vhdl/lab01/ct_sim.vhd
$ xelab -debug all ct_sim
$ xsim -gui ct_sim
```

# Automatic evaluation and peer review

Visit the [Notifications] page of the [EURECOM GitLab web site], and for the `pacalet/ds` project, select the `Custom` notification mode.
Check the `Failed pipeline` and ` Successful pipeline` options such that you will receive the results of the evaluations by email each time you push.

When you will be satisfied with the results of your simulations add-commit-push your work.
Remember that you should normally not add generated files, only the source files that you wrote.
Visit the [GitLab pipelines page](https://gitlab.eurecom.fr/renaud.pacalet/ds/pipelines) and observe the result of the automatic evaluation of your continuity tester.

Discuss your solution with your neighbours.

# Logic synthesis

We will now synthesize our design with the Vivado tool by Xilinx to map it in the programmable logic part of the Zynq core of the Zybo.

## Synthesizing out of source tree

For the very same reasons as with simulation, it is always better to synthesize out of the source tree.
Create a temporary working directory from which we will synthesize.
Assign its absolute path to another shell variable.
Example of set-up (adapt the suggested path to your own preferences):

```bash
$ syn=/tmp/$USER/ds/foo
$ mkdir -p $syn
```

Synthesis is a complex process for which there is no real default set-up.
This is why all options, parameters, the various VHDL source files, the chaining of the elementary synthesis steps, etc.
are defined in a script written in the [TCL] programming language (the language supported by many CAD tools, including Vivado, Modelsim and many others).
To synthesize according the instructions of a `$ds/vhdl/labX/foo.syn.tcl` script:

```bash
$ cd $syn
$ vivado -mode batch -source $ds/vhdl/labX/foo.syn.tcl -notrace
```

The `-notrace` option suppresses the (annoying) echo of each TCL command.

Note: when synthesizing it is always better to avoid collisions with old synthesis results by using a fresh and clean temporary working directory.
Either delete and recreate it, or, if you want to keep the previous synthesis results, create several temporary working directories with different names.

## Map the inputs and outputs of our VHDL model to input and output pins of the Zynq core

As mentioned in the interface specifications above, the `switch0` input comes form `SW0`, the rightmost user slide-switch.
`wire_in` and `wire_out` are connected respectively to pins number 1 and 2 of the `JE` Pmod connector.
The `led` output, of course, will be sent to the 4 user LEDs of the Zybo board.

The `ct.syn.tcl` and `ct.params.tcl` TCL scripts will automate the synthesis and the `boot.bif` file will tell the Xilinx tools what to do with the synthesis result.
Before you can use the synthesis scripts, you will have to edit `ct.params.tcl` and add information about the primary inputs and outputs (I/O).
For each I/O of our design we must specify:

* to which I/O pin of the Zynq core it must routed to (e.g. `G15`),
* what voltage class to use for this I/O pin - in our case it will always be `LVCMOS` (Low Voltage Complementary Metal Oxide Semiconductor),
* what voltage level to use (e.g. 3.3 volts).

All the information we need is available in the [Zybo reference manual] and in the [Zybo schematics].
You will find these two documents in the `$ds/doc/data` sub-directory.
Open these two documents.
Open the `ct.params.tcl` synthesis script with your favourite editor.
The missing information shall be provided in the definition of the `ios` array.

Let us deal with the `switch0` case, as an example:

* We want to connect this primary input of our design to `SW0`, the rightmost user slide-switch of the Zybo.
In the [Zybo reference manual], look at Figure 14, page 22/26.
You should see that the `SW0` slide switch of the Zybo is routed to the `G15` pin of the Zynq core.
* Page 10/13 of the [Zybo schematics], we see two groups (banks) of I/O pins of the Zynq core represented as yellow boxes.
The `G15` pin belongs to bank 35.
Above the top-left corner of each I/O bank we can see its operation voltage.
For bank 35 it is `VCC3V3`, for 3.3 volts.
The voltage level to use is thus 3.3 volts and the fully qualified voltage class is `LVCMOS33` (if the voltage level was 2.5 volts it would be `LVCMOS25`).

Note: on page 2/13 of the [Zybo schematics] we see that the slide switches are positioned between `GND` (for ground) and `VCC3V3` (for 3.3V power supply).
This is a confirmation that the voltage level to use is 3.3 volts.
We also see that to prevent the consequences of an accidental short circuit, the slide switches are connected to the Zynq core through a 10K ohms resistor).

Add these information (pin, voltage class and voltage level) in your personal copy of the `ct.params.tcl` synthesis script:

```tcl
array set ios {
    switch0       { G15 LVCMOS33 }
    wire_in       {}
    wire_out      {}
    led[0]        {}
    led[1]        {}
    led[2]        {}
    led[3]        {}
}
```

Do the same for the other inputs and outputs.
Remember that they will all use the `LVCMOS` voltage class.

Cross-check your findings with your neighbours.

## Synthesize the continuity tester

If the I/O mapping looks correct, synthesize:

```bash
$ cd $syn
$ vivado -mode batch -source $ds/vhdl/lab01/ct.syn.tcl -notrace
```

All log messages are printed on the standard output and stored in the `vivado.log` log file.
If there are errors during the synthesis of your design it is this `vivado.log` file that probably contains the most valuable error messages.

A resource utilization report is available in `ct.utilization.rpt`.
Open it and look at the first table of the `Slice Logic` section.
Check that you have the expected number of "_Register as Flip Flop_" (registers used as Flip Flop) and that you do not have any unwanted "_Register as Latch_".
Check also that the other resources ("_LUT as Logic_", "_LUT as Memory_", "_Block RAMs_", "_DSPs_"...) are about in line with the complexity of your design.

A timing report is available in `ct.timing.rpt`.
Open it and check that you do not have critical warnings or errors in the first sections.
Then, check that "_All user specified timing constraints are met_".
As our design is full combinatorial there is not much more to check here.

The main synthesis result is in `ct.bit`.
It is a binary file called a *bitstream* that is used by the Zynq core to configure the programmable logic.
If there were no synthesis errors or serious warnings, if the resource utilization and timing reports look OK, we must now use the `bootgen` utility to pack the bitstream with the first (`fsbl.elf`) and second (`u-boot.elf`) stage software boot loaders that can be found in the `$ds/software` sub-directory.
Copy them in your working directory:

```bash
$ cd $syn
$ cp $ds/software/fsbl.elf .
$ cp $ds/software/u-boot.elf .
```

Use the `bootgen` utility and the `$ds/vhdl/lab01/boot.bif` provided configuration script:

```bash
$ bootgen -w -image $ds/vhdl/lab01/boot.bif -o boot.bin
```

The result is a *boot image*: `boot.bin` that the Zynq core of the Zybo will use to initialize itself, including the FPGA part.

# Test your design (and your wire) on the Zybo

Mount the micro SD card on your computer and define a shell variable that points to it:

```bash
$ SDCARD=<path-to-mounted-sd-card>
```

If your micro SD card does not yet contain the software components of the DigitalSystems reference design, prepare it:

```bash
$ cd $ds/software
$ cp uImage devicetree.dtb uramdisk.image.gz $SDCARD
```

Copy the new boot image to the micro SD card:

```bash
$ cp $syn/boot.bin $SDCARD
$ sync
```

Unmount the micro SD card, eject it, plug it on the Zybo but do not power up now.
First imagine how you will test the continuity of the wire: where will you plug it and what experiments will you conduct? Cross-check with your neighbours.
Power on the Zybo and test the continuity of the wire.

# Report, add-commit-push

As soon as you are satisfied with the results, write your report in Markdown format in the `REPORT.md` file and add-commit-push your work.
Remember that you should normally not add generated file.
When looking at the rendering of your report on the GitLab web interface do not forget to point to your personal branch.

[1]: /images/ct-fig.png
[Zybo reference manual]: /doc/data/zybo_rm.pdf
[Zybo schematics]: /doc/data/zybo_sch.pdf
[Notifications]: https://gitlab.eurecom.fr/-/profile/notifications
[EURECOM GitLab web site]: https://gitlab.eurecom.fr/
[Free Range Factory]: /doc/data/free_range_vhdl.pdf
[Getting started with VHDL]: /doc/data/getting-started-with-vhdl.md
[Digital hardware design using VHDL in a nutshell]: /doc/digital-hardware-design-using-vhdl-in-a-nutshell.md
[VHDL simulation]: /doc/data/vhdl-simulation.md
[wait]: /doc/data/wait.md
[TCL]: https://www.tcl.tk/about/language.html
[FAQ]: /FAQ.md

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
