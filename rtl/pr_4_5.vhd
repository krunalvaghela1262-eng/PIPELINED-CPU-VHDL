library ieee;
use ieee.std_logic_1164.all;

entity pr_4_5 is
   port(
      clock: in std_logic; 
      reset: in std_logic;
      opcode_in: in std_logic_vector(3 downto 0);
      mem_data_in, alu_result_in: in std_logic_vector(7 downto 0);
      rd_index_in: in std_logic_vector(2 downto 0);
      pr_4_5_out: out std_logic_vector(22 downto 0):=(others => '0')
   );
end entity;

architecture struct of pr_4_5 is	
   signal opcode: std_logic_vector(3 downto 0) := "0000";
   signal mem_data, alu_result: std_logic_vector(7 downto 0) := "00000000";
   signal rd_index: std_logic_vector(2 downto 0) := "000";

begin

   clk_proc: process(clock, reset)
   begin
      if reset = '1' then  -- Active-low reset
         opcode      <= (others => '0');
         mem_data    <= (others => '0');
         alu_result  <= (others => '0');
         rd_index    <= (others => '0');
      elsif rising_edge(clock) then
         opcode      <= opcode_in;
         mem_data    <= mem_data_in;
         alu_result  <= alu_result_in;
         rd_index    <= rd_index_in;
      end if;
   end process;

   pr_4_5_out(22 downto 19) <= opcode;
   pr_4_5_out(18 downto 11) <= mem_data;
   pr_4_5_out(10 downto 3)  <= alu_result;
   pr_4_5_out(2 downto 0)   <= rd_index;

end struct;
