<!--
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

# Unconstrained types

It is possible to define unconstrained array types, that is, array types which lengths are not defined. Several standard array types are unconstrained (`bit_vector`, `string`, `std_ulogic_vector`...) This feature is extremely convenient to write generic, highly reusable, code. Of course, when declaring an object (signal, variable, constant...) of unconstrained type, the constraint must be specified:

```vhdl
signal v: bit_vector(47 downto 12);
```

Thanks to this feature, subprograms, entities and architectures can be written in a very generic way:

```vhdl
entity rbo is
  port(din:  in  bit_vector;
       dout: out bit_vector);
end entity rbo;

architecture arc of rbo is
  function reverse_bit_order(v: bit_vector) return bit_vector is
  begin
    ...
  end function reverse_bit_order;
begin
  dout <= reverse_bit_order(din);
end architecture arc;
```

As when declaring objects, the constraints must be given when calling subprograms or instantiating entities:

```vhdl
architecture sim of rbo_sim is
  signal a, b, c: bit_vector(13 to 19);
begin
  u0: entity work.rbo(arc) port map(a, b);
  c <= reverse_bit_order(b);
  assert a = c report "error" severity failure;
  ...
end architecture rbo_sim;
```

Of course, generic code must work in all possible contexts. A common mistake consists in implicitly assuming that vectors have a given direction or bound. In the code of the `reverse_bit_order` function shown above, it would be a mistake to consider that vector `v` is of type `bit_vector(n downto 0)` for some value `n`. The function could well be called with a parameter of type `bit_vector(3 to 67)`...

Attributes exist that can be used to request the shape of objects. The `length` attribute, for instance, evaluates as the size of a vector. Using intermediate local copies with known declarations frequently simplifies the design of generic code:

```vhdl
function reverse_bit_order(v: bit_vector) return bit_vector is
  constant n:   natural                  := v'length; -- length attribute
  constant tmp: bit_vector(n-1 downto 0) := v;        -- local copy with known direction and right bound
  variable res: bit_vector(n-1 downto 0);             -- result variable with known direction and right bound
begin
  for i in 0 to n-1 loop
    res(i) := tmp(n-1-i);
  end loop;
  return res;
end function reverse_bit_order;
```

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
