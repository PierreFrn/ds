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

-- To allow the use of the "finish" procedure. Declaration of library "std" is
-- not needed, it is implicit.
use std.env.all;

-- This is just the exact VHDL translation of the specifications.
entity ct_sim is
    port(wire_out: out bit;
         led:      out bit_vector(3 downto 0));
end entity ct_sim;

architecture sim of ct_sim is

    -- Declare signals to connect to ports of "ct". They can have same names as
    -- ports or not.
    signal switch0: bit;
    signal wire_in: bit;

begin

    -- Instantiate entity/architecture of "ct" (from default library "work")
    -- and connect ports to signals. Thanks to this named association between
    -- ports and signals the order can be anything.
    u0: entity work.ct(rtl)
    port map(
        switch0  => switch0,  -- comma, not semi-colon
        wire_in  => wire_in,
        wire_out => wire_out,
        led      => led -- no comma!
    );

    -- Exercise all possible combinations of inputs. Replay first combination
    -- at the end to force a last value change.
    process
    begin
        switch0 <= '0';
        wire_in <= '0'; -- 00
        wait for 1 ns;
        -- No need to re-assign "switch0", by default it keeps its value.
        wire_in <= '1'; -- 01
        wait for 1 ns;
        switch0 <= '1'; -- 11
        wait for 1 ns;
        wire_in <= '0'; -- 10
        wait for 1 ns;
        switch0 <= '0'; -- 00
        finish; -- Stop the simulation.
    end process;

end architecture sim;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
