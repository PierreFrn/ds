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

library common;
use common.utils_pkg.all;

entity dht11_ctrl_sim is
    generic(
        f_mhz:    positive := 1;
        start_us: positive := 200;
        warm_us:  positive := 250
    );
    port(
        data:     out std_logic;
        force0:   out std_ulogic;
        dso:      out std_ulogic;
        cerr:     out std_ulogic;
        rh:       out std_ulogic_vector(7 downto 0);
        tp:       out std_ulogic_vector(7 downto 0);
        dso_ref:  out std_ulogic;
        cerr_ref: out std_ulogic;
        dout_ref: out std_ulogic_vector(39 downto 0)
    );
end entity dht11_ctrl_sim;

architecture sim of dht11_ctrl_sim is

    constant period:           time := (1.0e3 * 1 ns) / real(f_mhz);
    constant start_low_max:    natural := start_us + start_us / 10; -- Maximum of start low phase
    constant start_high_max:   natural := 40;       -- Maximum of start high phase
    constant acknowledge_low:  natural := 80;       -- Acknowledge low phases
    constant acknowledge_high: natural := 80;       -- Acknowledge high phases
    constant bit_low:          natural := 50;       -- Bit low phase
    constant bit1_high:        natural := 70;       -- Bit 1 high phase
    constant acquisition_max:  natural := start_low_max + start_high_max + acknowledge_low + acknowledge_high + 40 * (bit_low + bit1_high) + bit_low;

    signal data_in:  std_ulogic;
    signal clk:      std_ulogic;
    signal sresetn:  std_ulogic;
    alias  rh_ref:   std_ulogic_vector(7 downto 0) is dout_ref(39 downto 32);
    alias  tp_ref:   std_ulogic_vector(7 downto 0) is dout_ref(23 downto 16);

begin

    process
    begin
        clk <= '0';
        wait for period / 2.0;
        clk <= '1';
        wait for period / 2.0;
    end process;

    -- Tri-state buffer.
    data <= '0' when force0 = '0' else 'H';

    -- Convert data line to 'X', '0', '1'.
    data_in <= to_x01(data);

    u_dht11_ctrl: entity work.dht11_ctrl(rtl)
    generic map(
        f_mhz    => f_mhz,
        start_us => start_us,
        warm_us  => warm_us
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

    u_dht11: entity common.dht11(beh)
    generic map(
        start_us => start_us,
        warm_us  => warm_us
    )
    port map(
        data => data,
        dso  => dso_ref,
        cerr => cerr_ref,
        val  => dout_ref
    );

    process
        constant nmax:  positive := 100;
    begin
        print("SIMULATING WITH f_mhz = " & ds_to_string(f_mhz) & ", start_us = " & ds_to_string(start_us) & ", warm_us = " & ds_to_string(warm_us));
        sresetn <= '0';
        data    <= 'Z';
        for i in 1 to 10 loop
            wait until rising_edge(clk);
        end loop;
        sresetn <= '1';
        wait until rising_edge(clk);
        for n in 1 to nmax loop
            wait until dso = '1' and rising_edge(clk) for (acquisition_max + warm_us) * 2 us;
        end loop;
        pass;
    end process;

    process
    begin
        wait until (dso_ref = '1' or dso = '1') and rising_edge(clk);
        if not (dso_ref = '1' and dso = '0') then
            check_ref(dso, '0', "DSO");
        end if;
        wait until (dso_ref = '0' or dso = '1') and rising_edge(clk);
        if not (dso_ref = '1' and dso = '1') then
            check_ref(dso, '1', "DSO");
        end if;
        check_ref(cerr, cerr_ref, "CERR");
        if cerr /= '1' then
            check_ref(rh, rh_ref, "RH");
            check_ref(tp, tp_ref, "TP");
        end if;
        wait until rising_edge(clk);
        check_ref(dso, '0', "DSO");
        wait until (dso_ref = '0' or dso = '1') and rising_edge(clk);
        if not (dso_ref = '0' and dso = '0') then
            check_ref(dso, '0', "DSO");
        end if;
    end process;

end architecture sim;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
