library ieee;
use ieee.std_logic_1164.all;

entity pr_1_2 is
   port(clock, reset: in std_logic; 
			instr_in: in std_logic_vector(15 downto 0);
			instr_out: out std_logic_vector(15 downto 0):=(others => '0'));
end entity;

architecture struct of pr_1_2 is	
	signal reg_data: std_logic_vector(15 downto 0):="1111000000000000";
	
	begin
	
	clk_proc: process(clock)
		begin
		if (reset='1') then
			reg_data <= "1111000000000000";			
		elsif (clock'event and clock='1') then
			reg_data <= instr_in;
		end if;
	end process;
	
	instr_out <= reg_data;
	
end struct;
