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

-- These declarations are needed to use the "std_ulogic" and
-- "std_ulogic_vector" types. The use of library "ieee" must be declared
-- because, different from "std", it is not implicit.
library ieee;
use ieee.std_logic_1164.all;

-- All ports use the "std_ulogic" or "std_ulogic_vector" type. Never, never use
-- "std_logic" or "std_logic_vector" if you do not intend to drive a signal
-- with multiple processes.
entity sr is
    generic(n: positive := 16);
    port(
        clk:     in  std_ulogic;
        sresetn: in  std_ulogic;
        shift:   in  std_ulogic;
        din:     in  std_ulogic;
        dout:    out std_ulogic_vector(n-1 downto 0)
    );
end entity sr;

architecture rtl of sr is

begin

    -- Synchronous process with synchronous reset; the only signal in the
    -- sensitivity list is the clock.
    process(clk)
    begin
        if rising_edge(clk) then
            -- Synchronous active low reset has the highest priority.
            if sresetn = '0' then
                -- Aggregate notation helps writing more generic code. There is
                -- no need to consider "dout" size, indexing direction or
                -- indexing bounds.
                dout <= (others => '0');
            elsif shift = '1'  then
                -- "dout" is in the RHS of the assignment. It is thus read and
                -- cannot be an output port in VHDL prior 2008. Writing this
                -- assignment in a more generic way without assumptions about
                -- the indexing is left as exercise.
                dout <= dout(n-2 downto 0) & din;
            end if;
            -- No else clause. This is OK because this is not a combinatorial
            -- process. It means: "in all other cases "dout" does not change
            -- (keep its value)".
        end if;
    end process;

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
