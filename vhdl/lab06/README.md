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

Lab: a counter

---

[TOC]

---

# CODING CHALLENGE: counter (30 minutes)

Counters are a very common element in digital hardware.
We used counters already when designing [our timer](../lab03/).
This challenge consists in designing a counter with _force-to-zero_ and _increment_ control inputs.

## Specifications

The entity is named `counter` and its architecture is named `rtl`.
Generic parameters:

| Name       | Type                            | Description                                                         |
| :----      | :----                           | :----                                                               |
| `cmax`     | `natural`                       | maximum value of counter                                            |

Input-output ports:

| Name       | Type                            | Direction | Description                                                             |
| :----      | :----                           | :----     | :----                                                                   |
| `clk`      | `std_ulogic`                    | in        | master clock, the design is synchronized on the rising edge of `clk`    |
| `sresetn`  | `std_ulogic`                    | in        | **synchronous**, active **low** reset                                   |
| `cz`       | `std_ulogic`                    | in        | if asserted **high**, force counter to zero                             |
| `inc`      | `std_ulogic`                    | in        | if asserted **high**, increment counter                                 |
| `c`        | `natural range 0 to cmax`       | out       | current value of counter                                                |

* The design is synchronized on the rising edge of `clk`.
* `sresetn` is a **synchronous**, active **low** reset that forces the counter to 0.
* On rising edges of `clk`, `c` is:
   * forced to 0 if `cz` is high,
   * else incremented by one if it is strictly less than `cmax` and `inc` is high,
   * else unmodified.

The following waveform shows the behaviour of `counter` with `cmax = 5`.

![`counter` waveform](/images/counter_waveform.png)  
*Behaviour of `counter` with `cmax = 5`*

## Schematic

As usual, before coding the VHDL model, draw a schematic of the digital hardware.

## VHDL coding

Edit the file named `counter.vhd`.
Code the `counter` entity and the `rtl` architecture.
Stick to your schematic, just translate it into VHDL.

## Validation

Validate your design using the provided simulation environment.

## Peer review

After the end of the challenge, compare your solution with your neighbours'.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
