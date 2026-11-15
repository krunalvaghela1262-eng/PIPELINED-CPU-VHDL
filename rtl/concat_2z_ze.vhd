library ieee;
use ieee.std_logic_1164.all;

entity concat_2z_ze is
  port(
        A: in std_logic_vector(8 downto 0);
        C: out std_logic_vector(15 downto 0)
  );
end concat_2z_ze;

architecture struct of concat_2z_ze is
signal concat_out : std_logic_vector(9 downto 0);
signal ze_out : std_logic_vector(15 downto 0);

component se_10to16 is
    port (
        A: in std_logic_vector(9 downto 0);
        C: out std_logic_vector(15 downto 0)
    );
end component;

begin

	process(A)
		 variable ans: std_logic_vector(9 downto 0) := (others => '0');
	begin
		 
		 loop1: for i in 9 downto 1 loop
			  ans(i) := A(i-1);
		 end loop loop1;

		 ans(0) := '0';

		 concat_out <= ans;
		 
	end process;

	 se_inst: se_10to16 
	 port map(
			A=>concat_out,
			C=>ze_out
		);

	C <= ze_out;

end struct;