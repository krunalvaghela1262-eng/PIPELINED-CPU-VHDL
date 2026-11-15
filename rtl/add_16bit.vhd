library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_16bit is
    port (
        opcode      : in  std_logic_vector(3 downto 0);
        A, B        : in  std_logic_vector(15 downto 0);
        result      : out std_logic_vector(15 downto 0);
        adder_flag  : out std_logic
    );
end entity;

architecture behavioral of add_16bit is
begin
    process (A, B, opcode)
    begin
			result <= std_logic_vector(to_signed((to_integer(signed(A))) + (to_integer(signed(B))),16));
			
		  if opcode = "0111" or opcode = "0110" then
            adder_flag <= '1';
        else
            adder_flag <= '0';
        end if;
    end process;
end architecture;
