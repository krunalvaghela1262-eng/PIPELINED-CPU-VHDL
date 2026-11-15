LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity testbench is 
end testbench;

architecture rtl of testbench is

-- Declaring component to test
	component proc is
		generic (
			 -- 16 bit data
			 RAM_WIDTH : integer := 16;
			 RAM_DEPTH : integer := 32
		  );
		port(
		  clk : in std_logic;
        rst : in std_logic;
		  lol : out std_logic_vector(15 downto 0);
		  lol1 : out std_logic_vector(7 downto 0);
	     lol2 :out std_logic_vector(7 downto 0);
		   lol3 :out std_logic_vector(22 downto 0);
	    r0,r1,r3: out std_logic_vector(7 downto 0)


		 );
	end component;
	
	-- Signal Declarations
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal lol : std_logic_vector(15 downto 0) ;
	 signal lol1 :  std_logic_vector(7 downto 0);
	signal lol2 : std_logic_vector(7 downto 0);
	signal lol3 : std_logic_vector(22 downto 0);
	signal r0,r1,r3 :  std_logic_vector(7 downto 0);

	begin
	DUT: proc port map(
		clk => clk,
		rst => rst,
		lol => lol,
		lol1 => lol1,
		lol2 => lol2,
		lol3 => lol3,
		r0 => r0,
		r1 => r1,
		r3 => r3);
	
	clk <= not clk after 10ns;
	rst <= '1', '0' after 5ns;


end architecture;