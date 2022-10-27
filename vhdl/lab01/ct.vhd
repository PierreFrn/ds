entity ct is
  port(
    switch0   : in  bit;
    wire_in   : in  bit;
    wire_out  : out bit;
    led       : out bit_vector(3 downto 0)
  );
end entity ct;

architecture rtl of ct is
  begin
    led(0) <= '1';
    led(1) <= '0';
    led(2) <= wire_in;
    led(3) <= not wire_in;
    wire_out <= switch0;
  end architecture rtl;
  
