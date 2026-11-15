library ieee;
use ieee.std_logic_1164.all;

entity beq_check is
    port (
        opcode    : in  std_logic_vector(3 downto 0);
        A, B      : in  std_logic_vector(7 downto 0);
        beq_flag  : out std_logic
    );
end entity;

architecture behavioral of beq_check is
begin
    process (A, B, opcode)
    begin
        if opcode = "0111" then
            if A = B then
                beq_flag <= '1';
            else
                beq_flag <= '0';
            end if;
        else
            beq_flag <= '0';
        end if;
    end process;
end architecture;
