<!--
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

# Arithmetic: which types to use?

## Integer types versus arithmetic vector types

Integer types are synthesizable, so when modelling a synthesizable design with some arithmetic, they can perfectly be the right choice.
Several standard packages (`ieee.numeric_bit_unsigned`, `ieee.numeric_bit`, `ieee.numeric_std_unsigned`, `ieee.numeric_std`) overload the arithmetic operators for vector types.
They can thus also be used for arithmetic.
This document presents only the `ieee.numeric_std_unsigned` package as it suffices for this course.

In a synthesizable design, 32 bits signed integers can be represented either by the native `integer` type or by `std_ulogic_vector(31 downto 0)`.
Which type to use in which case is a subtle question.
Answering it requires to know several things about these types and how simulators and synthesizers interpret them:

* The VHDL standard requires that the `integer` type is represented on at least 32 bits and that its range includes lest -2^31 +1 to 2^31 -1.
Note that, different from many programming languages, -2^31 may be out of the integer range.
Specific implementations can have wider ranges (e.g., include -2^31 or extend to 64 bits).
Using the type `integer` for a variable or signal with a smaller range has two major drawbacks:
  * The simulator cannot accurately detect out of range situations.
  * The synthesizer will probably allocate 32 bits and may produce a larger and/or slower implementation than what is actually needed.
* There is no automatic wrapping with integer types.
An error is raised during simulations if an out of range situation is detected.
This may be an advantage for debugging but it may also be a drawback if the intended behaviour is the automatic wrapping.
* With vector types the wrapping is automatic in case of overflow or underflow, in simulation and in synthesis.
This can be convenient if it is the expected behaviour but it can also prevent the detection of unwanted situations during simulations.
* For most logic synthesizers integer types are finally implemented as vectors of bits with a given fixed width; overflows or underflows lead to wrapping, not errors (that do not really make sense in hardware).
The behaviours of the simulation and the synthesized hardware are thus different.
* There is no simple way to model bit-wise operations on integer types; it is much easier with vector types.
* The only way to constrain the range of a vector type is by its bit-width.
Their bounds are always powers of two while they can be anything with integer types.

As a consequence, the use of integer types is recommended in situations where there is only a need for arithmetic operations, not for bit-wise operations, and the automatic wrapping around power of two bounds is not desired.
The range shall always be constrained to the smallest.
This will help the debugging during simulations and improve the performance / size after synthesis:

```vhdl
signal i: integer range 12 to 47;
...
  i <= i + 3;
...
```

In other situations, the use of the `std_ulogic_vector` is probably a better choice:

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
...
signal u, v:     std_ulogic_vector(7 downto 0);
signal msb:      std_ulogic;
signal not_zero: std_ulogic;
...
  u <= u + v;
...
  u <= u + 7; -- Mix of vector and integer operands
...
  msb      <= u(7);
  not_zero <= or v;
```

## Conversion functions

The `ieee.numeric_std_unsigned` package defines conversion functions between vector types and integer types:

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
...
signal i: integer range 0 to 255;
signal u: std_ulogic_vector(7 downto 0);
...
  i <= to_integer(u);
...
  u <= to_stdulogicvector(i, 8); -- convert on 8 bits
```

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
