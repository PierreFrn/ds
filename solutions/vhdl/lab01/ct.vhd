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

-- This is just the exact VHDL translation of the specifications.
entity ct is
    port(
        switch0:  in  bit;
        wire_in:  in  bit;
        wire_out: out bit;
        led:      out bit_vector(3 downto 0) -- no semi-colon
    ); -- semi-colon!
end entity ct;

-- This is just the exact VHDL translation of the specifications.
--
-- Individual bit number "i" of a bit_vector object is accessed with the
-- "object(i)" notation. The "i" index must of course fall in the object's
-- index range; here, "led(4)" would be an error.
--
-- A concurrent signal assignments "sig <= expression;" is a shorthand for an
-- equivalent process; each time one of the signals appearing in the expression
-- changes, the expression is re-computed and the result is assigned to the
-- target signal.
architecture rtl of ct is
begin
    led(0)   <= '1';
    led(1)   <= '0';
    led(2)   <= wire_in;
    led(3)   <= not wire_in;
    wire_out <= switch0;
end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
