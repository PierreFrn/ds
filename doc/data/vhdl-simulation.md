<!--
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

# VHDL simulation

VHDL simulation consists in exercising a VHDL model on a computer to analyze its behavior, discover bugs and fix them. It looks a lot like testing a program written in a classical programming language by compiling, linking and running it on a computer. The [Getting started with VHDL] chapter of the documentation explains in deep details the basic principles of HDL simulation, the event driven simulation algorithm and the semantics of VHDL simulation. Chapter [Digital hardware design using VHDL in a nutshell] explains how to design and develop a VHDL model starting from block diagrams. It also presents a complete example inspired by the design contest proposed by John Cooley for the 1995 edition of the Synopsys Users Group meeting (SNUG'1995). Using the same `cooley(rtl)` example this chapter explains how to use the various VHDL simulation tools in the context of this course.

In order to simulate an entity-architecture pair `cooley(rtl)` we need a _simulation environment_. A simulation environment is another entity-architecture pair in which:

1. the `cooley(rtl)` entity-architecture pair is instantiated,
1. processes around the `cooley(rtl)` instance are used to generate input stimuli,
1. optionally, processes are used to check the outputs of the `cooley(rtl)` instance.

Figure 1 represents the `cooley_sim(sim)` entity-architecture pair with the instantiated `cooley(rtl)` entity (red), the surrounding processes and the signals that interconnect the all.

[![A simulation environment for `cooley(rtl)`][1]][1]

The VHDL code of this simulation environment is the following (a commented version can be found in the `tests` subdirectory):

```vhdl
entity cooley_sim is
end entity cooley_sim;

use std.textio.all;
use std.env.all;

library common;
use common.rnd_pkg.all;

architecture sim of cooley_sim is

    signal clk:    bit;
    signal up:     bit;
    signal down:   bit;
    signal di:     bit_vector(8 downto 0);
    signal co:     bit;
    signal bo:     bit;
    signal po:     bit;
    signal do:     bit_vector(8 downto 0);

begin

	u0: entity work.cooley(rtl)
	port map(
		clock   => clk,
		up      => up,
		down    => down,
		di      => di,
		co      => co,
		bo      => bo,
		po      => po,
		do      => do
	);

	process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;

	process
		variable r: rnd_generator;
	begin
		r.init(1, 1);
		up   <= '0';
		down <= '0';
		di   <= (others => '0');
		wait until rising_edge(clk);
		for i in 1 to 10000 loop
			(up, down, di) <= r.get_bit_vector(11);
			wait until rising_edge(clk);
		end loop;
		report "End of simulation";
		finish;
	end process;

	process
		variable l: line;
	begin
		wait until rising_edge(clk);
		loop
			wait on po, do;
			if po /= not (xor do(8 downto 0)) then
				write(l, string'("DO="));
				write(l, do);
				write(l, string'(", PO="));
				write(l, po);
				assert false report l.all severity failure;
			end if;
		end loop;
	end process;

end architecture sim;
```

It generates the clock (first process), randomly generates the input stimuli (second process) but it automatically checks only the requirement about the `po` parity output (third process). The other requirements will have to be verified by visual inspection of the waveforms.

To simulate this we must compile, link and run or, in VHDL parlance, analyze, elaborate and simulate. But before compiling we must first explore another VHDL concept: libraries.

## VHDL libraries

VHDL design units (entities, architectures, packages) are always compiled in a target library, a kind of abstract container used to partition large projects in consistent sub-groups. VHDL libraries are a bit like modules or packages in other programming languages. They are very convenient, for instance, to split the work between designers of a team.

Some libraries are standard and are provided with all simulators (`std`, `ieee`...) They are read-only because modifying their content would corrupt the tool chain. The other libraries are created and managed by designers. We will name them user libraries.

User libraries have a logical name like `common` and a physical view, usually a directory in which the tools store compilation results. The logical name is used in the VHDL source code and is tool-independent. For example, if one wants to use the `rnd_pkg` of library `common` he must declare that with:

```vhdl
-- File cooley_sim.vhd
library common;
use common.rnd_pkg.all;
```

Note that this sort of inter-dependencies constrain the compilation order: before compiling `cooley_sim.vhd` we must compile `rnd_pkg.vhd` in library `common` (assuming the VHDL source code of package `rnd_pkg` is in file `rnd_pkg.vhd`).

The directory associated to a user library is tool-dependent. Each tool has its own strategy to create and modify the directory and its content and also its own way of associating logical names and directories. Modelsim and Vivado have almost the same default strategy: the name of the directory is the same as the logical name. The only difference is that for Modelsim the directory must be located immediately under where the commands are invoked while Vivado searches them in a `xsim.dir` sub-directory. Other behaviors can be obtained with the `vlib` and `vmap` Modelsim commands or with the `-lib name=directory` Vivado options, but for this course the default behavior is fine and recommended. GHDL, by default, stores all results in the directory it is invoked from but this can be changed with the `--workdir` and `-P` options. The default is also fine except if different libraries have design units with the same names, where the default could lead to name conflicts between the generated files. As these situations are avoided in this course, the GHDL default is also fine.

When compiling a VHDL source file, the _working_ library, that is, the library in which the compilation results will be stored, is specified with an option:

```bash
$ ghdl -a --work=common rnd_pkg.vhd
```

or:

```bash
$ vcom -work common rnd_pkg.vhd
```
or:

```bash
$ xvhdl -work common rnd_pkg.vhd
```

The `work` logical library name (not to be confused with the `-work` compilation option) is special for 3 main reasons:

1. In a VHDL source file it designates the working library, that is, the target library of the compilation of the file. So, if a VHDL source file `foo.vhd` contains a reference to library `work` and is compiled in library `foo_lib` (e.g. `vcom -work foo_lib foo.vhd`), `work` designates library `foo_lib`. While if we compile the same file in another library, let's say `bar_lib`, the same `work` designates library `bar_lib`. This is convenient to keep things generic: if we know that two files will always be compiled in the same library, they can reference each other's content with the `work` name instead of the actual library name. If later on we decide to change the name of the library in which we compile them we will not need to change these reference to the `work` library. Example: if file `dht11.vhd` is compiled in library `common` and contains:

    ```vhdl
    use work.rnd_pkg.all;
    ```

   the `rnd_pkg` package is searched for in library `common` (in which it must have been compiled before `dht11.vhd`), not in a library really named `work`.

1. This special library name is implicitly declared: the `library work;` declaration is not needed in our VHDL source files.

1. When compiling a VHDL source file, if the target library is not specified, most tools (including GHDL, Modelsim and Vivado) use `work` as the default target library: the `-work work` or `--work=work` options are the default.

> Note: the fact that library named `work` is the _working_ library has an interesting consequence: if we really create a library named `work` (or if we let the tools create it by default), it will be impossible to refer to its content from within a source file compiled in another library. Indeed, if we compile a package named `foo_pkg` in a library really named `work`, and then another source file in a library named `common`, and the compiler encounters a statement like `use work.foo_pkg.all;` it will search `foo_pkg` in library `common`, not in the existing `work` library. Because of this, ideally, we should avoid using a library really named `work`. But this will not be a problem in this course. We can thus exploit the default behavior of our 3 tool chains and let them compile by default in a library named `work`.

> Note: the `work` library is not the only one that is implicitly declared. The use of the `std` standard library is also implicitly declared and the use of the `std.standard` package too. All in all, it is like if each VHDL file implicitly contained:

   ```vhdl
   library std;
   use std.standard.all;

   library work;
   ```

   before any compilation unit. All other used libraries and packages (user or standard) must be declared before use.

## Compilation

The VHDL compilation takes one or several VHDL source files and some options. We already met the `-work <logical name>` option that designates the target library (default `-work work` or `--work=work`). The other useful options are:

- `-2008` (Modelsim and Vivado) or `--std=08` (GHDL), to set the version of the VHDL standard,
- `+acc` (Modelsim only) to avoid some optimizations and retain access to variables, constants... during debugging.

Example of compilation with GHDL:

```bash
$ ghdl -a --std=08 -work common ds/common/rnd_pkg.vhd
$ ghdl -a --std=08 ds/tests/cooley.vhd
$ ghdl -a --std=08 ds/tests/cooley_sim.vhd
```

Example of compilation with Modelsim:

```bash
$ vcom -2008 +acc -work common ds/common/rnd_pkg.vhd
$ vcom -2008 +acc ds/tests/cooley.vhd
$ vcom -2008 +acc ds/tests/cooley_sim.vhd
```

Example of compilation with Vivado:

```bash
$ xvhdl -2008 -work common ds/common/rnd_pkg.vhd
$ xvhdl -2008 ds/tests/cooley.vhd
$ xvhdl -2008 ds/tests/cooley_sim.vhd
```

Some compilation options can be set as the default once for all by modifying a configuration file in the installation. With the [ModelSim-Intel FPGA Starter Edition Software], for instance, the `-2008` option of `vcom` can be set as the default by editing the `/some/where/modelsim_ase/modelsim.ini` file (where `/some/where` is the installation root directory) and, in the `[vcom]` section, replacing:

```
VHDL93 = 2002
```

by:

```
VHDL93 = 2008
```

For other options and tools see the documentation.

## Elaboration

Elaboration is mandatory with Vivado and optional with Modelsim and GHDL. If you use Modelsim or GHDL forget about it, it is useless in this course. If you use Vivado use the `xelab` command (after compilation) to elaborate the top level, that is, to create the simulation executable. Contrary to compilation that operates on VHDL source files, elaboration operates on a single, already compiled design unit. The library of the design unit can be specified as in `work.cooley_sim` but if it is the default `work`, it can be omitted.

`xelab` has at least one important option: `-debug all` that avoids some optimizations and retains access to variables, constants... during debugging. Example:

```bash
$ xelab -debug all cooley_sim
```

## Simulation

With Modelsim (`vsim`) and Vivado (`xsim`) the simulation can be done either in Graphical User Interface (GUI) mode or in Command Line Interface (CLI) mode. GHDL (`ghdl -r`) does not have a GUI but it can generate a Value Change Dump (VCD) file in which it records all signal changes. This VCD file can then be opened with e.g. GTKWave to display and analyze the waveforms.

The CLI mode is very convenient for non-regression tests with a full-featured simulation environment that checks the outputs of the Design Under Test (DUT) and prints warning or error messages when an undesirable behavior is detected. Of course, such simulation environments are more difficult to design: they must have a good coverage, check as many specification points as possible, print useful informative messages... The CLI mode is the default with `xsim` (and, of course, with GHDL). It must be specified with the `-c` option for `vsim`. Other options can be used to automatically launch the simulation and quit when it finishes. An important `vsim` option is `-voptargs="+acc"` that avoids some optimizations and retains access to variables, constants... during debugging.

Example with `ghdl`:

```bash
$ ghdl -r --std=08 cooley_sim
```

Example with `vsim`:

```bash
$ vsim -c -voptargs="+acc" cooley_sim -do 'run -all; quit'
```

Example with `xsim`:

```bash
$ xsim -runall cooley_sim
```

The GUI mode is especially useful during the design-verification cycle. Both Modelsim and Vivado simulators have many useful debugging features: waveforms, breakpoints, step-by-step execution... See the respective documentations for more complete descriptions.

```bash
$ ghdl -r --std=08 cooley_sim --vcd=wave.vcd
$ gtkwave wave.vcd # GNU/Linux
$ open wave.vcd    # macOS
```

The GUI mode is the default with `vsim`:

```bash
$ vsim -voptargs="+acc" cooley_sim
```

The GUI mode must be specified with the `-gui` option for `xsim`:

```bash
$ xsim -gui cooley_sim
```

[Getting started with VHDL]: getting-started-with-vhdl.md
[Digital hardware design using VHDL in a nutshell]: digital-hardware-design-using-vhdl-in-a-nutshell.md
[1]: /images/cooley_sim-fig.png
[ModelSim-Intel FPGA Starter Edition Software]: https://www.altera.com/products/design-software/model---simulation/modelsim-altera-software.html

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
