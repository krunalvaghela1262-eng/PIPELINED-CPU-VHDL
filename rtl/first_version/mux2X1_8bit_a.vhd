library ieee;
use ieee.std_logic_1164.all;

entity mux2X1_8bit_a is 
 port(clock: in std_logic;
 A,B: in std_logic_vector(7 downto 0);
 opcode: in std_logic_vector(3 downto 0);
 Y: out std_logic_vector(7 downto 0):=(others => '0'));
end entity;

architecture struct of mux2X1_8bit_a is
signal s: std_logic;  
--signal output_buffer: std_logic_vector(7 downto 0);
--signal a_sig, b_sig : std_logic_vector(7 downto 0);

 component mux2_1 is 
	 port(A,B,sel: in std_logic; Y: out std_logic);
 end component;
 
begin 

	 s <= ((not opcode(0)) or opcode(1) or (not opcode(2)) or opcode(3));
	 
	 gen: for i in 0 to 7 generate
	  mux: mux2_1
		port map( A => A(i), B => B(i), sel => s , Y => Y(i));
	 end generate;	
	 
	--clk_proc: process(clock)
	--begin
	--	if rising_edge(clock) then
	--		a_sig <= A;
	--		b_sig <= B;
	--		Y <= output_buffer;
	--	end if;
	--end process;

end struct;  