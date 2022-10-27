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

entity timer_sim is
    generic(
        d:      positive                 := 1000; -- duration of test in clock cycles
        f_mhz:  positive range 1 to 1000 := 2;
        max_us: natural                  := 3
    );
end entity timer_sim;

use std.env.all;

library ieee;
use ieee.std_logic_1164.all;

library common;
use common.rnd_pkg.all;

architecture sim of timer_sim is

    signal clk:      std_ulogic;
    signal sresetn:  std_ulogic;
    signal tz:       std_ulogic;
    signal t:        natural range 0 to max_us;

begin

    timer0: entity work.timer(rtl)
    generic map(
        f_mhz  => f_mhz,
        max_us => max_us
    )
    port map(
        clk     => clk,
        sresetn => sresetn,
        tz      => tz,
        t       => t
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
        tz      <= '0';
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;
        sresetn <= '1';
        for i in 1 to d loop
            -- Reset with 1/10 probability
            if r.get_integer(1, 10) = 1 then
                sresetn <= '0';
            else
                sresetn <= '1';
            end if;
            -- Zero timer with 1/10 probability
            if r.get_integer(1, 10) = 1 then
                tz <= '1';
            else
                tz <= '0';
            end if;
            wait until rising_edge(clk);
        end loop;
        finish;
    end process;

end architecture sim;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
