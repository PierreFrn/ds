use std.env.all;

entity ct_sim is
  port(
    wire_out  : out bit;
    led       : out bit_vector(3 downto 0)
  );
end entity ct_sim;

architecture sim of ct_sim is

  signal switch0, wire_in: bit;
  
  begin
  
    u0: entity work.ct(rtl)
    port map(
      switch0  => switch0,
      wire_in  => wire_in,
      wire_out => wire_out,
      led      => led
    );

  process
  begin
    switch0 <= '0';
    wire_in <= '0';
    wait for 1 ns;
    switch0 <= '0';
    wire_in <= '1';
    wait for 1 ns;
    switch0 <= '1';
    wire_in <= '0';
    wait for 1 ns;
    switch0 <= '1';
    wire_in <= '1';
    wait for 1 ns;
    switch0 <= '0';
    wire_in <= '0';
    wait for 1 ns;
    finish;
  end process;
end architecture sim;
