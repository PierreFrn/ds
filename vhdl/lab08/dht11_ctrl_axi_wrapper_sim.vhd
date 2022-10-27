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

use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

library common;
use common.rnd_pkg.all;
use common.utils_pkg.all;

entity dht11_ctrl_axi_wrapper_sim is
    generic(
        f_mhz:    positive := 1;
        start_us: positive := 200;
        warm_us:  positive := 250
    );
    port(
        s0_axi_arready: out   std_ulogic;
        s0_axi_awready: out   std_ulogic;
        s0_axi_wready:  out   std_ulogic;
        s0_axi_rdata:   out   std_ulogic_vector(31 downto 0);
        s0_axi_rresp:   out   std_ulogic_vector(1 downto 0);
        s0_axi_rvalid:  out   std_ulogic;
        s0_axi_bresp:   out   std_ulogic_vector(1 downto 0);
        s0_axi_bvalid:  out   std_ulogic;
        data:           inout std_logic;
        led:            out   std_ulogic_vector(3 downto 0)
    );
end entity dht11_ctrl_axi_wrapper_sim;

architecture sim of dht11_ctrl_axi_wrapper_sim is

    constant axi_resp_okay:   std_ulogic_vector(1 downto 0) := "00";
    constant axi_resp_exokay: std_ulogic_vector(1 downto 0) := "01";
    constant axi_resp_slverr: std_ulogic_vector(1 downto 0) := "10";
    constant axi_resp_decerr: std_ulogic_vector(1 downto 0) := "11";

    constant period:          time := (1.0e3 * 1 ns) / real(f_mhz);
    constant startl_max:      natural := start_us + start_us / 10; -- Maximum of start low phase
    constant starth_max:      natural := 40;       -- Maximum of start high phase
    constant acknowledge:     natural := 80;       -- Acknowledge phases
    constant bitl:            natural := 50;       -- Bit low phase
    constant bit1h:           natural := 70;       -- Bit 1 high phase
    constant acquisition_max: natural := startl_max + starth_max + 2 * acknowledge + 40 * (bitl + bit1h) + bitl;

    signal aclk:            std_ulogic;
    signal aresetn:         std_ulogic;
    signal s0_axi_araddr:   std_ulogic_vector(11 downto 0);
    signal s0_axi_arvalid:  std_ulogic;
    signal s0_axi_rready:   std_ulogic;
    signal s0_axi_awaddr:   std_ulogic_vector(11 downto 0);
    signal s0_axi_awvalid:  std_ulogic;
    signal s0_axi_wdata:    std_ulogic_vector(31 downto 0);
    signal s0_axi_wstrb:    std_ulogic_vector(3 downto 0);
    signal s0_axi_wvalid:   std_ulogic;
    signal s0_axi_bready:   std_ulogic;

    signal dso:             std_ulogic;
    signal cerr:            std_ulogic;
    signal val:             std_ulogic_vector(39 downto 0);

    signal check:           boolean;
    signal v_reg:           std_ulogic;
    signal rh_reg:          std_ulogic_vector(7 downto 0);
    signal tp_reg:          std_ulogic_vector(7 downto 0);

    signal s0_axi_arready_ref: std_ulogic;
    signal s0_axi_rdata_ref:   std_ulogic_vector(31 downto 0);
    signal s0_axi_rresp_ref:   std_ulogic_vector(1 downto 0);
    signal s0_axi_rvalid_ref:  std_ulogic;
    signal s0_axi_awready_ref: std_ulogic;
    signal s0_axi_wready_ref:  std_ulogic;
    signal s0_axi_bresp_ref:   std_ulogic_vector(1 downto 0);
    signal s0_axi_bvalid_ref:  std_ulogic;

    signal led_ref:            std_ulogic_vector(3 downto 0);

begin

    process
    begin
        aclk <= '0';
        wait for period / 2;
        aclk <= '1';
        wait for period / 2;
    end process;

    -- Pull-up resistor
    data <= 'H';

    u_dht11: entity common.dht11(beh)
    generic map(
        start_us => start_us,
        warm_us  => warm_us
    )
    port map(
        data => data,
        dso  => dso,
        cerr => cerr,
        val  => val
    );

    u_dht11_ctrl_axi_wrapper: entity work.dht11_ctrl_axi_wrapper(rtl)
    generic map(
        f_mhz    => f_mhz,
        start_us => start_us,
        warm_us  => warm_us
    )
    port map(
        aclk           => aclk,
        aresetn        => aresetn,
        s0_axi_araddr  => s0_axi_araddr,
        s0_axi_arvalid => s0_axi_arvalid,
        s0_axi_rready  => s0_axi_rready,
        s0_axi_awaddr  => s0_axi_awaddr,
        s0_axi_awvalid => s0_axi_awvalid,
        s0_axi_wdata   => s0_axi_wdata,
        s0_axi_wstrb   => s0_axi_wstrb,
        s0_axi_wvalid  => s0_axi_wvalid,
        s0_axi_bready  => s0_axi_bready,
        s0_axi_arready => s0_axi_arready,
        s0_axi_rdata   => s0_axi_rdata,
        s0_axi_rresp   => s0_axi_rresp,
        s0_axi_rvalid  => s0_axi_rvalid,
        s0_axi_awready => s0_axi_awready,
        s0_axi_wready  => s0_axi_wready,
        s0_axi_bresp   => s0_axi_bresp,
        s0_axi_bvalid  => s0_axi_bvalid,
        data           => data,
        led            => led
    );

    -- Submit random AXI4 lite requests
    process
        variable rg: rnd_generator;
    begin
        aresetn        <= '0';
        s0_axi_araddr  <= (others => '0');
        s0_axi_arvalid <= '0';
        s0_axi_rready  <= '0';
        s0_axi_awaddr  <= (others => '0');
        s0_axi_awvalid <= '0';
        s0_axi_wdata   <= (others => '0');
        s0_axi_wstrb   <= (others => '0');
        s0_axi_wvalid  <= '0';
        s0_axi_bready  <= '0';
        for i in 1 to 10 loop
            wait until rising_edge(aclk);
        end loop;
        aresetn <= '1';
        loop
            wait until rising_edge(aclk);
            s0_axi_rready <= rg.get_std_ulogic;
            s0_axi_bready <= rg.get_std_ulogic;
            if s0_axi_arvalid = '0' or s0_axi_arready = '1' then
                s0_axi_araddr <= rg.get_std_ulogic_vector(12);
                if rg.get_integer(0, 9) /= 9 then
                    s0_axi_araddr(11 downto 3) <= (others => '0');
                end if;
                s0_axi_arvalid <= rg.get_std_ulogic;
            end if;
            if s0_axi_awvalid = '0' or s0_axi_awready = '1' then
                s0_axi_awaddr <= rg.get_std_ulogic_vector(12);
                if rg.get_integer(0, 9) /= 9 then
                    s0_axi_awaddr(11 downto 3) <= (others => '0');
                end if;
                s0_axi_awvalid <= rg.get_std_ulogic;
            end if;
            if s0_axi_wvalid = '0' or s0_axi_wready = '1' then
                s0_axi_wdata  <= rg.get_std_ulogic_vector(32);
                s0_axi_wstrb  <= rg.get_std_ulogic_vector(4);
                s0_axi_wvalid <= rg.get_std_ulogic;
            end if;
        end loop;
    end process;

    -- Termination after nmax acquisitions, check periodicity of acquisitions,
    -- error if no acquisition in twice the warm-up time plus maximum
    -- acquisition time
    process
        constant nmax:  positive := 100;
    begin
        wait until rising_edge(aclk) and aresetn = '0';
        wait until rising_edge(aclk) and aresetn = '1';
        for n in 1 to nmax loop
            wait until dso = '1' and rising_edge(aclk) for (acquisition_max + warm_us) * 2 us;
            check_ref(dso, '1', "DSO");
            wait until dso = '0' and rising_edge(aclk);
        end loop;
        pass;
    end process;

    -- Compute reference values and check flag. Actual and reference values are
    -- compared only when check flag is true. Check flag is false until reset
    -- is asserted low and during 10 us after the DHT11 emulator outputs
    -- reference values.
    process
        variable vcerr: std_ulogic;
    begin
        check     <= false;
        wait until rising_edge(aclk) and aresetn = '0';
        check     <= true;
        v_reg     <= '0';
        rh_reg    <= (others => '0');
        tp_reg    <= (others => '0');
        loop
            wait until rising_edge(aclk) and dso = '1';
            vcerr := cerr;
            check <= false;
            wait for 10 us;
            wait until rising_edge(aclk);
            if vcerr = '0' then
                check   <= true;
                v_reg   <= '1';
                rh_reg  <= val(39 downto 32);
                tp_reg  <= val(23 downto 16);
            else
                check   <= false;
            end if;
            wait until rising_edge(aclk) and dso = '0';
        end loop;
    end process;

    led_ref <= (others => '-') when not check else v_reg & '0' & rh_reg(0) & tp_reg(0);

    -- Check unknowns
    process
    begin
        wait until rising_edge(aclk) and aresetn = '0';
        loop
            wait until rising_edge(aclk);
            check_unknowns(s0_axi_araddr, "S0_AXI_ARADDR");
            check_unknowns(s0_axi_arvalid, "S0_AXI_ARVALID");
            check_unknowns(s0_axi_arready, "S0_AXI_ARREADY");
            check_unknowns(s0_axi_awaddr, "S0_AXI_AWADDR");
            check_unknowns(s0_axi_awvalid, "S0_AXI_AWVALID");
            check_unknowns(s0_axi_awready, "S0_AXI_AWREADY");
            check_unknowns(s0_axi_wdata, "S0_AXI_WDATA");
            check_unknowns(s0_axi_wstrb, "S0_AXI_WSTRB");
            check_unknowns(s0_axi_wvalid, "S0_AXI_WVALID");
            check_unknowns(s0_axi_wready, "S0_AXI_WREADY");
            check_unknowns(s0_axi_rdata, "S0_AXI_RDATA");
            check_unknowns(s0_axi_rresp, "S0_AXI_RRESP");
            check_unknowns(s0_axi_rvalid, "S0_AXI_RVALID");
            check_unknowns(s0_axi_rready, "S0_AXI_RREADY");
            check_unknowns(s0_axi_bresp, "S0_AXI_BRESP");
            check_unknowns(s0_axi_bvalid, "S0_AXI_BVALID");
            check_unknowns(s0_axi_bready, "S0_AXI_BREADY");
        end loop;
    end process;

    -- Reference slave behavior on AXI read channels. Use don't care values for no-check.
    process
        variable add: natural range 0 to 2**10 - 1;
    begin
        wait until rising_edge(aclk) and aresetn = '0';
        s0_axi_arready_ref <= '0';
        s0_axi_rvalid_ref  <= '0';
        s0_axi_rresp_ref   <= (others => '0');
        s0_axi_rdata_ref   <= (others => '0');
        wait until rising_edge(aclk) and aresetn = '1';
        loop
            if s0_axi_arvalid = '0' then
                wait until rising_edge(aclk) and s0_axi_arvalid = '1';
            end if;
            add := to_integer(s0_axi_araddr(11 downto 2));
            s0_axi_arready_ref <= '1';
            s0_axi_rvalid_ref  <= '1';
            s0_axi_rresp_ref   <= axi_resp_okay;
            if add = 0 then
                if not check then
                    s0_axi_rdata_ref <= (others => '-');
                else
                    s0_axi_rdata_ref <= v_reg & "000000000000000" & rh_reg & tp_reg;
                end if;
            else
                s0_axi_rresp_ref <= axi_resp_decerr;
                s0_axi_rdata_ref <= (others => '-');
            end if;
            wait until rising_edge(aclk);
            s0_axi_arready_ref <= '0';
            if s0_axi_rready = '0' then
                wait until rising_edge(aclk) and s0_axi_rready = '1';
            end if;
            s0_axi_rvalid_ref <= '0';
            wait until rising_edge(aclk);
        end loop;
    end process;

    process
    begin
        wait until rising_edge(aclk) and aresetn = '0';
        loop
            wait until rising_edge(aclk);
            check_ref(v => s0_axi_arready, r => s0_axi_arready_ref, s => "S0_AXI_ARREADY");
            check_ref(v => s0_axi_rvalid, r => s0_axi_rvalid_ref, s => "S0_AXI_RVALID");
            if(s0_axi_rvalid = '1') then
                check_ref(v => s0_axi_rdata, r => s0_axi_rdata_ref, s => "S0_AXI_RDATA");
                check_ref(v => s0_axi_rresp, r => s0_axi_rresp_ref, s => "S0_AXI_RRESP");
            end if;
        end loop;
    end process;

    -- Reference slave behavior on AXI write channels. Use don't care values for no-check.
    process
        variable add: natural range 0 to 2**10 - 1;
    begin
        wait until rising_edge(aclk) and aresetn = '0';
        s0_axi_awready_ref <= '0';
        s0_axi_wready_ref  <= '0';
        s0_axi_bvalid_ref  <= '0';
        s0_axi_bresp_ref   <= (others => '0');
        wait until rising_edge(aclk) and aresetn = '1';
        loop
            if s0_axi_awvalid = '0' or s0_axi_wvalid = '0' then
                wait until rising_edge(aclk) and (s0_axi_awvalid = '1') and (s0_axi_wvalid = '1');
            end if;
            add := to_integer(s0_axi_awaddr(11 downto 2));
            s0_axi_awready_ref <= '1';
            s0_axi_wready_ref  <= '1';
            s0_axi_bvalid_ref  <= '1';
            if add = 0 then
                s0_axi_bresp_ref   <= axi_resp_slverr;
            else
                s0_axi_bresp_ref   <= axi_resp_decerr;
            end if;
            wait until rising_edge(aclk);
            s0_axi_awready_ref <= '0';
            s0_axi_wready_ref  <= '0';
            if s0_axi_bready = '0' then
                wait until rising_edge(aclk) and s0_axi_bready = '1';
            end if;
            s0_axi_bvalid_ref <= '0';
            wait until rising_edge(aclk);
        end loop;
    end process;

    process
    begin
        wait until rising_edge(aclk) and aresetn = '0';
        loop
            wait until rising_edge(aclk);
            check_ref(v => s0_axi_awready, r => s0_axi_awready_ref, s => "S0_AXI_AWREADY");
            check_ref(v => s0_axi_wready, r => s0_axi_wready_ref, s => "S0_AXI_WREADY");
            check_ref(v => s0_axi_bvalid, r => s0_axi_bvalid_ref, s => "S0_AXI_BVALID");
            if(s0_axi_bvalid = '1') then
                check_ref(v => s0_axi_bresp, r => s0_axi_bresp_ref, s => "S0_AXI_BRESP");
            end if;
        end loop;
    end process;

    process
    begin
        wait on led, led_ref;
        if led'event and (not led_ref'event) then
            wait on led_ref for 0 ns;
        elsif (not led'event) and led_ref'event then
            wait on led for 0 ns;
        end if;
        check_ref(v => led, r => led_ref, s => "LED");
    end process;

end architecture sim;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
