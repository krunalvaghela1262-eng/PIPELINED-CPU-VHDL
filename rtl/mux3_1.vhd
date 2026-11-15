library ieee;
use ieee.std_logic_1164.all;

entity mux4_1 is 
    port(
        A, B, C, D : in std_logic;
        sel        : in std_logic_vector(1 downto 0);
        Y          : out std_logic
    );
end entity;

architecture struct of mux4_1 is 
begin 
    process(A, B, C, D, sel)
    begin
        case sel is
            when "00" => Y <= A;
            when "01" => Y <= B;
            when "10" => Y <= C;
            when "11" => Y <= D;
            when others => Y <= '0'; 
        end case;
    end process;
end struct;
