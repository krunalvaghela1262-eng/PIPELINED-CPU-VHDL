library ieee;
use ieee.std_logic_1164.all;

entity mux4X1_8bit is 
    port(
        clock  : in std_logic;
        A, B, C : in std_logic_vector(7 downto 0);
        opcode : in std_logic_vector(3 downto 0);
        Y      : out std_logic_vector(7 downto 0) := (others => '0')
    );
end entity;

architecture struct of mux4X1_8bit is

    component mux3_1 is 
        port(
            A, B, C, D : in std_logic;
            sel        : in std_logic_vector(1 downto 0);
            Y          : out std_logic
        );
    end component;

    signal sel : std_logic_vector(1 downto 0);

begin


    process(opcode)
    begin
        if opcode = "0111" then
            sel <= "10";  -- select C
        elsif (opcode(0) = '1' or opcode(1) = '1' or opcode(2) = '0') then
            sel <= "01";  -- select B
        else
            sel <= "00";  -- select A
        end if;
    end process;

    -- generate 8 muxes
    gen: for i in 0 to 7 generate
        mux: mux3_1
            port map(
                A => A(i),
                B => B(i),
                C => C(i),
                D => '0',     
                sel => sel,
                Y => Y(i)
            );
    end generate;

end struct;
