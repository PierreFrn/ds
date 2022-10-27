<!--
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

# Digital hardware design using VHDL in a nutshell

Digital hardware design using VHDL is simple, even for beginners, but there are a few important things to know and a small set of rules to obey. The tool used to transform a VHDL description in digital hardware is a logic synthesizer. The semantics of the VHDL language used by logic synthesizers is rather different from the simulation semantics described in the Language Reference Manual (LRM). Even worse: it is not standardized and varies between synthesis tools.

The proposed method introduces several important limitations for the sake of simplicity:

- No level-triggered latches.
- The circuits are synchronous on the rising edge of a single clock.
- No asynchronous reset or set.
- No multiple drive on resolved signals.

The [Block diagram](#block-diagram) section briefly presents the basics of digital hardware and proposes a short list of rules to design a block diagram of a digital circuit. The rules help to guarantee a straightforward translation to VHDL code that simulates and synthesizes as expected.

The [Coding](#coding) section explains the translation from a block diagram to VHDL code and illustrates it on a simple digital circuit.

Finally, the [John Cooley’s design contest](#john-cooleys-design-contest) section shows how to apply the proposed method on a more complex example of digital circuit. It also elaborates on the introduced limitations and relaxes some of them.

## Introduction

In this chapter we propose a simple method to correctly design simple digital circuits with VHDL. The method is based on graphical block diagrams and an easy-to-remember principle:

__Think hardware first, code VHDL next__

It is intended for beginners in digital hardware design using VHDL, with a limited understanding of the synthesis semantics of the language.

## Block diagram

Digital hardware is built from two types of hardware primitives:

- Combinatorial gates (inverters, and, or, xor, 1-bit full adders, 1-bit multiplexers...) These logic gates perform a simple boolean computation on their inputs and produce an output. Each time one of their inputs changes, they start propagating electrical signals and, after a short delay, the output stabilizes to the resulting value. The propagation delay is important because it is strongly related to the speed at which the digital circuit can run, that is, its maximum clock frequency.
- Memory elements (latches, D-flip-flops, RAMs...). Contrary to the combinatorial logic gates, memory elements do not react immediately to the change of any of their inputs. They have data inputs, control inputs and data outputs. They react on a particular combination of control inputs, not on any change of their data inputs. The rising-edge triggered D-flip-flop (DFF), for instance, has a clock input and a data input. On every rising edge of the clock, the data input is sampled and copied to the data output that remains stable until the next rising edge of the clock, even if the data input changes in between.

A digital hardware circuit is a combination of combinatorial logic and memory elements. Memory elements have several roles. One of them is to allow reusing the same combinatorial logic for several consecutive operations on different data. Circuits using this are frequently referred to as _sequential circuits_. The figure below shows an example of a sequential circuit that accumulates integer values using the same combinatorial adder, thanks to a rising-edge triggered register. It is also our first example of a block diagram.

[![A sequential circuit][1]][1]

Pipe-lining is another common use of memory elements and the basis of many micro-processor architectures. It aims at increasing the clock frequency of a circuit by splitting a complex processing in a succession of simpler operations, and at parallelizing the execution of several consecutive processing:

[![Pipe-lining of a complex combinatorial processing][2]][2]

The block diagram is a graphical representation of the digital circuit. It helps making the right decisions and getting a good understanding of the overall structure before coding. It is the equivalent of the recommended preliminary analysis phases in many software design methods. Experienced designers frequently skip this design phase, at least for simple circuits. If you are a beginner in digital hardware design, however, and if you want to code a digital circuit in VHDL, adopting the 10 simple rules below to draw your block diagram should help you getting it right:

1. Surround your drawing with a large rectangle. This is the boundary of your circuit. Everything that crosses this boundary is an input or output port. The VHDL entity will describe this boundary.
2. Clearly separate edge-triggered registers (e.g. square blocks) from combinatorial logic (e.g. round blocks). In VHDL they will be translated into processes but of two very different kinds: synchronous and combinatorial.
3. Do not use level-triggered latches, use only rising-edge triggered registers. This constraint does not come from VHDL, which is perfectly usable to model latches. It is just a reasonable advice for beginners. Latches are less frequently needed and their use poses many problems which we should probably avoid, at least for our first designs.
4. Use the same single clock for all of your rising-edge triggered registers. There again, this constraint is here for the sake of simplicity. It does not come from VHDL, which is perfectly usable to model multi-clock systems. Name the clock `clock`. It comes from the outside and is an input of all square blocks and only them. If you wish, do not even represent the clock, it is the same for all square blocks and you can leave it implicit in your diagram.
5. Represent the communications between blocks with named and oriented arrows. For the block an arrow comes from, the arrow is an output. For the block an arrow goes to, the arrow is an input. All these arrows will become ports of the VHDL entity, if they are crossing the large rectangle, or signals of the VHDL architecture.
6. Arrows have one single origin but they can have several destinations. Indeed, if an arrow had several origins we would create a VHDL signal with several drivers. This is not completely impossible but requires special care in order to avoid short-circuits. We will thus avoid this for now. If an arrow has several destinations, fork the arrow as many times as needed. Use dots to distinguish connected and non-connected crossings.
7. Some arrows come from outside the large rectangle. These are the input ports of the entity. An input arrow cannot also be the output of any of your blocks. This is enforced by the VHDL language: the input ports of an entity can be read but not written. This is again to avoid short-circuits.
8. Some arrows go outside. These are the output ports[^1].
9. All arrows that do not come or go from/to the outside are internal signals. You will declare them all in the VHDL architecture.
10. Every cycle in the diagram must comprise at least one square block. This is not due to VHDL. It comes from the basic principles of digital hardware design. Combinatorial loops shall absolutely be avoided. Except in very rare cases, they do not produce any useful result. And a cycle of the block diagram that would comprise only round blocks would be a combinatorial loop.

Do not forget to carefully check the last rule, it is as essential as the others but it may be a bit more difficult to verify.

Unless you absolutely need features that we excluded for now, like latches, multiple-clocks or signals with multiple drivers, you should easily draw a block diagram of your circuit that complies with the 10 rules. If not, the problem is probably with the circuit you want, not with VHDL or the logic synthesizer. And it probably means that the circuit you want is __not__ digital hardware.

Applying the 10 rules to our example of a sequential circuit would lead to a block diagram like:

[![Reworked block diagram of the sequential circuit][3]][3]

1. The large rectangle around the diagram is crossed by 3 arrows, representing the input and output ports of the VHDL entity.
2. The block diagram has two round (combinatorial) blocks - the adder and the output renaming block - and one square (synchronous) block - the register.
3. It uses only edge-triggered registers.
4. There is only one clock, named `clock` and we use only its rising edge.
5. The block diagram has five arrows, one with a fork. They correspond to two internal signals, two input ports and one output port.
6. All arrows have one origin and one destination except the arrow named `Data_out` that has two destinations.
7. The `Data_in` and `Clock` arrows are our two input ports. They are not output of our own blocks.
8. The `Data_out` arrow is our output port.
9. `Next_sum` is our internal signal.
10. There is exactly one cycle in the graph and it comprises one square block.

Our block diagram complies with the 10 rules. The [Coding](#coding) section will detail how to translate this type of block diagrams in VHDL.

## Coding

With a block diagram that complies with the 10 rules (see the [Block diagram](#block-diagram) section), the VHDL coding becomes straightforward:

- the large surrounding rectangle becomes the VHDL entity,
- internal arrows become VHDL signals and are declared in the architecture,
- every square block becomes a synchronous process in the architecture body,
- every round block becomes a combinatorial process in the architecture body.

Let us illustrate this on the block diagram of a sequential circuit:

[![A sequential circuit][1]][1]

The VHDL model of a circuit comprises two compilation units:

- The entity that describes the circuit's name and its interface (ports names, directions and types). It is a direct translation of the large surrounding rectangle of the block diagram. Assuming the data are integers, and the `clock` uses the VHDL type `bit` (two values only: `'0'` and `'1'`), the entity of our sequential circuit could be:
```vhdl
entity sequential_circuit is
  port(
    Data_in:  in  integer;
    Clock:    in  bit;
    Data_out: out integer
  );
end entity sequential_circuit;
```

- The architecture that describes the internals of the circuit (what it does). This is where the internal signals are declared and where all processes are instantiated. The skeleton of the architecture of our sequential circuit could be:
```vhdl
architecture ten_rules of sequential_circuit is
  signal Next_sum: integer;
begin
  <...processes...>
end architecture ten_rules;
```

We have two processes to add to the architecture body, one synchronous (square block) and one combinatorial (round block).

A synchronous process looks like this:
```vhdl
process(clock)
begin
  if rising_edge(clock) then
    o1 <= i1;
    ...
    ox <= ix;
  end if;
end process;
```

where `i1, i2,..., ix` are __all__ arrows that enter the corresponding square block of the diagram and `o1, ..., ox` are __all__ arrows that output the corresponding square block of the diagram. Absolutely nothing shall be changed, except the names of the signals, of course. Nothing. Not even a single character. 

The synchronous process of our example is thus:
```vhdl
  process(clock)
  begin
    if rising_edge(clock) then
      Data_out <= Next_sum;
    end if;
  end process;
```

Which can be informally translated into: if `clock` changes, and only then, if the change is a rising edge (`'0'` to `'1'`), assign the value of signal `Next_sum` to signal `Data_out`.

A combinatorial process looks like this:
```vhdl
process(i1, i2,... , ix)
  variable v1: <type_of_v1>;
  ...
  variable vy: <type_of_vy>;
begin
  v1 := <default_value_for_v1>;
  ...
  vy := <default_value_for_vy>;
  o1 <= <default_value_for_o1>;
  ...
  oz <= <default_value_for_oz>;
  <statements>
end process;
```

where `i1, i2,..., ix` are __all__ arrows that enter the corresponding round block of the diagram. __all__ and no more. We shall not forget any arrow and we shall not add anything else to the list.

`v1, ..., vy` are variables that we may need to simplify the code of the process. They have exactly the same role as in any other imperative programing language: hold temporary values. They must absolutely be all assigned before being read. If we fail guaranteeing this, the process will not be combinatorial any more as it will model kind of memory elements to retain the value of some variables from one process execution to the next. This is the reason for the `vi := <default_value_for_vi>` statements at the beginning of the process. Note that the `<default_value_for_vi>` must be constants. If not, if they are expressions, we could accidentally use variables in the expressions and read a variable before assigning it.

`o1, ..., oz` are __all__ arrows that output the corresponding round block of your diagram. __all__ and no more. They must absolutely be all assigned at least once during the process execution. As the VHDL control structures (`if`, `case`...) can very easily prevent an output signal from being assign, we strongly advice to assign each of them, unconditionally, with a constant value `<default_value_for_oi>` at the beginning of the process. This way, even if an `if` statement masks a signal assignment, it will have received a value anyway.

Absolutely nothing shall be changed to this VHDL skeleton, except the names of the variables, if any, the names of the inputs, the names of the outputs, the values of the `<default_value_for_..>` constants and `<statements>`. Do __not__ forget a single default value assignment, if you do the synthesis will infer unwanted memory elements (most likely latches) and the result will not be what you initially wanted.

In our example sequential circuit, the combinatorial adder process is:
```vhdl
  process(Data_out, Data_in)
  begin
    Next_sum <= 0;
    Next_sum <= Data_out + Data_in;
  end process;
```

Which can be informally translated into: if `Data_out` or `Data_in` (or both) change assign the value 0 to signal `Next_sum` and then assign it again value `Data_out + Data_in`.

As the first assignment (with the constant default value `0`) is immediately followed by another assignment that overwrites it, we can simplify:
```
  process(Data_out, Data_in)
  begin
    Next_sum <= Data_out + Data_in;
  end process;
```

The complete code for the sequential circuit is:
```vhdl
-- File sequential_circuit.vhd
entity sequential_circuit is
  port(
    Data_in:  in  integer;
    Clock:    in  bit;
    Data_out: out integer
  );
end entity sequential_circuit;

architecture ten_rules of sequential_circuit is
  signal Next_sum: integer;
begin
  process(clock)
  begin
    if rising_edge(clock) then
      Data_out <= Next_sum;
    end if;
  end process;

  process(Data_out, Data_in)
  begin
    Next_sum <= Data_out + Data_in;
  end process;
end architecture ten_rules;
```

Note: we could write the processes in any order, it would not change anything to the final result in simulation or in synthesis. This is because processes are concurrent statements and VHDL treats them as if they were really parallel.

## John Cooley’s design contest

This section is directly derived from John Cooley’s design contest at SNUG’95 (Synopsys Users Group meeting). The contest was intended to oppose VHDL and Verilog designers on the same design problem. What John had in mind was probably to determine what language was the most efficient. The results were that 8 out of the 9 Verilog designers managed to complete the design contest yet none of the 5 VHDL designers could. Hopefully, using the proposed method, we will do a much better job.

### Specifications

Our goal is to design in plain synthesizable VHDL (entity and architecture) a synchronous up-by-3, down-by-5, loadable, modulus 512 counter, with carry output, borrow output and parity output. The counter is a 9 bits unsigned counter so it ranges between 0 and 511. The interface specification of the counter is given in the following table:

| Name | Bit-width | Direction | Description |
| :--- | :---      | :-------- | :---------- |
| CLOCK | 1        | Input     | Master clock; the counter is synchronized on the rising edge of CLOCK |
| DI | 9 | Input | Data input bus; the counter is loaded with DI when UP and DOWN are both low |
| UP | 1 | Input | Up-by-3 count command; when UP is high and DOWN is low the counter increments by 3, wrapping around its maximum value (511) |
| DOWN | 1 | Input | Down-by-5 count command; when DOWN is high and UP is low the counter decrements by 5, wrapping around its minimum value (0) |
| CO | 1 | Output | Carry out signal; high only when counting up beyond the maximum value (511) and thus wrapping around |
| BO | 1 | Output | Borrow out signal; high only when counting down below the minimum value (0) and thus wrapping around |
| DO | 9 | Output | Output bus; the current value of the counter; when UP and DOWN are both high the counter retains its value |
| PO | 1 | Output | Parity out signal; high when the current value of the counter contains an even number of 1’s |

When counting up beyond its maximum value or when counting down below its minimum value the counter wraps around:

| Counter current value | UP DOWN | Counter next value | Next CO | Next BO | Next PO       |   
| :-----                | :------ | :------            | :------ | :------ | :------       |   
| x                     | 00      | DI                 | 0       | 0       | parity(DI)    |   
| x                     | 11      | x                  | 0       | 0       | parity(x)     |   
| 0 ≤ x ≤ 508           | 10      | x+3                | 0       | 0       | parity(x+3)   | 
| 509                   | 10      | 0                  | 1       | 0       | 1             |   
| 510                   | 10      | 1                  | 1       | 0       | 0             |   
| 511                   | 10      | 2                  | 1       | 0       | 0             |   
| 5 ≤ x ≤ 511           | 01      | x-5                | 0       | 0       | parity(x−5)   | 
| 4                     | 01      | 511                | 0       | 1       | 0             |   
| 3                     | 01      | 510                | 0       | 1       | 1             |   
| 2                     | 01      | 509                | 0       | 1       | 1             |   
| 1                     | 01      | 508                | 0       | 1       | 0             |   
| 0                     | 01      | 507                | 0       | 1       | 1             |

### Block diagram

Based on these specifications we can start designing a block diagram. Let us first represent the interface:

[![The external interface][4]][4]

Our circuit has 4 inputs (including the clock) and 4 outputs. The next step consists in deciding how many registers and combinatorial blocks we will use and what their roles will be. For this simple example we will dedicate one combinatorial block to the computation of the next value of the counter, the carry out and the borrow out. Another combinatorial block will be used to compute the next value of the parity out. The current values of the counter, the carry out and the borrow out will be stored in a register while the current value of the parity out will be stored in a separate register. The result is shown on the figure below:

[![Two combinatorial blocks and two registers][5]][5]

Checking that the block diagram complies with our 10 design rules is quickly done:

1. Our external interface is properly represented by the large surrounding rectangle.
2. Our 2 combinatorial blocks (round) and our 2 registers (square) are clearly separated.
3. We use only rising edge triggered registers.
4. We use only one clock.
5. We have 4 internal arrows (signals), 4 input arrows (input ports) and 4 output arrows (output ports).
6. None of our arrows has several origins. Three have several destinations (`clock`, `ndo` and `do`).
7. None of our 4 input arrows is an output of our internal blocks.
8. We have 4 output arrows, they represent our 4 output ports.
9. We have now exactly 4 internal signals (`nco`, `nbo`, `ndo` and `npo`).
10. There is only one cycle in the diagram, formed by `do` and `ndo`. There is a square block in the cycle.

### VHDL coding

Translating our block diagram in VHDL is straightforward. The current value of the counter ranges from 0 to 511, so we will use a 9-bits `bit_vector` signal to represent it. The only subtlety comes from the need to perform bitwise (like computing the parity) and arithmetic operations on the same data. The standard `numeric_bit_unsigned` package of library `ieee` solves this: it overloads the arithmetic operators such that they take any mixture of `bit_vector`, `bit` and integers. In order to compute the carry out and the borrow out we need one extra bit. We will thus use a 10-bits `bit_vector` temporary value.

The library declarations and the entity:
```vhdl
library ieee;
use ieee.numeric_bit_unsigned.all;

entity cooley is
  port(
        clock: in  bit;
        up:    in  bit;
        down:  in  bit;
        di:    in  bit_vector(8 downto 0);
        co:    out bit;
        bo:    out bit;
        po:    out bit;
        do:    out bit_vector(8 downto 0)
      );
end entity cooley;
```

The skeleton of the architecture is:
```vhdl
architecture arc1 of cooley is
  signal ndo: bit_vector(8 downto 0);
  signal nco: bit;
  signal nbo: bit;
  signal npo: bit;
begin
    <...processes...>
end architecture arc1;
```

Each of our 4 blocks is modeled as a process. The synchronous processes corresponding to our two registers are very easy to code. We simply use the pattern proposed in the [Coding](#coding) section. The register that stores the parity out flag, for instance, is coded:
```vhdl
  poreg: process(clock)
  begin
    if rising_edge(clock) then
      po <= npo;
    end if;
  end process poreg;
```

and the other register that stores `co`, `bo` and `do`:
```vhdl
  cobodoreg: process(clock)
  begin
    if rising_edge(clock) then
      co <= nco;
      bo <= nbo;
      do <= ndo;
    end if;
  end process cobodoreg;
```

The parity computation can use the unary version of the `xnor` operator:
```vhdl
  parity: process(ndo)
  begin
    npo <= xnor ndo;
  end process parity;
```

The last combinatorial process is the most complex of all but strictly applying the proposed translation method makes it easy too:
```vhdl
  u3d5: process(up, down, di, do)
    variable tmp: bit_vector(9 downto 0);
  begin
    tmp := (others => '0');
    nco <= '0';
    nbo <= '0';
    ndo <= (others => '0');
    if up = '0' and down = '0' then
      ndo <= di;
    elsif up = '1' and down = '1' then
      ndo <= do;
    elsif up = '1' and down = '0' then
      tmp := ('0' & do) + 3;
      ndo <= tmp(8 downto 0);
      nco <= tmp(9);
    elsif up = '0' and down = '1' then
      tmp := ('0' & do) - 5;
      ndo <= tmp(8 downto 0);
      nbo <= tmp(9);
    end if;
  end process u3d5;
```

Note that the two synchronous processes could also be merged. The complete code, with library and packages declarations, and with the proposed simplifications is as follows:
```vhdl
library ieee;
use ieee.numeric_bit_unsigned.all;

entity cooley is
  port(
        clock: in  bit;
        up:    in  bit;
        down:  in  bit;
        di:    in  bit_vector(8 downto 0);
        co:    out bit;
        bo:    out bit;
        po:    out bit;
        do:    out bit_vector(8 downto 0)
      );
end entity cooley;

architecture arc2 of cooley is
  signal ndo: bit_vector(8 downto 0);
  signal nco: bit;
  signal nbo: bit;
  signal npo: bit;
begin
  reg: process(clock)
  begin
    if rising_edge(clock) then
      co <= nco;
      bo <= nbo;
      po <= npo;
      do <= ndo;
    end if;
  end process reg;

  parity: process(ndo)
  begin
    npo <= xnor ndo;
  end process parity;

  u3d5: process(up, down, di, do)
    variable tmp: bit_vector(9 downto 0);
  begin
    tmp  := (others => '0');
    nco  <= '0';
    nbo  <= '0';
    ndo <= (others => '0');
    if up = '0' and down = '0' then
      ndo <= di;
    elsif up = '1' and down = '1' then
      ndo <= do;
    elsif up = '1' and down = '0' then
      tmp   := ('0' & do) + 3;
      ndo  <= tmp(8 downto 0);
      nco   <= tmp(9);
    elsif up = '0' and down = '1' then
      tmp   := ('0' & do) - 5;
      ndo  <= tmp(8 downto 0);
      nbo   <= tmp(9);
    end if;
  end process u3d5;
end architecture arc2;
```

### Going a bit further

The proposed method is simple and safe but it relies on several constraints that can be relaxed.

#### Skip the block diagram drawing

Experienced designers can skip the drawing of a block diagram for simple designs. But they still think hardware first. They draw in their head instead of on a sheet of paper but they somehow continue drawing.

#### Use asynchronous resets

There are circumstances where asynchronous resets (or sets) can improve the quality of a design. The proposed method supports only synchronous resets (that is resets that are taken into account on rising edges of the clock):
```vhdl
  process(clock)
  begin
    if rising_edge(clock) then
      if reset = '1' then
        o <= reset_value_for_o;
      else
        o <= i;
      end if;
    end if;
  end process;
```

The version with asynchronous reset modifies our template by adding the reset signal in the sensitivity list and by giving it the highest priority:
```vhdl
  process(clock, reset)
  begin
    if reset = '1' then
      o <= reset_value_for_o;
    elsif rising_edge(clock) then
      o <= i;
    end if;
  end process;
```

#### Merge several simple processes

We already used this in the final version of our example. Merging several synchronous processes, if they all have the same clock, is trivial. Merging several combinatorial processes in one is also trivial and is just a simple reorganization of the block diagram.

We can also merge some combinatorial processes with synchronous processes. But in order to do this we must go back to our block diagram and add an eleventh rule:

11. Group several round blocks and at least one square block by drawing an enclosure around them. Also enclose the arrows that can be. Do not let an arrow cross the boundary of the enclosure if it does not come or go from/to outside the enclosure. Once this is done, look at all the output arrows of the enclosure. If any of them comes from a round block of the enclosure or is also an input of the enclosure, we cannot merge these processes in a synchronous process. Else we can.

In our counter example, for instance, we could not group the two processes in the red enclosure of the following figure:

[![Processes that cannot be merged][6]][6]

because `ndo` is an output of the enclosure and its origin is a round (combinatorial) block. But we could group:

[![Processes that can be merged][7]][7]

The internal signal `npo` would become useless and the resulting process would be:
```vhdl
  poreg: process(clock)
  begin
    po <= xnor ndo;
  end process poreg;
```

which could also be merged with the other synchronous process:
```vhdl
  reg: process(clock)
  begin
    if rising_edge(clock) then
      co <= nco;
      bo <= nbo;
      do <= ndo;
      po <= xnor ndo;
    end if;
  end process reg;
```

The grouping could even be:

[![More grouping][8]][8]

Leading to the much simpler architecture:
```vhdl
architecture arc5 of cooley is
begin
  process(clock)
    variable ndo: bit_vector(9 downto 0);
  begin
    if rising_edge(clock) then
      ndo := '0' & do;
      co   <= '0';
      bo   <= '0';
      if up = '0' and down = '0' then
        ndo := '0' & di;
      elsif up = '1' and down = '0' then
        ndo := ndo + 3;
        co   <= ndo(9);
      elsif up = '0' and down = '1' then
        ndo := ndo - 5;
        bo   <= ndo(9);
      end if;
      po <= xnor ndo(8 downto 0);
      do <= ndo(8 downto 0);
    end if;
  end process;
end architecture arc5;
```

### Going even further

Level-triggered latches, falling clock edges, multiple clocks (and resynchronizers between clock domains), multiple drivers for the same signal, etc. are not evil. They are sometimes useful. But learning how to use them and how to avoid the associated pitfalls goes far beyond this short introduction to digital hardware design with VHDL.

[1]: /images/sequential_circuit_1-fig.png
[2]: /images/pipeline-fig.png
[3]: /images/sequential_circuit_2-fig.png
[4]: /images/cooley_1-fig.png
[5]: /images/cooley_2-fig.png
[6]: /images/cooley_3-fig.png
[7]: /images/cooley_4-fig.png
[8]: /images/cooley_5-fig.png

[^1]: In VHDL versions prior 2008 the output ports of an entity could be written but not read. Since VHDL 2008 ouptut ports can also be read. With pre-2008 versions of the language an output arrow must thus have one single origin and one single destination: the outside. No forks on output arrows, an output arrow cannot be also the input of one of your blocks. If you want to use an output arrow as an input for some of your blocks, insert a new round block to split it in two parts: the internal one, with as many forks as you wish, and the output arrow that comes from the new block and goes outside. The new block will become a simple continuous assignment in VHDL. A kind of transparent renaming.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
