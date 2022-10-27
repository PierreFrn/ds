library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity lb is
  generic(
    f_mhz : positive range 1 to 1000 := 100;
    delay_us : positive range 1 to 1000000 := 10
  );
  port(
    clk : in std_ulogic;
    areset : in std_ulogic;
    led : out std_ulogic_vector(3 downto 0)
  );
end entity lb;

architecture rtl of lb is

  signal sresetn : std_ulogic;
  signal areset_resync : std_ulogic_vector(1 downto 0);

  signal cnt : natural range 0 to f_mhz-1;
  signal t : natural range 0 to delay_us;

  signal sresetn_pushed : std_ulogic;

begin
  process(clk)
  begin
    if rising_edge(clk) then
      areset_resync(1) <= areset_resync(0);
      areset_resync(0) <= areset;
    end if;
  end process;

  process(areset_resync(1))
  begin
    sresetn <= not areset_resync(1);
  end process;


  process(clk)
  begin
    if rising_edge(clk) then
      if not sresetn then
        cnt <= 0;
      elsif t /= delay_us then
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
      elsif t = delay_us then
        t <= 0;
      else
        if cnt = f_mhz-1 then
          t <= t + 1;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if not sresetn then
        led <= (others => '0');
      elsif t = delay_us then
        if nor led then
          led <= "0001";
        else
          led <= led(2 downto 0) & led(3);
        end if;
      end if;
    end if;
  end process;

end architecture rtl;
