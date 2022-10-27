library ieee;
use ieee.std_logic_1164.all;

entity moore is
	port(clk:     in  std_ulogic;
		 sresetn: in  std_ulogic;
		 stb:     in  std_ulogic;
		 done:    in  std_ulogic;
		 lsb:     in  std_ulogic;
		 a:       out std_ulogic;
		 s:       out std_ulogic;
		 i:       out std_ulogic
	 );
end entity moore;

architecture rtl of moore is

	type state_t is (idle, init, run, shift, add);
	signal state, next_state: state_t;

begin

	process(state, stb, done, lsb)
	begin
		next_state <= state;
		case state is
			when idle =>
				if stb = '1' then
					next_state <= init;
				end if;
			when init =>
				next_state <= run;
			when run =>
				if done = '1' then
					next_state <= idle;
				elsif lsb = '1' then
					next_state <= add;
				else
					next_state <= shift;
				end if;
			when add =>
				next_state <= shift;
			when shift =>
				next_state <= run;
		end case;
	end process;

	a <= '1' when state = add else '0';

	s <= '1' when state = shift else '0';

	i <= '1' when state = init else '0';

	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				state <= idle;
			else
				state <= next_state;
			end if;
		end if;
	end process;

end architecture rtl;
