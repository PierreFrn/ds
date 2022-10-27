library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity dht11_ctrl_axi_wrapper is

  generic(
    f_mhz    : positive := 125;
    start_us : positive := 18000;
    warm_us  : positive := 1000000
  );

  port(
    aclk           : in    std_ulogic;
    aresetn        : in    std_ulogic;
    s0_axi_araddr  : in    std_ulogic_vector(11 downto 0);
    s0_axi_arvalid : in    std_ulogic;
    s0_axi_arready : out   std_ulogic;
    s0_axi_awaddr  : in    std_ulogic_vector(11 downto 0);
    s0_axi_awvalid : in    std_ulogic;
    s0_axi_awready : out   std_ulogic;
    s0_axi_wdata   : in    std_ulogic_vector(31 downto 0);
    s0_axi_wstrb   : in    std_ulogic_vector(3 downto 0);
    s0_axi_wvalid  : in    std_ulogic;
    s0_axi_wready  : out   std_ulogic;
    s0_axi_rdata   : out   std_ulogic_vector(31 downto 0);
    s0_axi_rresp   : out   std_ulogic_vector(1 downto 0);
    s0_axi_rvalid  : out   std_ulogic;
    s0_axi_rready  : in    std_ulogic;
    s0_axi_bresp   : out   std_ulogic_vector(1 downto 0);
    s0_axi_bvalid  : out   std_ulogic;
    s0_axi_bready  : in    std_ulogic;
    data           : inout std_logic;
    led            : out   std_ulogic_vector(3 downto 0)
  );

end entity dht11_ctrl_axi_wrapper;


architecture rtl of dht11_ctrl_axi_wrapper is

  type axi_write_state_t is (standby, decerr, decerr_wait, slverr, slverr_wait);
  type axi_read_state_t  is (standby, valid, valid_wait, decerr, decerr_wait);
  
  signal axi_write_state : axi_write_state_t;
  signal axi_read_state  : axi_read_state_t;
  

  signal data_ctrl : std_ulogic;
  signal force0    : std_ulogic;
  signal dso       : std_ulogic;
  signal cerr      : std_ulogic;
  signal tp        : std_ulogic_vector(7 downto 0);
  signal rh        : std_ulogic_vector(7 downto 0);
  
  signal v_reg  : std_ulogic;
  signal rh_reg : std_ulogic_vector(7 downto 0);
  signal tp_reg : std_ulogic_vector(7 downto 0);

  begin
  
  dht11_ctrl0: entity work.dht11_ctrl(rtl)
    
    generic map(
    f_mhz => f_mhz,
    start_us => start_us,
    warm_us => warm_us
    )
    
    port map(
    clk     => aclk,
    sresetn => aresetn,
    data_in => data_ctrl,
    force0  => force0,
    dso     => dso,
    cerr    => cerr,
    tp      => tp,
    rh      => rh
    );


  data <= '0' when not force0 else 'Z';
  
  data_ctrl <= '0' when data = '0' else '1';
  
  led <= v_reg & '0' & rh_reg(0) & tp_reg(0);
  
  registers: process(aclk)
  begin
    if rising_edge(aclk) then
      if not aresetn then
        v_reg <= '0';
        rh_reg <= (others => '0');
        tp_reg <= (others => '0');
      elsif dso = '1' and cerr = '0' then
        v_reg <= '1';
        rh_reg <= rh;
        tp_reg <= tp;
      end if;
    end if;
  end process registers;
  
  
  axi_write_state_machine: process(aclk)
  begin
    if rising_edge(aclk) then
      if not aresetn then
        axi_write_state <= standby;
      elsif axi_write_state = standby then
        if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' and s0_axi_awaddr < 4 then
          axi_write_state <= slverr;
        elsif s0_axi_awvalid = '1' and s0_axi_wvalid = '1' and s0_axi_awaddr >= 4 then
          axi_write_state <= decerr;
        end if;
      elsif axi_write_state = slverr then
        if s0_axi_bready = '1' then
          axi_write_state <= standby;
        else
          axi_write_state <= slverr_wait;
        end if;
      elsif axi_write_state = slverr_wait then
        if s0_axi_bready = '1' then
          axi_write_state <= standby;
        end if;
      elsif axi_write_state = decerr then
        if s0_axi_bready = '1' then
          axi_write_state <= standby;
        else
          axi_write_state <= decerr_wait;
        end if;
      elsif axi_write_state = decerr_wait then
        if s0_axi_bready = '1' then
          axi_write_state <= standby;
        end if;  
      end if;
    end if;
  end process axi_write_state_machine;
  
  s0_axi_awready <= '1'  when (axi_write_state = decerr) or (axi_write_state = slverr) else '0';
  s0_axi_wready  <= '1'  when (axi_write_state = decerr) or (axi_write_state = slverr) else '0';
  s0_axi_bvalid  <= '0'  when axi_write_state = standby else '1';
  s0_axi_bresp   <= "10" when (axi_write_state = slverr) or (axi_write_state = slverr_wait) else "11";
  
  axi_read_state_machine: process(aclk)
  begin
    if rising_edge(aclk) then
      if not aresetn then
        axi_read_state <= standby;
      elsif axi_read_state = standby then
        if s0_axi_arvalid = '1' and s0_axi_araddr < 4 then
          axi_read_state <= valid;
        elsif s0_axi_arvalid = '1' and s0_axi_araddr >= 4 then
          axi_read_state <= decerr;
        end if;
      elsif axi_read_state = valid then
        if s0_axi_rready = '1' then
          axi_read_state <= standby;
        else
          axi_read_state <= valid_wait;
        end if;
      elsif axi_read_state = valid_wait then
        if s0_axi_rready = '1' then
          axi_read_state <= standby;
        end if;
      elsif axi_read_state = decerr then
        if s0_axi_rready = '1' then
          axi_read_state <= standby;
        else
          axi_read_state <= decerr_wait;
        end if;
      elsif axi_read_state = decerr_wait then
        if s0_axi_rready = '1' then
          axi_read_state <= standby;
        end if;  
      end if;
    end if;
  end process axi_read_state_machine;
  
  s0_axi_arready <= '1' when (axi_read_state = decerr) or (axi_read_state = valid) else '0';
  s0_axi_rvalid <= '0' when axi_read_state = standby else '1';
  s0_axi_rresp <= "11" when (axi_read_state = decerr) or (axi_read_state = decerr_wait) else "00";  
  
  process(axi_read_state)
  begin
  if (axi_read_state = valid) or (axi_read_state = valid_wait) then
    s0_axi_rdata <= (v_reg & "000000000000000" & rh_reg & tp_reg);
  else
    s0_axi_rdata <= (others => '0');
  end if;
  end process;

end architecture rtl;
