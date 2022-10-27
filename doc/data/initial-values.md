<!--
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
-->

# Initial values

## For simulation

At the beginning of a VHDL simulation, by default, a signal or variable takes the leftmost value of its type: `'0'` for the `bit` type, `'U'` for the `std_ulogic` type. `'U'` is the leftmost value in `std_ulogic` declaration and it means **U**ninitialized.

This `'U'` value of type `std_ulogic` is convenient in simulation because it clearly shows that the signal or variable has not been assigned yet and, in case its value is used before the first assignment, the computations will not work as expected. This is one of the various advantages of type `std_ulogic` over type `bit`. With `bit` the default initial value being `'0'`, things may look correct while they will not necessarily be in the final hardware.

## In real hardware

But in hardware there is nothing like the `'U'` value. We can roughly distinguish two types of hardware target technologies:

* The hardware target technologies that offer one form or another of initialization at power-up, like many FPGA targets. In FPGAs that support power-up initialization, all memory elements are initialized to a default value (usually `'0'`) just after power-up. **Warning**: never rely on this before having checked that your target FPGA supports power-up initialization.
* The other hardware target technologies, like the ones dedicated to custom integrated circuits. In these technologies, a wire that is not driven by a logic gate is floating and, if used in computations, can lead to any result. A consequence of this is that, in a circuit containing memory elements like registers, it is preferable to add a _reset_ mechanism that forces the value of all memory elements when the _reset_ input is asserted:

```vhdl
process(clk, reset) -- asynchronous reset
begin
  if reset = '1' then
    q <= '0';
  elsif rising_edge(clk) then
    q <= d;
  end if;
end process;
```

or:

```vhdl
process(clk) -- synchronous reset
begin
  if rising_edge(clk) then
    if reset = '1' then
      q <= '0';
    else
      q <= d;
    end if;
  end if;
end process;
```

## Initial values declarations

When declaring a signal or a variable, it is possible to also declare an initial value (note the `:=` assignment operator, even for signals):

```vhdl
signal q: std_ulogic := '1';
...
process
  variable v: std_ulogic := '0';
begin
  ...
end process;
```

This overwrites the default initial value for the signal or variable: instead of using the leftmost value of its type, the simulator will use the declared initial value. This is fine for simulation but what about synthesis? If the target hardware technology (and the logic synthesizer) supports it, this declared initial value can be used to initialize the hardware at power up. Else, a warning should be issued by the logic synthesizer, stating that this initial value declaration is ignored for synthesis. Moreover, even if the target hardware technology supports it, the initial value must make sense:

```vhdl
signal foo: std_ulogic := 'X';
```

is not synthesizable because the `X` value (unknown) does not make sense in hardware, it is useful only for simulation. Similarly, the signal or variable must correspond to a piece of hardware that can be initialized at power-up: it works only for signals or variable corresponding to the outputs of memory elements.

## Conclusion

This initial value declaration feature is apparently convenient but it is also dangerous and should be used with precautions:

* it does not work the same after synthesis on all target hardware technologies,
* even when it is supported for synthesis there are limitations (values, outputs of memory elements...),
* even when it is supported for synthesis it initializes the hardware only at power-up, while a real reset mechanism can be used anytime to re-initialize the hardware,
* if it is not supported for synthesis, the simulation and the final hardware may exhibit completely different behaviors.

Unless you have a very very good reason (for instance because it saves a lot of hardware resources or leads to a much faster design), it is probably better to not use initial value declarations for synthesizable designs.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0: -->
