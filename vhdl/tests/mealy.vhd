library ieee;
use ieee.std_logic_1164.all;

entity mealy is
	port(clk:     in  std_ulogic;
		 sresetn: in  std_ulogic;
		 stb:     in  std_ulogic;
		 done:    in  std_ulogic;
		 lsb:     in  std_ulogic;
		 a:       out std_ulogic;
		 s:       out std_ulogic;
		 i:       out std_ulogic
	 );
end entity mealy;

architecture rtl of mealy is

	type state_t is (idle, run, sa);
	signal state, next_state: state_t;

begin

	process(state, stb, done, lsb)
	begin
		next_state <= state;
		i          <= '0';
		a          <= '0';
		s          <= '0';
		case state is
			when idle =>
				if stb = '1' then
					next_state <= run;
					i          <= '1';
				end if;
			when run =>
				if done = '1' then
					next_state <= idle;
				elsif lsb = '1' then
					next_state <= sa;
					a          <= '1';
				else
					next_state <= sa;
				end if;
			when sa =>
				next_state <= run;
				s          <= '1';
		end case;
	end process;

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
