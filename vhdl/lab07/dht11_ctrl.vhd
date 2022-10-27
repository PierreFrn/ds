library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity dht11_ctrl is

  generic(
    f_mhz : positive := 125;
    start_us : positive := 18000;
    warm_us : positive := 1000000
  );

  port(
    clk     : in  std_ulogic;
    sresetn : in  std_ulogic;
    data_in : in  std_ulogic;
    force0  : out std_ulogic;
    dso     : out std_ulogic;
    cerr    : out std_ulogic;
    tp      : out std_ulogic_vector(7 downto 0);
    rh      : out std_ulogic_vector(7 downto 0)
  );

end entity dht11_ctrl;

architecture rtl of dht11_ctrl is

  type state_t is (reset, warm_up, start_up, receive);
  
  -- signals to handle shift register
  signal cs : std_ulogic_vector(7 downto 0);
  signal shift : std_ulogic;
  signal data_sync : std_ulogic;
  signal reg_data : std_ulogic_vector(23 downto 0);

  -- signals to handle timer
  signal tz : std_ulogic;
  signal t : natural range 0 to warm_us;

  -- signals to handle counter
  signal inc : std_ulogic;
  signal cz : std_ulogic;
  signal c : natural range 0 to 42;

  -- signals to handle edge detector and resynchronizer
  signal re : std_ulogic;
  signal fe : std_ulogic;

  -- signals to handle stateMachine
  signal state : state_t;
  signal next_state : state_t;
  
  signal timer_save : natural range 0 to warm_us;



  begin

  sr24: entity work.sr(rtl)

    generic map(n => 24)

    port map(
    clk => clk,
    sresetn => sresetn,
    shift => shift,
    din => data_sync,
    dout => reg_data
    );

  timer0: entity work.timer(rtl)

    generic map(
    f_mhz => f_mhz,
    max_us => warm_us
    )

    port map(
    clk => clk,
    sresetn => sresetn,
    tz => tz,
    t => t
    );

  counter42: entity work.counter(rtl)

    generic map(cmax => 42)

    port map(
    clk => clk,
    sresetn => sresetn,
    cz => cz,
    inc => inc,
    c => c
    );

  edge0: entity work.edge(rtl)

    port map(
    clk => clk,
    sresetn => sresetn,
    data_in => data_in,
    re => re,
    fe => fe
    );


  stateMachine: process(clk)
  begin
  if rising_edge(clk) then
    if not sresetn then
      state <= reset;
      next_state <= warm_up;

    elsif state = reset then
      state <= next_state;
    elsif state = warm_up then
      if t = warm_us then
        state <= reset;
        next_state <= start_up;
      end if;
      
    elsif state = start_up then
      if (t = start_us) then
        state <= reset;
        next_state <= receive;
      end if;
      
    elsif state = receive then
      if (t = start_us) then 
        state <= reset;
        next_state <= warm_up;
      elsif (c = 42) and (t = 50) then
        state <= reset;
        next_state <= warm_up;
      end if;
    end if;
  end if;
  end process stateMachine;
  
  cerr <= '0' when tp+rh=cs else '1';

  rh <= reg_data(23 downto 16);
  tp <= reg_data(15 downto  8);
  cs <= reg_data( 7 downto  0);

  force0    <= '1' when not ((state = start_up) and (sresetn = '1'))                            else '0';
  dso       <= '1' when (c = 42) and (t = 50)                                                   else '0';
  tz        <= '1' when (state = reset) or (fe = '1')                                           else '0';
  cz        <= '1' when (state = reset)                                                         else '0';
  inc       <= '1' when (fe = '1') and (state = receive)                                        else '0';
  --shift     <= '1' when (fe = '1') and ((c > 1 and c < 10) or (c > 17 and c < 26) or (c > 34))  else '0';
  --data_sync <= '1' when (t >= 100)                                                              else '0';
  
  process(clk)
  begin
  if rising_edge(clk) then
    if not sresetn then
      data_sync <= '0';
    elsif (t >= 100) then
      data_sync <= '1';
    else
      data_sync <= '0';
    end if;
  end if;
  end process;
  
  process(clk)
  begin
  if rising_edge(clk) then
    if not sresetn then
      shift <= '0';
    elsif (fe = '1') and ((c > 1 and c < 10) or (c > 17 and c < 26) or (c > 33)) then
      shift <= '1';
    else
      shift <= '0';
    end if;
  end if;
  end process;

end architecture rtl;
