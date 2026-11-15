library ieee;
use ieee.std_logic_1164.all;

entity pr_2_3 is
   port(
        clock, reset: in std_logic; 
        opcode_in: in std_logic_vector(3 downto 0);
        rd_val_in, rs_val_in, sec_opr_val_in: in std_logic_vector(7 downto 0);
        rd_index_in: in std_logic_vector(2 downto 0);	
        pr_2_3_out: out std_logic_vector(30 downto 0):=(others => '0')
   );
end entity;

architecture struct of pr_2_3 is	
	signal opcode: std_logic_vector(3 downto 0) := "0000";
	signal rd_val, rs_val, sec_opr_val: std_logic_vector(7 downto 0) := "00000000";
	signal rd_index: std_logic_vector(2 downto 0) := "000";
begin

	opcode       <= opcode_in;
	rd_val       <= rd_val_in;
	rs_val       <= rs_val_in;
	sec_opr_val  <= sec_opr_val_in;
	rd_index     <= rd_index_in;

	clk_proc: process(clock, reset)
	begin
		if reset = '1' then
			pr_2_3_out(30 downto 27)      <= "1111";
			pr_2_3_out(26 downto 19)    <= (others => '0');
			pr_2_3_out(18 downto 11)    <= (others => '0');
			pr_2_3_out(10 downto 3)  <= (others => '0');
			pr_2_3_out(2 downto 0)   <= (others => '0');
		elsif rising_edge(clock) then
		
			pr_2_3_out(30 downto 27) <= opcode;
			pr_2_3_out(26 downto 19) <= rd_val;
			pr_2_3_out(18 downto 11) <= rs_val;
			pr_2_3_out(10 downto 3)  <= sec_opr_val;
			pr_2_3_out(2 downto 0)   <= rd_index;

		end if;
	end process;

end struct;
