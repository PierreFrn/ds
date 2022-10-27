-- MASTER-ONLY: DO NOT MODIFY THIS FILE
--
-- Copyright (C) Telecom Paris
-- Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)
-- 
-- This file must be used under the terms of the CeCILL. This source
-- file is licensed as described in the file COPYING, which you should
-- have received as part of this distribution. The terms are also
-- available at:
-- http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
--

-- The simulation environment has no inputs and no outputs. It is a black box
-- representing the whole universe.
entity sr_sim is
    generic(d: positive := 1000); -- Duration of test in clock cycles
end entity sr_sim;

-- For the "finish" procedure.
use std.env.all;

-- For the "std_ulogic" and "std_ulogic_vector" types.
library ieee;
use ieee.std_logic_1164.all;

-- "common.rnd_pkg" defines the "rnd_generator" protected type and all the
-- companion procedures and functions.
library common;
use common.rnd_pkg.all;

architecture sim of sr_sim is

    -- The signals that will connect the "sr" instance to its environment. They
    -- have the same names as the ports of "sr" because it is a natural choice
    -- but it is not mandatory at all.
    signal clk:      std_ulogic;
    signal sresetn:  std_ulogic;
    signal shift:    std_ulogic;
    signal din:      std_ulogic;
    signal dout:     std_ulogic_vector(3 downto 0);

begin

    -- Instance of "sr", named "dut" (for Design Under Test). The format of the
    -- associations is:
    --   generic-parameter-name => value
    --   port-name => signal
    -- Implicit ordered associations are also possible:
    --   generic map(4)
    --   port map(clk, sresetn, shift, din, dout)
    -- but they are less flexible and must consider the order of the
    -- declarations in entity "sr".
    dut: entity work.sr(rtl)
    generic map(n => 4)
    port map(
        clk     => clk,
        sresetn => sresetn,
        shift   => shift,
        din     => din,
        dout    => dout
    );

    -- Infinite 500 MHz clock generator.
    process
    begin
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
    end process;

    -- Generator of the other inputs of "sr".
    process
        -- A random generator
        variable r: rnd_generator;
    begin
        -- Start with a reset phase.
        sresetn <= '0';
        shift   <= '0';
        din     <= '0';
        -- Let 10 rising edges of clock go.
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;
        -- Deassert reset signal.
        sresetn <= '1';
        -- Loop over "d" clock cycles.
        for i in 1 to d loop
            -- Since VHDL 2008 the conditional when signal assignment is usable
            -- in processes. This one asserts the reset with probability 1/10.
            if r.get_integer(1, 10) = 1 then
                sresetn <= '0';
            else
                sresetn <= '1';
            end if;
            -- Assign uniform random values to "shift" and "din". The aggregate
            -- notation can be used in the LHS of assignments.
            (shift, din) <= r.get_std_ulogic_vector(2);
            -- Wait until next rising edge of clock (necessary for the applied
            -- stimulus to be taken into account by the "sr" instance).
            wait until rising_edge(clk);
        end loop;
        -- The "finish" procedure of the "std.env" package terminates the
        -- simulation. It has been introduced in VHDL 2008. Prior this,
        -- gracefully ending a simulation was a bit more difficult.
        finish;
    end process;

end architecture sim;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
