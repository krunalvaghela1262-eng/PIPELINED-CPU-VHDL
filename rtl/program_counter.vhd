library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
  generic (
    -- 16 bit data
    
    RAM_DEPTH : integer := 32;
	 RAM_WIDTH : integer := 16
	 
  );
  port(
		clock, reset: in std_logic;
		n_pc: in std_logic;
		PC_in: in std_logic_vector(15 downto 0);
		PC_out: out std_logic_vector(15 downto 0);
		PC_out_next: out std_logic_vector(15 downto 0));
end program_counter;

architecture struct of program_counter is
type ram_type is array (0 to RAM_DEPTH - 1) of
 std_logic_vector(15 downto 0);
--signal PC_sig : std_logic_vector(15 downto 0);
signal wh : std_logic_vector(15 downto 0):="0000000000000010";
subtype index_type is integer range ram_type'range;
signal prog_ctr_int : index_type := 0;

--  signal prog_buffer : integer; 
--  signal PC_sig : std_logic_vector(15 downto 0):="0000000000000000";
begin
	
	--PC_next <= std_logic_vector(to_unsigned((to_integer(signed(PC_sig)) + to_integer(signed(wh))),16));
	
	--clk_proc: process(clock)
	--begin
	--if rising_edge(clock) then
	--	if n_pc='1' then
	--		PC_sig<=PC_in;
	--	else 
	--		PC_sig<=PC_next;
	--	end if;
	--		PC_out <= PC_sig;
	--		PC_out_next <= std_logic_vector(to_unsigned((to_integer(signed(PC_sig)) + to_integer(signed(wh))),16));
	-- end if;
	
pc_read_process: process(PC_in)
    variable pc_temp    : unsigned(15 downto 0);
	 variable buffer_int : integer;
begin
    if (to_integer(signed(PC_in)) > 29) then
        buffer_int := 0;
    else
        buffer_int := to_integer(signed(PC_in));
    end if;

    prog_ctr_int <= buffer_int;
end process;	

clk_process: process(clock)
begin	
	 if falling_edge(clock) then
		 PC_out <= std_logic_vector(to_unsigned(prog_ctr_int, 16));
		 PC_out_next <= std_logic_vector(to_unsigned(prog_ctr_int, 16) + unsigned(wh));
	 end if;
end process;
end struct;