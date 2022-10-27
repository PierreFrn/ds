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

entity edge is
    port(
        clk:      in  std_ulogic;
        sresetn:  in  std_ulogic;
        data_in:  in  std_ulogic;
        re:       out std_ulogic;
        fe:       out std_ulogic
    );
end entity edge;

architecture rtl of edge is

    signal sync: std_ulogic_vector(2 downto 0);

begin

    sr0: entity work.sr(rtl)
    generic map(
        n => 3
    )
    port map(
        clk     => clk,
        sresetn => sresetn,
        shift   => '1',
        din     => data_in,
        dout    => sync
    );

    re <= sync(1) and (not sync(2));
    fe <= (not sync(1)) and sync(2);

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
