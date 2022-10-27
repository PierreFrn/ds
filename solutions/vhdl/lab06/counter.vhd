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

entity counter is
    generic(
        cmax: natural
    );
    port(
        clk:      in  std_ulogic;
        sresetn:  in  std_ulogic;
        cz:       in  std_ulogic;
        inc:      in  std_ulogic;
        c:        out natural range 0 to cmax
    );
end entity counter;

architecture rtl of counter is

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0' or cz = '1' then
                c <= 0;
            elsif c < cmax and inc = '1' then
                c <= c + 1;
            end if;
        end if;
    end process;

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
