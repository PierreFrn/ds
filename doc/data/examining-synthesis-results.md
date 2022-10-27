<!--
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

# Examining synthesis results

Logic synthesis translates a HDL description into a network of interconnected logic gates and memory elements. It is very different from simulation. The error, warning and information messages issued by a logic synthesizer are very different from the messages issued by a simulation tool. It can be that the simulations run as expected but the logic synthesis fails or produces erroneous results. The opposite is also possible.

## Synthesis errors

Error messages are printed on the standard output during the synthesis and usually also stored in one or more log files. Sometimes a global but not very informative error message is printed on the standard output and detailed error messages are only stored in log files. It is thus important to know where to look for them. With Xilinx Vivado two modes of operation are supported:

* In project mode several log files are produced. The global log file is named `vivado.log` by default but detailed error messages are stored in other log files. Its(their) path(s) is(are) mentioned in the global log file, search for the string `"log"` in `vivado.log`. In the following we can see that the secondary log file for the synthesis of a design named `top` is `/tmp/top.runs/synth_1/runme.log` and that two sub-modules named `lb` and `ps7` have their respective synthesis log files named `/tmp/top.runs/top_lb_0_synth_1/runme.log` and `/tmp/top.runs/top_ps7_0_synth_1/runme.log`:

    ```bash
    $ cat vivado.log
    ...
    [Wed Mar 20 09:32:21 2019] Launched top_lb_0_synth_1, top_ps7_0_synth_1...
    Run output will be captured here:
    top_lb_0_synth_1: /tmp/top.runs/top_lb_0_synth_1/runme.log
    top_ps7_0_synth_1: /tmp/top.runs/top_ps7_0_synth_1/runme.log
    [Wed Mar 20 09:32:22 2019] Launched synth_1...
    Run output will be captured here: /tmp/top.runs/synth_1/runme.log
    ...
    ```

   If a synthesis error occurs, it is probably these secondary log files that must be analyzed.

* In non-project mode, usually, only the global log file is produced and contains all error messages.

Here is a (non exhaustive) list of reasons why a logic synthesis can fail:

* Syntax errors in the HDL source code.
   > * Note: as the synthesis usually takes time, it is recommended to first check the correctness of the VHDL source code with a compiler / simulator before trying to synthesize. Syntax errors will be identified more quickly.
   > * Note: for the same reason it makes more sense to synthesize a design only after simulations have shown that it is functionally correct (or, at least, we are reasonably confident that it is).
   > * Note: there are exceptions, though. It may sometimes be interesting to try to synthesize a design even if it is not yet complete. For instance to test that a HDL construct is properly supported by the synthesizer for the selected hardware target. Another example is when a design comprises critical parts (e.g. large multipliers) for which it is essential to get an estimate of the performance (size, speed, power consumption, number of pipeline stages...) before the rest can be designed.
* Syntax errors in the synthesis script or mismatches between names (entities, ports...) in the HDL source code and the synthesis script.
* Letter case: VHDL is not case sensitive but some synthesis tools consider the case of identifiers (entities, ports...) as meaningful.
   > Note: in the VHDL source files it is recommended to always use the same case for a given user identifier (entity, port...) and to use the same case in the synthesis scripts.
* Some synthesizers are not 100% compliant with the latest version of the HDL standard. Reading output ports, for instance, is supported in VHDL only since the 2008 version of the standard. If the logic synthesizer does not yet fully support VHDL 2008 it can reject an architecture in which output ports are read while a compliant tool (compiler / simulator or another synthesizer) would not.
* Unsupported HDL constructs, like files, pointers or other pure software concepts that exist in HDLs but are not synthesizable for obvious reasons: they have no hardware equivalent.
   > * Note: some synthesizers silently ignore these constructs when they are used in an unsupported context. They do not even issue warnings or errors.
   > * Note: some synthesizers support these pure software constructs in very specific contexts, like to initialize constants. The content of an array modeling a ROM, for instance, can be read from a text file, using pointers. The non-synthesizable constructs are then not really translated into hardware. Instead, the synthesizer somehow "_simulates_" the code before the real synthesis to compute the value of the constants. It then uses the computed values during synthesis.
* Other unsupported HDL constructs, like `wait` statements or physical time for many synthesizers. Depending on the HDL construct and on the synthesizer errors can be issued, or warnings, or the constructs can be silently ignored. The following VHDL code will be rejected by many synthesizers, either with an error, a warning or by completely and silently ignoring the `after 2 ns` statement:

    ```vhdl
    signal a, b, c: bit;
    ...
    c <= a and b after 2 ns; -- physical time
    ```
* HDL constructs that have a hardware equivalent but for which the gap between the (apparent) simplicity of the HDL code and the complexity of the hardware equivalent is too large. Many synthesizers, for instance, reject floating point computations. In a VHDL code one could write:

    ```vhdl
    signal a, b, c: real;
    ...
    c <= a / b;
    ```

   In order to synthesize this, a synthesizer would need to instantiate a floating point unit, which is a very complex hardware component for which hundreds of different candidate architectures exist. With these synthesizers, when floating point computations are needed, a floating point unit must be modeled with all details and a custom record type must be used to represent the operands:

    ```vhdl
    type my_real is
      record
        sign:     std_ulogic;
        exponent: std_ulogic_vector(7 downto 0);
        mantissa: std_ulogic_vector(22 downto 0);
      end record my_real;
    type my_real_operations is (mul, div, add, sub);
    ...
    entity my_fpu is
      port(clk, sresetn, start: in  std_ulogic;
           op:                  in  my_real_operations;
           a, b:                in  my_real;
           done:                out std_ulogic;
           c:                   out my_real
      );
    end entity my_fpu;
    ...
    ```

   > Note: many logic synthesizers, for the same reason, also reject integer divisions (except if the operands are constants or if the divider is a power of 2).
* HDL constructs for which the target technology has no equivalent. Dual-edge-triggered flip-flops, for instance, are frequently unsupported. The following code will be rejected by logic synthesizers that do not support dual-edge-triggered flip-flops for the selected hardware target:

    ```vhdl
    process(clk)
    begin
      if rising_edge(clk) then
        q <= a;
      elsif falling_edge(clk) then
        q <= b;
      end if;
    end process;
    ```

## Synthesis warnings

Most warnings can be ignored because they correspond to unused elements that are discarded by the synthesis but some must sometimes be considered seriously. They can indicate problems that must be solved. Ignoring warnings without first checking that they can safely be ignored is usually a bad idea that will eventually have to be paid. The synthesis warnings can be found in the same log files as the synthesis errors. Two types of warnings are frequently encountered and deserve attention (but all of them shall be investigated).

### Latch inference

Very frequently, inferred latches are not intentional but due to errors in the HDL code. For this reason most synthesizers issue a warning. For example, this VHDL process:

```vhdl
process(a, b)
begin
    if b = '1' then
        c <= a;
    elsif a = '0' then
        c <= '1';
    end if;
end process;
```

Is not a synchronous process but it is not a combinatorial process neither: the `c` output is not assigned in all possible executions of the process. If `b /= '1'` and `a /= '0'`, `c` is not assigned. A logic synthesizer considers that, in this case, the previous value must be preserved, and it infers a latch to store the value of `c` such that it can output the stored value when a new value is not computed from `a` and `b`. If fed with such a VHDL code Xilinx Vivado will issue warnings like:

```bash
$ grep -i warning vivado.log
...
WARNING: [Synth 8-327] inferring latch for variable 'c_reg' [.../foobar.vhd:14]
...
WARNING: [DRC PDRC-153] Gated clock check: Net foobar/U0/c_reg_i_2_n_0 is a gated
clock net sourced by a combinational pin foobar/U0/c_reg_i_2/O, cell
foobar/U0/c_reg_i_2. This is not good design practice and will likely impact
performance. For SLICE registers, for example, use the CE pin to control the
loading of data.
...
```

Moreover, it will report this in the resources utilization report (see below):

```bash
$ cat foobar.utilization.rpt
...
1. Slice Logic
--------------

+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
...
|   Register as Latch     |    1 |     0 |     35200 | <0.01 |
...
+-------------------------+------+-------+-----------+-------+
...
```

If latches are inferred it is essential to check that this is not due to a wrongly designed HDL description. Else, there is a real risk that the behavior of the synthesized hardware is not the expected one. Debugging this kind of errors on the target hardware is extremely difficult, if not impossible.

### Incomplete sensitivity lists

If the sensitivity list of a combinatorial process is incomplete there is a risk of mismatch between the simulation and the behavior of the synthesized hardware. This is why most synthesizers issue a warning. Example of incomplete VHDL sensitivity list:

```vhdl
process(a)
begin
    c <= a and b;
end process;
```

The process should also be sensitive to `b` because the value of signal `b` is read (it is in the right-hand side of an assignment). If fed with such a process Xilinx Vivado will issue a warning like:

```bash
$ grep -i warning vivado.log
...
WARNING: [Synth 8-614] signal 'b' is read in the process but is not in the sensitivity list [.../foobar.vhd:11]
...
```

Most synthesizers are capable of detecting and fixing this kind of errors automatically: they will probably do what the designer wanted. However the simulations that were used to functionally validate the design do not necessarily reflect the behavior of the final hardware. It is essential to fix the incomplete sensitivity lists and re-simulate the design to verify that the observed behavior is really the expected one.

## Resources utilization

Once all errors have been fixed, all warnings have been investigated and, when needed, also fixed, the resources utilization report shall be analyzed. It is frequently produced as one or several separate text files. Three important aspects shall be studied:

1. Is the number of flip-flops (one bit registers) consistent with the expectations? If the HDL supposedly models a 64-bits register but only 2 flip-flops (or 128) were inferred, there is probably something wrong.
1. Are there latches? As latches are frequently unwanted side-effects of badly coded HDL, each reported latch must be explained.
1. Is the usage of other resources (glue logic, DSP blocks, Block RAMs) consistent with the expectations? If the design models an 8 bits adder but thousands of LUTs (Look-Up Tables, a basic glue-logic element in FPGAs) have been used, there is probably something wrong. Symmetrically, if the HDL code models a very sophisticated floating point unit but only a dozen of LUTs have been used, there is probably something wrong. Finally, the number of DSP blocks, Block RAMs or other target-specific resources must also be consistent with the intentions of the designers.

Warning: the resource utilization report may sometimes also report resources for elements that have been automatically added by the tools, not just for the user HDL code.

## Timing

The timing report is where information about the performance of the synthesized hardware can be found. It shall be analyzed to check that the target clock frequency and the other timing constraints are correctly specified are met. If they are not, the design will not work properly at the target clock frequency. If you have latches or flip-flops not clocked by a declared clock pin, for instance, and/or I/O pins not constrained for maximum delay, there is probably a serious problem. But even if the timing constraints are met is may be interesting to study this report carefully. It could be, for instance, that the constraints are met so easily that it is worth trying to take advantage of this to save some hardware resources. Or that the critical path is far from all other paths and that slightly reworking the corresponding part of the design could lead to a much better global result.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
