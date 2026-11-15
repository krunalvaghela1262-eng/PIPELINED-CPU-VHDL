library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_inc_mux is
    port (
        pc_in  : in std_logic_vector(15 downto 0);
        sel    : in std_logic;  
        pc_out : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of pc_inc_mux is
    signal pc_4 : std_logic_vector(15 downto 0);
begin

    pc_4 <= std_logic_vector(unsigned(pc_in) + 4);

    pc_out <= pc_4 when sel = '1' else pc_in;

end architecture;
