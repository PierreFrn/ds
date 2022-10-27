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

entity timer is
    generic(
        f_mhz:  positive range 1 to 1000 := 100;
        max_us: natural := 10
    );
    port(
        clk:      in  std_ulogic;
        sresetn:  in  std_ulogic;
        tz:       in  std_ulogic;
        t:        out natural range 0 to max_us
    );
end entity timer;

architecture rtl of timer is

    -- Constraining integer ranges is important: out of range errors can be
    -- raised during simulation (easier debugging) and logic synthesizers infer
    -- less hardware (smaller, faster, more power efficient results).
    signal cnt: natural range 0 to f_mhz - 1;

begin

    -- The synchronous process is a straightforward VHDL translation of the
    -- natural language specification.
    process(clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0' or tz = '1' then
                cnt <= 0;
                t   <= 0;
            elsif t /= max_us then
                if cnt = f_mhz - 1 then
                    cnt <= 0;
                    t   <= t + 1;
                else
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process;

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
