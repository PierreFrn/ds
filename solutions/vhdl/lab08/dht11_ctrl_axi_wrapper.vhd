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
use ieee.numeric_std_unsigned.all;

library common;
use common.axi_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity dht11_ctrl_axi_wrapper is
    generic(
        f_mhz:    positive := 100;
        start_us: positive := 18000;
        warm_us:  positive := 1000000
    );
    port(
        aclk:           in    std_ulogic;
        aresetn:        in    std_ulogic;
        s0_axi_araddr:  in    std_ulogic_vector(11 downto 0);
        s0_axi_arvalid: in    std_ulogic;
        s0_axi_arready: out   std_ulogic;
        s0_axi_awaddr:  in    std_ulogic_vector(11 downto 0);
        s0_axi_awvalid: in    std_ulogic;
        s0_axi_awready: out   std_ulogic;
        s0_axi_wdata:   in    std_ulogic_vector(31 downto 0);
        s0_axi_wstrb:   in    std_ulogic_vector(3 downto 0);
        s0_axi_wvalid:  in    std_ulogic;
        s0_axi_wready:  out   std_ulogic;
        s0_axi_rdata:   out   std_ulogic_vector(31 downto 0);
        s0_axi_rresp:   out   std_ulogic_vector(1 downto 0);
        s0_axi_rvalid:  out   std_ulogic;
        s0_axi_rready:  in    std_ulogic;
        s0_axi_bresp:   out   std_ulogic_vector(1 downto 0);
        s0_axi_bvalid:  out   std_ulogic;
        s0_axi_bready:  in    std_ulogic;
        data:           inout std_logic;
        led:            out   std_ulogic_vector(3 downto 0) --;
--        irq:            out   std_ulogic
    );
end entity dht11_ctrl_axi_wrapper;

architecture rtl of dht11_ctrl_axi_wrapper is

    signal data_in: std_ulogic;
    signal force0:  std_ulogic;
    signal dso:     std_ulogic;
    signal cerr:    std_ulogic;
    signal rh:      std_ulogic_vector(7 downto 0);
    signal tp:      std_ulogic_vector(7 downto 0);
    signal v_reg:   std_ulogic;
    signal rh_reg:  std_ulogic_vector(7 downto 0);
    signal tp_reg:  std_ulogic_vector(7 downto 0);

    type states is (idle, ackok, waitok, ackko, waitko);
    signal state_r, state_w: states;

begin

    u0: entity work.dht11_ctrl(rtl)
    generic map(
        f_mhz    => f_mhz,
        start_us => start_us,
        warm_us  => warm_us
    )
    port map(
        clk      => aclk,
        sresetn  => aresetn,
        data_in  => data_in,
        force0   => force0,
        dso      => dso,
        cerr     => cerr,
        rh       => rh,
        tp       => tp
    );

    u1 : iobuf
    generic map (
        drive      => 12,
        iostandard => "lvcmos33",
        slew       => "slow")
    port map (
        o  => data_in,
        io => data,
        i  => '0',
        t  => force0
    );

    led <= v_reg & '0' & rh_reg(0) & tp_reg(0);

    process(aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                v_reg  <= '0';
                rh_reg <= (others => '0');
                tp_reg <= (others => '0');
            elsif dso = '1' and cerr = '0' then
                v_reg  <= '1';
                rh_reg <= rh;
                tp_reg <= tp;
            end if;
        end if;
    end process;

    process(aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                state_w <= idle;
            else
                case state_w is
                    when idle =>
                        if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' then
                            if s0_axi_awaddr < 4 then
                                state_w <= ackok;
                            else
                                state_w <= ackko;
                            end if;
                        end if;
                    when ackok =>
                        if s0_axi_bready = '1' then
                            state_w <= idle;
                        else
                            state_w <= waitok;
                        end if;
                    when waitok =>
                        if s0_axi_bready = '1' then
                            state_w <= idle;
                        end if;
                    when ackko =>
                        if s0_axi_bready = '1' then
                            state_w <= idle;
                        else
                            state_w <= waitko;
                        end if;
                    when waitko =>
                        if s0_axi_bready = '1' then
                            state_w <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    s0_axi_awready <= '1' when state_w = ackok or state_w = ackko else '0';
    s0_axi_wready  <= '1' when state_w = ackok or state_w = ackko else '0';
    s0_axi_bvalid  <= '0' when state_w = idle else '1';
    s0_axi_bresp   <= axi_resp_slverr when state_w = ackok or state_w = waitok else
                      axi_resp_decerr when state_w = ackko or state_w = waitko else
                      axi_resp_okay;

    process(aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                state_r      <= idle;
            else
                case state_r is
                    when idle =>
                        if s0_axi_arvalid = '1' then
                            if s0_axi_araddr < 4 then
                                state_r <= ackok;
                            else
                                state_r <= ackko;
                            end if;
                        end if;
                    when ackok =>
                        if s0_axi_rready = '1' then
                            state_r <= idle;
                        else
                            state_r <= waitok;
                        end if;
                    when waitok =>
                        if s0_axi_rready = '1' then
                            state_r <= idle;
                        end if;
                    when ackko =>
                        if s0_axi_rready = '1' then
                            state_r <= idle;
                        else
                            state_r <= waitko;
                        end if;
                    when waitko =>
                        if s0_axi_rready = '1' then
                            state_r <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    s0_axi_arready <= '1' when state_r = ackok or state_r = ackko else '0';
    s0_axi_rvalid  <= '0' when state_r = idle else '1';
    s0_axi_rresp   <= axi_resp_decerr when state_r = ackko or state_r = waitko else
                      axi_resp_okay;

    process(aclk)
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                s0_axi_rdata <= (others => '0');
            elsif s0_axi_rvalid = '0' then
                s0_axi_rdata <= v_reg & "000000000000000" & rh_reg & tp_reg;
            end if;
        end if;
    end process;

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
