library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity edge is
  port(
    clk : in std_ulogic;
    sresetn : in std_ulogic;
    data_in : in std_ulogic;
    re : out std_ulogic;
    fe : out std_ulogic
  );
end entity edge;

architecture rtl of edge is

  signal tmp : std_ulogic_vector(2 downto 0);

begin

  sr3: entity work.sr(rtl)
  
    generic map(n => 3)
  
    port map(
    clk => clk,
    sresetn => sresetn,
    shift => '1',
    din => data_in,
    dout => tmp
    );

    re <= (not tmp(2)) and (tmp(1));
    fe <= (tmp(2)) and (not tmp(1));

end architecture rtl;
