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

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity dht11_ctrl_top is
    port(
        clk:     in    std_ulogic;
        areset:  in    std_ulogic;
        sw:      in    std_ulogic_vector(1 downto 0);
        data:    inout std_logic;
        led:     out   std_ulogic_vector(3 downto 0)
    );
end entity dht11_ctrl_top;

architecture rtl of dht11_ctrl_top is

    signal data_in:   std_ulogic;
    signal force0:    std_ulogic;
    signal dso:       std_ulogic;
    signal cerr:      std_ulogic;
    signal rh:        std_ulogic_vector(7 downto 0);
    signal tp:        std_ulogic_vector(7 downto 0);
    signal reg:       std_ulogic_vector(15 downto 0);
    signal sync:      std_ulogic_vector(1 downto 0);
    alias  sresetn:   std_ulogic is sync(1);

begin

    -- select LED source with switches
    led <= reg( 3 downto  0) when sw = "00" else -- 4 lSBs of temperature
           reg( 7 downto  4) when sw = "01" else -- 4 MSBs of temperature
           reg(11 downto  8) when sw = "10" else -- 4 LSBs of humidity
           reg(15 downto 12);                    -- 4 MSBs of humidity

    -- DHT11 controller
    u0: entity work.dht11_ctrl(rtl)
    generic map(
        f_mhz     => 125,
        start_us  => 20000,
        warm_us   => 1000000
    )
    port map(
        clk      => clk,
        sresetn  => sresetn,
        data_in  => data_in,
        force0   => force0,
        dso      => dso,
        cerr     => cerr,
        rh       => rh,
        tp       => tp
    );

    -- tri-state buffer
    u_tsb : iobuf
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

    -- 16-bits register to store humidity and temperature
    process(clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0' then
                reg <= (others => '0');
            elsif dso = '1' and cerr = '0' then
                reg(15 downto 0) <= rh & tp;
            end if;
        end if;
    end process;

    -- 2-stages resynchronizer for reset
    sr2: entity work.sr(rtl)
    generic map(n => 2)
    port map(
        clk     => clk,
        sresetn => '1',
        shift   => '1',
        din     => not areset,
        dout    => sync
    );

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
