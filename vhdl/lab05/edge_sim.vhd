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

entity edge_sim is
    generic(
        n: positive := 1000 -- duration of test in clock cycles
    );
end entity edge_sim;

use std.env.all;

library ieee;
use ieee.std_logic_1164.all;

library common;
use common.rnd_pkg.all;

architecture sim of edge_sim is

    signal clk:      std_ulogic;
    signal sresetn:  std_ulogic;
    signal data_in:  std_ulogic;
    signal re:       std_ulogic;
    signal fe:       std_ulogic;

    constant clock_period: time := 2 ns;

begin

    edge0: entity work.edge(rtl)
    port map(
        clk     => clk,
        sresetn => sresetn,
        data_in => data_in,
        re      => re,
        fe      => fe
    );

    process
    begin
        clk <= '0';
        wait for clock_period / 2;
        clk <= '1';
        wait for clock_period / 2;
    end process;

    process
        variable r: rnd_generator;
    begin
        sresetn <= '0';
        data_in <= '0';
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;
        sresetn <= '1';
        for i in 1 to n loop
            if r.get_integer(1, 10) = 1 then
                sresetn <= '0';
            else
                sresetn <= '1';
            end if;
            wait for (0.25 + r.get_real / 2.0) * clock_period;
            data_in <= r.get_std_ulogic;
            wait until rising_edge(clk);
        end loop;
        finish;
    end process;

end architecture sim;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
