library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;


entity sr is
  generic(
    n : positive := 16
  );
  port(
    clk     : in  std_ulogic;
    sresetn : in  std_ulogic;
    shift   : in  std_ulogic;
    din     : in  std_ulogic;
    dout    : out std_ulogic_vector(n-1 downto 0)
  );
end entity sr;

architecture rtl of sr is
  begin
  process(clk)
  begin
    if rising_edge(clk) then
      if not sresetn then
        dout <= (others => '0');
      else
        if shift then
          dout <= dout(n-2 downto 0) & din;
        end if;
      end if;
    end if;
  end process;
end architecture rtl;
