library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity timer is
  generic(
    f_mhz : positive range 1 to 1000 := 100;
    max_us : natural := 10
  );
  port(
    clk : in std_ulogic;
    sresetn : in std_ulogic;
    tz : in std_ulogic;
    t : out natural range 0 to max_us
  );
end entity timer;

architecture rtl of timer is

  signal cnt : natural range 0 to f_mhz-1;

  begin
  process(clk)
  begin
    if rising_edge(clk) then
      if not sresetn then
        cnt <= 0;
      elsif tz then
        cnt <= 0;
      elsif t /= max_us then
        if cnt = f_mhz-1 then
          cnt <= 0;
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if not sresetn then
        t <= 0;
      elsif tz then
        t <= 0;
      elsif t /= max_us then
        if cnt = f_mhz-1 then
          t <= t + 1;
        end if;
      end if;
    end if;
  end process;
end architecture rtl;
