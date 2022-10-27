-- dual AXI4 lite port memory for simulation; 20 MB, 32 bits data ports

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

library common;
use common.axi_pkg.all;

entity axi_memory is
    port
    (
        aclk:           in    std_ulogic;                     -- clock
        aresetn:        in    std_ulogic;                     -- synchronous active low reset
        s0_axi_araddr:  in    std_ulogic_vector(19 downto 0); -- AXI4 lite read (byte) address
        s0_axi_arvalid: in    std_ulogic;                     -- AXI4 lite read address valid
        s0_axi_arready: out   std_ulogic;                     -- AXI4 lite read address acknowledge
        s0_axi_awaddr:  in    std_ulogic_vector(19 downto 0); -- AXI4 lite write (byte) address
        s0_axi_awvalid: in    std_ulogic;                     -- AXI4 lite read address valid
        s0_axi_awready: out   std_ulogic;                     -- AXI4 lite read address valid
        s0_axi_wdata:   in    std_ulogic_vector(31 downto 0); -- AXI4 lite 32-bits write data
        s0_axi_wstrb:   in    std_ulogic_vector(3 downto 0);  -- AXI4 lite 4-bits write byte enable
        s0_axi_wvalid:  in    std_ulogic;                     -- AXI4 lite write data and byte enable valid
        s0_axi_wready:  out   std_ulogic;                     -- AXI4 lite write data and byte enable acknowledge
        s0_axi_rdata:   out   std_ulogic_vector(31 downto 0); -- AXI4 lite read data
        s0_axi_rresp:   out   std_ulogic_vector(1 downto 0);  -- AXI4 lite read response
        s0_axi_rvalid:  out   std_ulogic;                     -- AXI4 lite read data and response valid
        s0_axi_rready:  in    std_ulogic;                     -- AXI4 lite read data and response acknowledge
        s0_axi_bresp:   out   std_ulogic_vector(1 downto 0);  -- AXI4 lite write response
        s0_axi_bvalid:  out   std_ulogic;                     -- AXI4 lite write response valid
        s0_axi_bready:  in    std_ulogic;                     -- AXI4 lite write response acknowledge
        s1_axi_araddr:  in    std_ulogic_vector(19 downto 0); -- AXI4 lite read (byte) address
        s1_axi_arvalid: in    std_ulogic;                     -- AXI4 lite read address valid
        s1_axi_arready: out   std_ulogic;                     -- AXI4 lite read address acknowledge
        s1_axi_awaddr:  in    std_ulogic_vector(19 downto 0); -- AXI4 lite write (byte) address
        s1_axi_awvalid: in    std_ulogic;                     -- AXI4 lite read address valid
        s1_axi_awready: out   std_ulogic;                     -- AXI4 lite read address valid
        s1_axi_wdata:   in    std_ulogic_vector(31 downto 0); -- AXI4 lite 32-bits write data
        s1_axi_wstrb:   in    std_ulogic_vector(3 downto 0);  -- AXI4 lite 4-bits write byte enable
        s1_axi_wvalid:  in    std_ulogic;                     -- AXI4 lite write data and byte enable valid
        s1_axi_wready:  out   std_ulogic;                     -- AXI4 lite write data and byte enable acknowledge
        s1_axi_rdata:   out   std_ulogic_vector(31 downto 0); -- AXI4 lite read data
        s1_axi_rresp:   out   std_ulogic_vector(1 downto 0);  -- AXI4 lite read response
        s1_axi_rvalid:  out   std_ulogic;                     -- AXI4 lite read data and response valid
        s1_axi_rready:  in    std_ulogic;                     -- AXI4 lite read data and response acknowledge
        s1_axi_bresp:   out   std_ulogic_vector(1 downto 0);  -- AXI4 lite write response
        s1_axi_bvalid:  out   std_ulogic;                     -- AXI4 lite write response valid
        s1_axi_bready:  in    std_ulogic                      -- AXI4 lite write response acknowledge
    );
end entity axi_memory;

architecture rtl of axi_memory is

begin

    s0_axi_rresp   <= axi_resp_okay;
    s0_axi_bresp   <= axi_resp_okay;
    s1_axi_rresp   <= axi_resp_okay;
    s1_axi_bresp   <= axi_resp_okay;

    process(aclk)
        subtype word is std_ulogic_vector(31 downto 0);
        type ram_t is array(natural range 0 to 2**17) of word;
        variable ram: ram_t;
        type state_t is (idle, responding);
        variable state0_r: state_t;
        variable state0_w: state_t;
        variable state1_r: state_t;
        variable state1_w: state_t;
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                s0_axi_awready <= '0';
                s0_axi_wready  <= '0';
                s0_axi_arready <= '1';
                s0_axi_rdata   <= (others => '0');
                s0_axi_rvalid  <= '0';
                s0_axi_bvalid  <= '0';
                s1_axi_awready <= '0';
                s1_axi_wready  <= '0';
                s1_axi_arready <= '1';
                s1_axi_rdata   <= (others => '0');
                s1_axi_rvalid  <= '0';
                s1_axi_bvalid  <= '0';
            else
                case state0_r is
                    when idle =>
                        if s0_axi_arvalid = '1' then
                            s0_axi_arready <= '0';
                            s0_axi_rvalid  <= '1';
                            s0_axi_rdata   <= ram(to_integer(s0_axi_araddr));
                            state0_r       := responding;
                        end if;
                    when responding =>
                        if s0_axi_rready = '1' then
                            s0_axi_arready <= '1';
                            s0_axi_rvalid  <= '0';
                            state0_r       := idle;
                        end if;
                end case;
                case state0_w is
                    when idle =>
                        if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' then
                            s0_axi_awready <= '1';
                            s0_axi_wready  <= '1';
                            s0_axi_bvalid  <= '1';
                            for i in 0 to 3 loop
                                if s0_axi_wstrb(i) = '1' then
                                    ram(to_integer(s0_axi_awaddr))(8 * i + 7 downto 8 * i) := s0_axi_wdata(8 * i + 7 downto 8 * i);
                                end if;
                            end loop;
                            state0_w       := responding;
                        end if;
                    when responding =>
                        s0_axi_awready <= '0';
                        s0_axi_wready  <= '0';
                        if s0_axi_bready = '1' then
                            s0_axi_bvalid <= '0';
                            state0_w      := idle;
                        end if;
                end case;
                case state1_r is
                    when idle =>
                        if s1_axi_arvalid = '1' then
                            s1_axi_arready <= '0';
                            s1_axi_rvalid  <= '1';
                            s1_axi_rdata   <= ram(to_integer(s1_axi_araddr));
                            state1_r       := responding;
                        end if;
                    when responding =>
                        if s1_axi_rready = '1' then
                            s1_axi_arready <= '1';
                            s1_axi_rvalid  <= '0';
                            state1_r       := idle;
                        end if;
                end case;
                case state1_w is
                    when idle =>
                        if s1_axi_awvalid = '1' and s1_axi_wvalid = '1' then
                            s1_axi_awready <= '1';
                            s1_axi_wready  <= '1';
                            s1_axi_bvalid  <= '1';
                            for i in 0 to 3 loop
                                if s1_axi_wstrb(i) = '1' then
                                    ram(to_integer(s1_axi_awaddr))(8 * i + 7 downto 8 * i) := s1_axi_wdata(8 * i + 7 downto 8 * i);
                                end if;
                            end loop;
                            state1_w       := responding;
                        end if;
                    when responding =>
                        s1_axi_awready <= '0';
                        s1_axi_wready  <= '0';
                        if s1_axi_bready = '1' then
                            s1_axi_bvalid <= '0';
                            state1_w      := idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
