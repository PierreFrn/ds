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

entity counter_sim is
    generic(
        n:    positive := 10000; -- duration of test in clock cycles
        cmax: natural := 5
    );
end entity counter_sim;

use std.env.all;

library ieee;
use ieee.std_logic_1164.all;

library common;
use common.rnd_pkg.all;

architecture sim of counter_sim is

    signal clk:      std_ulogic;
    signal sresetn:  std_ulogic;
    signal cz:       std_ulogic;
    signal inc:      std_ulogic;
    signal c:        natural range 0 to cmax;

begin

    counter0: entity work.counter(rtl)
    generic map(
        cmax => cmax
    )
    port map(
        clk     => clk,
        sresetn => sresetn,
        cz      => cz,
        inc     => inc,
        c       => c
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
        sresetn <= '0';
        cz      <= '0';
        inc     <= '0';
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;
        sresetn <= '1';
        for i in 1 to n loop
            if r.get_integer(1, 100) = 1 then
                sresetn <= '0';
            else
                sresetn <= '1';
            end if;
            if r.get_integer(1, 100) = 1 then
                cz <= '1';
            else
                cz <= '0';
            end if;
            inc     <= r.get_std_ulogic;
            wait until rising_edge(clk);
        end loop;
        finish;
    end process;

end architecture sim;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
