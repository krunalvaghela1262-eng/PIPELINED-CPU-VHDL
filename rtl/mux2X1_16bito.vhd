library ieee;
use ieee.std_logic_1164.all;

entity mux2X1_16bito is 
    port(
        opcode : in std_logic_vector(3 downto 0);
        A, B: in std_logic_vector(15 downto 0);
        Y      : out std_logic_vector(15 downto 0) := (others => '0')
    );
end entity;

architecture struct of mux2X1_16bito is

begin 
process(A,B,opcode)
begin
	if opcode ="0110" then
		Y <= A;

	elsif opcode ="0111" then 
		Y <= B;		
	else  
		Y <= B;
	end if;
end process;	
end struct;