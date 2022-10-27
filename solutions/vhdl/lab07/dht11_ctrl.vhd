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

entity dht11_ctrl is
    generic(
        f_mhz:    positive := 125;
        start_us: positive := 20000;
        warm_us:  positive := 1000000
    );
    port(
        clk:     in  std_ulogic;
        sresetn: in  std_ulogic;
        data_in: in  std_ulogic;
        force0:  out std_ulogic;
        dso:     out std_ulogic;
        tp:      out std_ulogic_vector(7 downto 0);
        rh:      out std_ulogic_vector(7 downto 0);
        cerr:    out std_ulogic
    );
end entity dht11_ctrl;

architecture rtl of dht11_ctrl is

    type state_t is (idle, start, level_low, level_high);

    signal state:   state_t;
    signal shift:   std_ulogic;
    signal din:     std_ulogic;
    signal reg:     std_ulogic_vector(23 downto 0);
    signal tz:      std_ulogic;
    signal t:       natural range 0 to warm_us;
    signal re:      std_ulogic;
    signal fe:      std_ulogic;
    signal cz:      std_ulogic;
    signal inc:     std_ulogic;
    signal c:       natural range 0 to 42;

begin

    rh     <= reg(23 downto 16);
    tp     <= reg(15 downto 8);

    cerr   <= '1' when reg(23 downto 16) + reg(15 downto 8) /= reg(7 downto 0) else '0';

    tz     <= '1' when state = idle and t = warm_us else
              '1' when state = start and t = start_us else
              '1' when state = level_high and (fe = '1' or t = start_us) else
              '1' when state = level_low and (re = '1' or t = start_us) else
              '0';

    din    <= '1' when state = level_high and t >= 50 else '0';

    shift  <= '1' when state = level_high and fe = '1' and ((c >= 2 and c <= 9) or (c >= 18 and c <= 25) or (c >= 34 and c <= 41)) else '0';

    cz     <= '1' when state = start and t = start_us else '0';

    inc    <= '1' when state = level_high and fe = '1' else '0';

    force0 <= '0' when state = start else '1';

    dso    <= '1' when state = level_low and re = '1' and c = 42 else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if sresetn = '0' then
                state  <= idle;
            else
                case state is
                    when idle =>
                        if t = warm_us then
                            state  <= start;
                        end if;
                    when start =>
                        if t = start_us then
                            state  <= level_high;
                        end if;
                    when level_high =>
                        if fe = '1' then
                            state <= level_low;
                        elsif t = start_us then
                            state <= idle;
                        end if;
                    when level_low =>
                        if re = '1' then
                            if c /= 42 then
                                state <= level_high;
                            else
                                state <= idle;
                            end if;
                        elsif t = start_us then
                            state <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    sr0: entity work.sr(rtl)
    generic map(
        n => 24
    )
    port map(
        clk     => clk,
        sresetn => sresetn,
        shift   => shift,
        din     => din,
        dout    => reg
    );

    timer0: entity work.timer(rtl)
    generic map(
        f_mhz  => f_mhz,
        max_us => warm_us
    )
    port map(
        clk     => clk,
        sresetn => sresetn,
        tz      => tz,
        t       => t
    );

    edge0: entity work.edge(rtl)
    port map(
        clk     => clk,
        sresetn => sresetn,
        data_in => data_in,
        re      => re,
        fe      => fe
    );

    counter0: entity work.counter(rtl)
    generic map(
        cmax => 42
    )
    port map(
        clk     => clk,
        sresetn => sresetn,
        cz      => cz,
        inc     => inc,
        c       => c
    );

end architecture rtl;

-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
