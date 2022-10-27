<!--
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

# Entity instantiations

## Principles of hierarchical descriptions with entity instantiations

The easiest way to model a design using a hierarchical (structural) approach is the entity instantiation. Any already designed entity/architecture pair can be used as a sub-circuit of another entity/architecture pair:

```vhdl
entity BOTTOM is
  generic(
    G0: G0_TYPE [:= G0_VALUE];
    ...
  );
  port(
    P0: P0_DIRECTION P0_TYPE;
    ...
  );
end entity BOTTOM;

architecture BARC of BOTTOM is
...
end architecture BARC;
...
entity TOP is
...
end entity TOP;

architecture TARC of TOP is
begin
  U0: entity LIB.BOTTOM(ARC)
    generic map(
      G0 => EXPRESSION,
      ...
    )
    port map(
      P0 => EXPRESSION,
      ...
    );
end architecture TARC;
```

> Note: the main drawback of this approach is that the higher hierarchy level can be compiled only after the lower. It is a bottom-up design strategy. While perfectly acceptable for simple projects, it may become sub-optimal for complex designs. Top-down approaches are possible using VHDL component declarations, component instantiations and configurations. They are more powerful but significantly more verbose and difficult to understand.

The generic parameters of the instantiated entity are associated to constant static expressions (that is, expressions that evaluate as a constant value during the elaboration of the design). The association can be omitted for generic parameters with a declared default value.

The ports of the instantiated entity are associated to expressions or to the `open` keyword. Expressions can involve signals or ports of the instantiating architecture. The `open` association cannot be used on an input port, unless it was declared with a default value. Example of a four-bits adder made of four instances of a one-bit adder:

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity ONE_BIT_ADDER is
  generic(
    DEBUG: boolean := false
  );
  port(
    A, B, CI: in  std_ulogic;
    S, CO:    out std_ulogic
  );
end entity ONE_BIT_ADDER;

architecture ARC1 of ONE_BIT_ADDER is
begin
  S  <= A xor B xor CI;
  CO <= (A and B) or (A and CI) or (B and CI);
  process(S, CO)
  begin
    if DEBUG then
      assert true report "S=" & to_string(S) & ", CO=" & to_string(CO) severity note;
    end if;
  end process;
end architecture ARC1;

library ieee;
use ieee.std_logic_1164.all;

entity FOUR_BITS_ADDER is
  generic(
    QUIET: boolean
  );
  port(
    X, Y: in  std_ulogic_vector(3 downto 0);
    SUM:  out std_ulogic_vector(3 downto 0)
  );
end entity FOUR_BITS_ADDER;

architecture ARC4 of FOUR_BITS_ADDER is
  signal C:  std_ulogic_vector(3 downto 1);
begin
  U0: entity work.ONE_BIT_ADDER(ARC1)
    port map(
      A  => X(0),
      B  => Y(0),
      CI => '0',
      S  => SUM(0),
      CO => C(1)
    );
  U1: entity work.ONE_BIT_ADDER(ARC1)
    generic map(
      DEBUG => not QUIET
    )
    port map(
      A  => X(1),
      B  => Y(1),
      CI => C(1),
      S  => SUM(1),
      CO => C(2)
    );
  U2: entity work.ONE_BIT_ADDER(ARC1)
    generic map(
      DEBUG => true
    )
    port map(
      A  => X(2),
      B  => Y(2),
      CI => C(2),
      S  => SUM(2),
      CO => C(3)
    );
  U3: entity work.ONE_BIT_ADDER(ARC1)
    port map(
      A  => X(3),
      B  => Y(3),
      CI => C(3),
      S  => SUM(3),
      CO => open
    );
end architecture ARC4;
```

The `U0` and `U3` instances use the default value (`false`) of the `DEBUG` generic parameter of `ONE_BIT_ADDER` while `U1` uses an expression (that involves the `QUIET` generic parameter of `FOUR_BITS_ADDER`) and `U2` uses a constant expression (`true`).

The ports of the instances are associated to expressions, most of which are simply names of signals or ports of `FOUR_BITS_ADDER(ARC4)`, or slices of them. Note that `FOUR_BITS_ADDER` has not input carry (it is implictly `'0'`) and no output carry (it is ignored). The `CI` port of the `U0` instance is thus associated to the constant expression `'0'` and the `CO` output port of the `U3` instance is declared `open`.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
