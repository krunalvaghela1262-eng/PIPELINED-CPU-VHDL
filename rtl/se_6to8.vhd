library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity se_6to8 is
    port (
        A: in std_logic_vector(5 downto 0);
        C: out std_logic_vector(7 downto 0)
    );
end entity;

architecture struct of se_6to8 is
begin

process(A)
begin 
	C <= std_logic_vector(resize(unsigned(A), 8));
end process;
end struct;