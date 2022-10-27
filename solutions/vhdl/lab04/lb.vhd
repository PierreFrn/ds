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

library ieee;
use ieee.std_logic_1164.all;

entity lb is
    generic(
        f_mhz:    positive range 1 to 1000    := 1;
        delay_us: positive range 1 to 1000000 := 1
    );
    port(
        clk:      in  std_ulogic;
        areset:   in  std_ulogic;
        led:      out std_ulogic_vector(3 downto 0)
    );
end entity lb;

architecture rtl of lb is

    -- parallel output of reset resynchronizer
    signal sync:          std_ulogic_vector(1 downto 0);
    -- synchronous active low reset
    alias  sresetn:       std_ulogic is sync(1);
    -- timer output
    signal t:             natural range 0 to delay_us;
    -- set to '1' when timer reaches delay_us
    signal t_eq_delay_us: std_ulogic;
    -- serial input of 4-bits shift register
    signal sr4_in:        std_ulogic;

begin

    -- 2-stages resynchronizer for reset
    sr2: entity work.sr(rtl)
    generic map(n => 2)
    port map(
        clk     => clk,
        sresetn => '1',
        shift   => '1',
        din     => not areset,
        dout    => sync
    );

    -- timer
    timer0: entity work.timer(rtl)
    generic map(
        f_mhz  => f_mhz,
        max_us => delay_us
    )
    port map(
        clk     => clk,
        sresetn => sresetn,
        tz      => t_eq_delay_us,
        t       => t
    );

    -- delay_us detector
    t_eq_delay_us <= '1' when t = delay_us else '0';

    -- 2-inputs multiplexer
    sr4_in <= led(3) when or led = '1' else '1';

    -- 4-bits shift register
    sr4: entity work.sr(rtl)
    generic map(n => 4)
    port map(
        clk     => clk,
        sresetn => sresetn,
        shift   => t_eq_delay_us,
        din     => sr4_in,
        dout    => led
    );

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
