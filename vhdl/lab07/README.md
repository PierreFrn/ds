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

Lab: the DHT11 controller

---

- [Overview](#overview)
- [Learn a bit more of digital hardware design](#learn-a-bit-more-of-digital-hardware-design)
- [The one-bit communication protocol](#the-one-bit-communication-protocol)
- [Design of the DHT11 controller](#design-of-the-dht11-controller)
  * [Interface specification](#interface-specification)
  * [Detailed specifications](#detailed-specifications)
  * [Block diagram](#block-diagram)
  * [Learn a bit more of digital hardware design](#learn-a-bit-more-of-digital-hardware-design-1)
  * [State diagram](#state-diagram)
  * [VHDL coding](#vhdl-coding)
  * [Validation](#validation)
  * [Peer review](#peer-review)
  * [Synthesis](#synthesis)
  * [Test](#test)

---

# Overview

Our first serious design is not oriented towards high-performance but it is a good wrap-up for what we learned up to now.
Our goal is to attach a DHT11 temperature and humidity sensor to the Zybo board and use it to measure the current temperature and humidity level.
In order to do this we must design a hardware controller, `dht11_ctrl`, to communicate with the sensor.
It will implement the master side of the communication protocol used by the DHT11 sensor, the slave side being implemented by the sensor itself.
Our controller will periodically order the sensor to measure the temperature and the humidity level, receive the sensed data, and store them in internal registers.
It will also produce status and error signals to indicate that acquired measurements are available or that errors occurred during the acquisition.
We will map this controller in the FPGA part of the Zynq core of the Zybo such that it is connected to the `JE` Pmod connector of the board and, through it, to the sensor.

> Note: In the next lab we will interface our controller with the ARM processor of the Zynq core of the Zybo, such that we can read the last acquired temperature and humidity levels from the software stack.

![`Zybo and DHT11`](/images/zybo-and-dht11.jpg)  
*The DHT11 sensor connected to the `JE` Pmod connector of the Zybo board*

The datasheet of the DHT11 sensor is available in [`/doc/data/DHT11.pdf`](/doc/data/DHT11.pdf).
You can open it and read it if you wish, but as it is not very well written and difficult to understand you will find below a better description.

# Learn a bit more of digital hardware design

High impedance, tri-state buffers.

# The one-bit communication protocol

Sensors like the DHT11 are very low cost.
To further minimize the system integration costs, there is only one single wire between the sensor and its controller: a data line that can be driven by the sensor or by the controller.
The risk of short circuits is eliminated because the participants can only drive the line **low** or let it float.
They can never drive it **high**.
This behaviour is hard-wired in the sensor.
To guarantee the same from our controller, we will use the data line as an input port only.
Instead of driving the data line directly, our controller outputs a `force0` signal to control an external tri-state buffer located between the data line and the ground.
When the controller asserts `force0` **low**, the tri-state buffer drives the data line **low**.
Else the tri-state buffer does not drive the data line at all, it lets it float.
If none of the participants drives the data line, it is driven high by a pull-up resistor.

> Note: the DHT11 module we are using comprises the DHT11 sensor (the blue box), two connectors (we will only use the 3 pins black connector located on the bottom side) and a 10 k-Ohms pull-up resistor.
If you carefully inspect the top side of the module you should see two metal tracks, one for the data line (labelled _S_) and the other for the power supply (_V_).
They connect the sensor to the two connectors.
There is no visible metal track for the ground (_G_) because it is routed in an inner layer of the printed circuit board.
A tiny rectangular Surface Mounted Device (SMD) is soldered between the data line and the power supply.
It is the pull-up resistor.
With powerful enough magnifying glasses you could see the `103` label on it, where `10` is the significant value and `3` the power-of-ten of the multiplier, which means $`\mathbf{10}\times10^\mathbf{3}\ \Omega`$.

![`Controller and DHT11`](/images/dht11_ctrl-and-dht11-fig.png)  
*The DHT11 sensor, the controller and the tri-state buffer*

With this clock-less protocol the data exchange cannot really be based on instantaneous values of the data line: the participants would not know when to sample it.
Instead, it is the duration of the data line states that conveys information.
At any phase of the protocol each participant knows whether it is supposed to listen or to talk.
When talking, it alternates high and low states of the data line and maintains these states for a given meaningful duration.
When listening, it measures how long the data line remains in each state and deduces bits of information from this.
The following figure shows a complete acquisition using the single-wire communication protocol.
The dashed low levels are driven by `dht11_ctrl` (through its `tsb` tri-state buffer when asserting **low** its `force0` output), and the plain ones are driven by the sensor (through its own internal tri-state buffer).
All high levels are driven by the pull-up resistor.

![`DHT11 communication protocol`](/images/dht11_protocol-fig.png)  
*The single-wire communication protocol*

To guarantee a reasonable accuracy of the measurements there must be at least 1 second between the end of the reset and the first acquisition, and between consecutive acquisitions.
The `start` command is sent by our controller by forcing the data line low for at least 18 milliseconds.
The sensor responds with 42 pairs of high and low pulses of the data line.
The first pair (20 to 40 microseconds high, 80 microseconds low, numbered \#1 on the figure), and the second (80 microseconds high, 50 microseconds low, numbered \#2 on the figure) are acknowledges, they don't carry data bits.
The 40 following pairs (numbered \#3 to \#42 on the figure) correspond to the 40 data bits sent serially by the sensor, Most Significant Bit (bit \#39) first.
A pair carries a 0-bit if the high pulse lasts between 26 and 28 microseconds; it carries a 1 if the high pulse lasts 70 microseconds.
The low pulses all last 50 microseconds.
On the figure, bits \#39 and \#0 are thus 0-bits, while bit \#38 is a 1-bit.
The 40 data bits form five 8-bits fields:

| Bits   | Description                                                               |
| :----  | :----                                                                     |
| 39..32 | Relative humidity, integer part                                           |
| 31..24 | Relative humidity, fractional part, always zero with DHT11                |
| 23..16 | Temperature, integer part                                                 |
|  15..8 | Temperature, fractional part, always zero with DHT11                      |
|   7..0 | Check sum, shall be equal to the sum modulus 256 of the four other fields |

# Design of the DHT11 controller

To simplify our design and to accommodate for timing variations, we will consider that a pair carries a 0-bit if its high pulse lasts strictly less than 50 microseconds, a 1-bit if it lasts 50 microseconds or more.
We will not consider the duration of the low pulses, except the `start` command, of course.
To further simplify we will consider the two acknowledge pairs as regular data bits (a 0 followed by a 1) that we will simply discard.

## Interface specification

The entity is named `dht11_ctrl` and its architecture is named `rtl`.
Generic parameters:

| Name       | Type          | Description                                                                        | Default value |
| :----      | :----         | :----                                                                              | :---          |
| `f_mhz`    | `positive`    | master clock frequency in MHz (also clock periods per micro-second)                | 125           |
| `start_us` | `positive`    | duration of `start` command in micro-seconds                                       | 18000         |
| `warm_us`  | `positive`    | duration of warm-up delay (reset-to-first-acquisition, pause between acquisitions) | 1000000       |

Input-output ports:

| Name       | Type                            | Direction | Description                                                                                 |
| :----      | :----                           | :----     | :----                                                                                       |
| `clk`      | `std_ulogic`                    | in        | master clock, the design is synchronized on the rising edge of `clk`                        |
| `sresetn`  | `std_ulogic`                    | in        | **synchronous**, active **low** reset                                                       |
| `data_in`  | `std_ulogic`                    | in        | input data line from DHT11 sensor (wired to `JE1`, pin 1 of the `JE` Pmod connector)        |
| `force0`   | `std_ulogic`                    | out       | when **low**, force data line **low**                                                       |
| `dso`      | `std_ulogic`                    | out       | data strobe out, asserted **high** during one `clk` period at the end of an acquisition     |
| `tp`       | `std_ulogic_vector(7 downto 0)` | out       | acquired temperature, integer part only, ignored by environment when `dso` **low**          |
| `rh`       | `std_ulogic_vector(7 downto 0)` | out       | acquired relative humidity, integer part only, ignored by environment when `dso` **low**    |
| `cerr`     | `std_ulogic`                    | out       | **high** to indicate a checksum error, ignored by environment when `dso` **low**            |

## Detailed specifications

To design `dht11_ctrl` we will assemble our `sr`, `timer`, `edge` and `counter` modules and, if needed, some custom processes.
Something is missing: the brain of the controller.
We will specify and implement it as a **Mealy** Finite State Machine (FSM).

The state machine will be the brain of our controller, but as it is the most delicate piece of hardware to design we will first assume that this brain already exists and we will concentrate on the pure processing part.
It is only when we will have a clear idea of the processing part that we will be able to fully specify the state machine, its inputs, its outputs and its behaviour.

* The design is synchronized on the rising edge of `clk`.
* `sresetn` is the **synchronous**, active **low** reset.
* The reset values of the outputs are all zeros, except `force0` which reset value is `'1'`.
* An instance of `edge` is used to re-synchronize the `data_in` data line and detect its rising and falling edges.
* An instance of `sr` stores the bits sent serially by the DHT11 sensor.
* An instance of `counter` counts the received bits.
* An instance of `timer` measures the warm-up delay, the duration of the start command and the duration of the sensor-driven high and low pulses of `data_in`.
* The controller automatically starts a new acquisition `warm_us` micro-seconds after reset or after the end of the previous acquisition.
  It start acquisitions by asserting `force0` low for `start_us` micro-seconds.
* The decisions about the received bits are:
   * `'0'` if the duration of the corresponding high level of the data line is strictly less 50 micro-seconds.
   * `'1'` if the duration of the corresponding high level of the data line is greater or equal 50 micro-seconds.
* A checksum error occurs if the sum of the received temperature and relative humidity integer values is different from the received checksum, modulus 256.
  Checksum errors are signalled by asserting high the `cerr` output.
* The controller asserts `dso` high for exactly one clock period when detecting the last `data_in` rising edge of an acquisition (the edge labelled _end-of-transfer_ in the above _single-wire communication protocol_ figure).
* Normally the sensor-controlled phases of the communication protocol last only a few tens of micro-seconds.
  However, if the sensor malfunctions or if the data line is cut, one of these phases could last much longer, if not infinitely, and our controller could stay stuck waiting for an event that will never come.
  In order to avoid such deadlocks we will implement a kind of watchdog mechanism.
  During any of the sensor-controlled phases, if the timer equals `start_us` micro-seconds but the phase is not finished, we abort the current acquisition without asserting `dso` high, wait `warm_us` micro-seconds and try to start a new acquisition.
* The environment monitors `dso`.
  It samples `tp`, `rh` on each rising edge of `clk` where `dso` is asserted high and `cerr` is low.
  It expects `dso` to be asserted high during one `clk` period at the end of every acquisition, including when a checksum error occurred.
  On each rising edge of `clk` where `dso` is asserted high, if `cerr` is asserted high the environment ignores `tp` and `rh`.
  Else it considers `tp` and `rh` as valid temperature and relative humidity measurements.
* The environment ignores `tp`, `rh` and `cerr` when `dso` is low.
  They can thus take any value.
  If it makes sense, you can exploit this to optimize your design.

## Block diagram

Imagine how we could use the shift register, timer, 3-stages-re-synchronizer-and-edges-detector and counter we already designed to implement the DHT11 controller.
What value would you give to the generic parameters of their instances?

Draw a block diagram of `dht11_ctrl`.
Represent the state machine as a rectangular box.
Clearly identify and name the wires that interconnect the `sr`, `timer`, `edge`, `counter` instances, the state machine, and the outside world (input/output ports).
Imagine how you will generate the `cerr` output from the current value stored in the instance of `sr`.

## Learn a bit more of digital hardware design

Moore and Mealy finite state machines (discussion).

* What is a finite state machine?
* What are the differences between Moore and Mealy state machines?
* What are the advantages and drawbacks of Moore and Mealy state machines?
* Can we say that a Moore state machine is a special case of a Mealy state machine?
* Can we say that a Mealy state machine is a special case of a Moore state machine?
* What does the states diagram of a Moore state machine look like?
  Where do we indicate the value of the outputs?
  The conditions of the transitions?
* Draw the block diagram of a Moore state machine.
* What is the minimum number of processes needed to model a Moore state machine?
  Why?
* Are there specific Moore state machines that can be modelled with less processes?
* What does the states diagram of a Mealy state machine look like?
  Where do we indicate the value of the outputs?
  The conditions of the transitions?
* Draw the block diagram of a Mealy state machine.
* What is the minimum number of processes needed to model a Mealy state machine?
  Why?
* Are there specific Mealy state machines that can be modelled with less processes?
* What are the different ways to represent states in VHDL?
  What are their respective advantages and drawbacks?

## State diagram

Imagine how you will generate the outputs of the state machine.
Specify the state machine by drawing its state diagram.
Do not forget the watchdog mechanism to avoid deadlocks.
Try to compute the control signals combinatorially from the current state and the inputs of the state machine.

## VHDL coding

Edit the file named `dht11_ctrl.vhd`, code the `dht11_ctrl` entity and the `rtl` architecture.
Stick to your schematic and your state diagram, just translate it into VHDL.
Use an enumerated type for the states of the Mealy state machine and a signal for its current state:

```vhdl
type state_t is (idle, ...);
signal state: state_t;
```

## Validation

The provided simulation environment uses a reference model of the DHT11 sensor (`common/dht11.vhd`).
This reference model behaves like the real sensor.
Its behaviour is randomized but stays within the limits of the specification.
It randomly causes checksum errors.
It checks the start and warm-up durations and outputs reference values for `dso`, `cerr` and the 40 transmitted bits.
Based on these reference values the simulation environment checks the actual `dso`, `cerr`, `tp` and `rh` outputs of `dht11_ctrl`.

Validate your design using the provided simulation environment.
Compile, in the right order and in the right target library:

* `common/rnd_pkg.vhd`, `common/utils_pkg.vhd` and `common/dht11.vhd` in library `common`,
* `lab02/sr.vhd` and `lab03/timer.vhd` in library `work`,
* `lab05/edge.vhd` and `lab06/counter.vhd` in library `work`,
* `lab07/dht11_ctrl.vhd` and `lab07/dht11_ctrl_sim.vhd` in library `work`.

And (elaborate) simulate `work.dht11_ctrl_sim`.

## Peer review

Compare your solution with your neighbours'.

## Synthesis

The `dht11_ctrl_top.vhd` VHDL source file contains a minimal environment around the `dht11_ctrl` controller to be able to synthesize and test on the Zybo board:

- An instance of the `dht11_ctrl` controller, with generic parameters:
  * `f_mhz=125`, the frequency of the clock generated by the on-board Ethernet chip that we already used for the LED blinker, and that we also use here,
  * `start_us=20000` (20 milliseconds),
  * `warm_us=1000000`(1 second).
- A 2-stages resynchronizer of the inverted rightmost push-button used as reset.
- A tri-state buffer to drive the data line low.
- A 16-bits register to store the `rh` and `tp` outputs of `dht11_ctrl`.
- A multiplexer to select the source of the 4 user LEDs, based on the 2 rightmost user switches:
  * `"00"`: 4 Least Significant Bits (LSB) of the temperature,
  * `"01"`: 4 Most Significant Bits (MSB) of the temperature,
  * `"10"`: 4 LSBs of the humidity,
  * `"11"`: 4 MSBs of the humidity.

![`dht11_CTR_top and DHT11`](/images/dht11_ctrl_top-fig.png)  
*Minimal environment around the `dht11_ctrl` controller for synthesis and test (clock and resets not represented)*

We will now synthesize our design with the Vivado tool by Xilinx to map it in the programmable logic part of the Zynq core of the Zybo.
The `dht11_ctrl_top.syn.tcl` and `dht11_ctrl_top.params.tcl` TCL scripts will automate the synthesis and the `boot.bif` file will tell the Xilinx tools what to do with the synthesis result.
As usual, before you can use the synthesis scripts, you will have to edit `dht11_ctrl_top.params.tcl` and add information about the primary inputs and outputs (I/O) in the definition of the `ios` array (see the [Zybo reference manual] and the [Zybo schematics]).
Remember that the data line must be connected to pin number 1 of the `JE` Pmod connector.

Cross-check your edits with your neighbours. If everything looks fine, synthesize:

```bash
$ ds=$HOME/some-where/ds
$ syn=/tmp/$USER/ds/syn
$ mkdir -p $syn
$ cd $syn
$ vivado -mode batch -source $ds/vhdl/lab07/dht11_ctrl_top.syn.tcl -notrace
```

All log messages are printed on the standard output and stored in the `vivado.log` log file.
Check for errors and warnings in the log file.

A resource utilization report is available in `dht11_ctrl_top.utilization.rpt`.
Open it and look at the first table of the `Slice Logic` section.
Check that you have the expected number of "_Register as Flip Flop_" (registers used as Flip Flop) and that you do not have any unwanted "_Register as Latch_".
Check also that the other resources ("_LUT as Logic_", "_LUT as Memory_", "_Block RAMs_", "_DSPs_"...) are about in line with the complexity of your design.

A timing report is available in `dht11_ctrl_top.timing.rpt`.
Open it and check that you do not have critical warnings or errors in the first sections.
Then, check that "_All user specified timing constraints are met_".
Look also at the first of the "_Max Delay Paths_" and try to understand where it starts from, where it ends and how long it is.

The main synthesis result is in `dht11_ctrl_top.bit`.
If there were no synthesis errors or serious warnings, if the resource utilization and timing reports look OK, use the `bootgen` utility to pack the bitstream with the first (`fsbl.elf`) and second (`u-boot.elf`) stage software boot loaders that can be found in `$ds/software`:

```bash
$ cd $syn
$ cp $ds/software/fsbl.elf .
$ cp $ds/software/u-boot.elf .
$ bootgen -w -image $ds/vhdl/lab07/boot.bif -o boot.bin
```

The result is a *boot image*: `boot.bin`.

## Test

Mount the micro SD card on a computer and define a shell variable that points to it:

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

Open the small plastic box that contains the DHT11 module and inspect it.
The DHT11 sensor (the blue box) is connected to a small electronic board with two connectors (we will only use the 3 pins black connector located on the bottom side) and a 10 k-Ohms pull-up resistor.
If you carefully inspect the top side of the module you should see two metal tracks, one for the data line (labelled _S_) and the other for the power supply (_V_).
They connect the sensor to the two connectors.
There is no visible metal track for the ground (_G_) because it is routed in an inner layer of the printed circuit board.
A tiny rectangular Surface Mounted Device (SMD) component is soldered between the data line and the power supply.
It is the pull-up resistor.
With powerful enough magnifying glasses you could see the `103` label on it, where `10` is the significant value and `3` the power-of-ten of the multiplier, which means $`\mathbf{10}\times10^\mathbf{3}\ \Omega`$.

Imagine how you will connect the DHT11 sensor to the `JE` PMOD connector such that it is powered by the PMOD connector and the data line is connected to pin number 1 of the PMOD connector (you will need the male-female wire).
The figure below and also figure 16, page 24/26 of the [Zybo reference manual] should help you.
Cross-check with your neighbours and connect the module to the Zybo.

Power on the Zybo, read the humidity and temperature levels with the LEDs and the 2 rightmost user switches.
Blow on the sensor to increase both values and observe the changes.

[Zybo reference manual]: /doc/data/zybo_rm.pdf
[Zybo schematics]: /doc/data/zybo_sch.pdf
[DHT11 sensor datasheet]: /doc/data/DHT11.pdf

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
