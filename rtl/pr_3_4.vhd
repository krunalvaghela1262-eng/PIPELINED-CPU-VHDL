library ieee;
use ieee.std_logic_1164.all;

entity pr_3_4 is
   port(
        clock, reset: in std_logic; 
        opcode_in: in std_logic_vector(3 downto 0);
        rd_val_in, alu_result_in: in std_logic_vector(7 downto 0);
        rd_index_in: in std_logic_vector(2 downto 0);
        pr_3_4_out: out std_logic_vector(22 downto 0):="00110000000000000000000"
   );
end entity;

architecture struct of pr_3_4 is	
	signal opcode: std_logic_vector(3 downto 0) := "1111";
	signal rd_val, alu_result: std_logic_vector(7 downto 0) := "00000000";
	signal rd_index: std_logic_vector(2 downto 0) := "000";
begin

	clk_proc: process(clock, reset)
	begin
		if reset = '1' then
			opcode     <= "1111";
			rd_val     <= (others => '0');
			alu_result <= (others => '0');
			rd_index   <= (others => '0');
		elsif rising_edge(clock) then
			opcode     <= opcode_in;
			rd_val     <= rd_val_in;
			alu_result <= alu_result_in;
			rd_index   <= rd_index_in;
		end if;
	end process;

	pr_3_4_out(22 downto 19) <= opcode;
	pr_3_4_out(18 downto 11) <= rd_val;
	pr_3_4_out(10 downto 3)  <= alu_result;
	pr_3_4_out(2 downto 0)   <= rd_index;

end struct;
