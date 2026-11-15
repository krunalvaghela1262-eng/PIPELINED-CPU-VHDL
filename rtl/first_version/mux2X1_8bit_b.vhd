library ieee;
use ieee.std_logic_1164.all;

entity mux2X1_8bit_b is 
 port(
 clock: in std_logic;
 A,B: in std_logic_vector(7 downto 0);
 opcode: in std_logic_vector(3 downto 0);
 Y: out std_logic_vector(7 downto 0):=(others => '0'));
end entity;

architecture struct of mux2X1_8bit_b is
   signal s: std_logic; 
 component mux2_1 is 
	 port(A,B,sel: in std_logic; Y: out std_logic);
 end component;
 
begin 
    s <= (opcode(0) or opcode(1) or opcode(2));
	 gen: for i in 0 to 7 generate
	  mux: mux2_1
		port map( A => A(i), B => B(i), sel =>s , Y => Y(i));
	 end generate;	


end struct;