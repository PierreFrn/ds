<!--
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

# Generics

Generics are a way to parametrize an entity/architecture pair. The generic parameters are declared in the entity and can be used as constants everywhere else in the entity and architecture code. They can have a default value or not and their value can be assigned when instantiating the entity inside an encapsulating design.

```vhdl
entity subcircuit is
  generic(
    size: positive := 16
  );
  port(
    a: in  std_ulogic;
    b: in  std_ulogic_vector(1 to size);
    ...
    r: out std_ulogic;
    s: out std_ulogic_vector(7 downto 4)
  );
end entity subcircuit;

architecture arc of subcircuit is
...
end architecture arc;
...
entity circuit is
  port(
    a: in  std_ulogic;
    ...
    foo: out std_ulogic_vector(3 downto 0);
    ...
  );
end entity circuit;

architecture arc of circuit is
  ...
  signal bb:  std_ulogic_vector(36 downto 0);
  ...
begin
  ...
  u0: entity work.subcircuit(arc)
    generic map(
      size => 37
    )
    port map(
      a => a,
      b => bb,
      ...
      r => open,
      s => foo
    );
  ...
end architecture arc;
```

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
