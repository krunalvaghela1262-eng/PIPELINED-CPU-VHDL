library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity se_10to16 is
    port (
        A: in std_logic_vector(9 downto 0);
        C: out std_logic_vector(15 downto 0)
    );
end entity;

architecture struct of se_10to16 is
begin

process(A)
begin 
	C <= std_logic_vector(resize(unsigned(A), 16));
end process;
end struct;