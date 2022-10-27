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

package vcomponents is

  component iobuf
  generic(
    drive:        integer := 12;
    ibuf_low_pwr: boolean := true;
    iostandard:   string  := "DEFAULT";
    slew:         string  := "SLOW"
  );
  port(
    o:  out   std_ulogic;
    io: inout std_ulogic;
    i:  in    std_ulogic;
    t:  in    std_ulogic
  );
  end component iobuf;

end package vcomponents;

library ieee;
use ieee.std_logic_1164.all;

entity iobuf is
  generic(
    drive:        integer := 12;
    ibuf_low_pwr: boolean := true;
    iostandard:   string  := "DEFAULT";
    slew:         string  := "SLOW"
  );
  port(
    o:  out   std_ulogic;
    io: inout std_ulogic;
    i:  in    std_ulogic;
    t:  in    std_ulogic
  );
end entity iobuf;

architecture rtl of iobuf is
begin

  o  <= to_x01(io);
   
  io <= 'Z' when t = '1' or t = 'H' else
        'U' when t = 'U' else
        '1' when (t = '0' or t = 'L') and (i = '1' or i = 'H') else
        '0' when (t = '0' or t = 'L') and (i = '0' or i = 'L') else
        'U' when (t = '0' or t = 'L') and i = 'U' else
        'X';

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
