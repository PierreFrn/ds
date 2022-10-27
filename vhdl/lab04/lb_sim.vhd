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

entity lb_sim is
    generic(
        n:        positive                    := 10; -- duration of test in delay_us
        f_mhz:    positive range 1 to 1000    := 7;
        delay_us: positive range 1 to 1000000 := 5
    );
end entity lb_sim;

use std.env.all;

library ieee;
use ieee.std_logic_1164.all;

architecture sim of lb_sim is

    signal clk:    std_ulogic;
    signal areset: std_ulogic;
    signal led:    std_ulogic_vector(3 downto 0);

begin

    lb0: entity work.lb(rtl)
    generic map(
        f_mhz    => f_mhz,
        delay_us => delay_us
    )
    port map(
        clk    => clk,
        areset => areset,
        led    => led
    );

    process
        constant period: time := (1 sec) / (1.0e6 * real(f_mhz));
    begin
        clk <= '0';
        wait for period / 2.0;
        clk <= '1';
        wait for period / 2.0;
    end process;

    process
    begin
        areset <= '1';
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;
        areset <= '0';
        wait for n * delay_us * (1 us);
        areset <= '1';
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;
        areset <= '0';
        wait for n * delay_us * (1 us);
        finish;
    end process;

end architecture sim;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
