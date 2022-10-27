<!--
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

First intermediate status check-list

Please fill the check list and add-commit push it. If you are late on some tasks, please try to catch up.

* [x] Get a Zybo prototyping board
* [x] Fill the `zybo.md` file, add-commit-push it
* [x] Learn enough of `git` (e.g. by reading the [ProGit book]) for our needs in the labs
* [x] Learn enough of Markdown (e.g. on [Daring Fireball] or the [Markdown tutorial]) for our needs in the labs
* [ ] Read the following parts of the [Free Range Factory] book:
   * [ ] Chapter 1
   * [ ] Chapter 2
   * [ ] Chapter 3
   * [ ] Chapter 4
   * [ ] Chapter 5
   * [ ] Section 10.4
   * [ ] Section 10.8
* [ ] Read the following parts of the documentation:
   * [ ] [Digital hardware design using VHDL in a nutshell]
   * [x] [Getting started with VHDL]
   * [ ] [VHDL simulation]
   * [ ] [The `ieee.std_logic_1164` package]
   * [x] [Generic parameters]
   * [x] [Aggregate notations]
   * [x] [Comments]
   * [x] [Identifiers]
   * [x] [Wait statements]
   * [x] [Initial values declarations]
   * [ ] [D-flip-flops (DFF) and latches]
   * [ ] [Arithmetic: which types to use?]
   * [x] [Entity instantiations]
   * [ ] [Resolution functions, unresolved and resolved types]
* [x] Complete [the continuity tester](vhdl/lab01)
   * [x] Write the VHDL model of the continuity tester for our jumper wires
   * [x] Write a simulation environment, simulate, debug, validate using GHDL, Siemens Modelsim or Xilinx Vivado
   * [x] Pass the automatic evaluation
   * [x] Synthesize
   * [x] Test on the Zybo board
   * [ ] Write your report
* [x] Complete [the shift register](vhdl/lab02)
   * [x] Write the VHDL model of the shift register
   * [x] Use the provided simulation environment to simulate, debug and validate using GHDL, Siemens Modelsim or Xilinx Vivado
   * [x] Pass the automatic evaluation
   * [ ] Write your report
* [x] Complete [the timer](vhdl/lab03)
   * [x] Write the VHDL model of the timer
   * [x] Use the provided simulation environment to simulate, debug and validate using GHDL, Siemens Modelsim or Xilinx Vivado
   * [x] Pass the automatic evaluation
   * [ ] Write your report
* [x] Complete [the LED blinker](vhdl/lab04)
   * [x] Write the VHDL model of the LED blinker
   * [x] Use the provided simulation environment to simulate, debug and validate using GHDL, Siemens Modelsim or Xilinx Vivado
   * [x] Pass the automatic evaluation
   * [x] Synthesize the LED blinker
   * [x] Test on the Zybo board
   * [ ] Write your report
* [x] Complete [the edge detector](vhdl/lab05)
   * [x] Write the VHDL model of the re-synchronizer / edges detector
   * [x] Use the provided simulation environment to simulate, debug and validate using GHDL, Siemens Modelsim or Xilinx Vivado
   * [x] Pass the automatic evaluation
   * [ ] Write your report
* [x] Complete [the counter](vhdl/lab06)
   * [x] Write the VHDL model of the counter
   * [x] Use the provided simulation environment to simulate, debug and validate using GHDL, Siemens Modelsim or Xilinx Vivado
   * [x] Pass the automatic evaluation
   * [ ] Write your report
* [x] Read the [DHT11 sensor datasheet]
* [ ] Imagine and start specifying the DHT11 controller.

[ProGit book]: doc/data/ProGitScottChacon.pdf
[Daring Fireball]: https://daringfireball.net/projects/markdown/syntax
[Markdown tutorial]: http://www.markdowntutorial.com/
[Free Range Factory]: doc/data/free_range_vhdl.pdf
[Getting started with VHDL]: doc/data/getting-started-with-vhdl.md
[Digital hardware design using VHDL in a nutshell]: doc/data/digital-hardware-design-using-vhdl-in-a-nutshell.md
[VHDL simulation]: doc/data/vhdl-simulation.md
[Comments]: doc/data/comments.md
[Identifiers]: doc/data/identifiers.md
[Wait statements]: doc/data/wait.md
[The `ieee.std_logic_1164` package]: doc/data/std_logic_1164.md
[Generic parameters]: doc/data/generics.md
[Aggregate notations]: doc/data/aggregate-notations.md
[Resolution functions, unresolved and resolved types]: doc/data/resolution-functions-unresolved-and-resolved-types.md
[Entity instantiations]: doc/data/entity-instantiations.md
[Initial values declarations]: doc/data/initial-values.md
[D-flip-flops (DFF) and latches]: doc/data/d-flip-flops-dff-and-latches.md
[Arithmetic: which types to use?]: doc/data/arithmetic-which-types-to-use.md
[DHT11 sensor datasheet]: doc/data/DHT11.pdf

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
