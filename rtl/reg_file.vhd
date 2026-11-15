library ieee;
use ieee.std_logic_1164.all;

entity reg_file is
  port(
    clock, reset: in std_logic;
    opcode: in std_logic_vector(3 downto 0);
	 opcode1: in std_logic_vector(3 downto 0);
	 
	 rd_index,rs_index,rt_index: in std_logic_vector(2 downto 0);
	 rd_instant,rs_instant,rd_content,rs_content,rt_content: out std_logic_vector(7 downto 0):=(others => '0');
	 imm_field: in std_logic_vector(5 downto 0);
	 rdw_index: in std_logic_vector(2 downto 0);
	 
	 rdw_content: in std_logic_vector(7 downto 0);
	 r00: out std_logic_vector(7 downto 0);
	 r11: out std_logic_vector(7 downto 0); 
	 r33: out std_logic_vector(7 downto 0));
end reg_file;

architecture struct of reg_file is

component mux2X1_8bit_a is 
 port(clock: in std_logic;
 A,B: in std_logic_vector(7 downto 0);
 opcode: in std_logic_vector(3 downto 0);
 Y: out std_logic_vector(7 downto 0):=(others => '0'));
end component;

component se_6to8 is
    port (
        A: in std_logic_vector(5 downto 0);
        C: out std_logic_vector(7 downto 0)
    );
end component;

signal r0:std_logic_vector(7 downto 0) :="00000001";
signal r1:std_logic_vector(7 downto 0) :="00001101";
signal r2:std_logic_vector(7 downto 0) :="00000101";
signal r7:std_logic_vector(7 downto 0) :="00001101";
signal r3, r4, r5, r6: std_logic_vector(7 downto 0) := (others => '0');
signal rt_reg_read: std_logic_vector(7 downto 0):=(others => '0');
signal mux_out, imm_val_se: std_logic_vector(7 downto 0);
begin  
-- Write process
	write_process: process(clock, reset)
	begin
	if rising_edge(clock) then
	if (opcode1(3 downto 0)="0000"  or opcode1(3 downto 0)="0010" or opcode1(3 downto 0)="0011" or opcode1(3 downto 0)="0101") then
		  case rdw_index is
			 when "000" =>
				r0 <= rdw_content;
			 when "001" =>
				r1 <= rdw_content;
			 when "010" =>
				r2 <= rdw_content;
			 when "011" =>
				r3 <= rdw_content;
			 when "100" =>
				r4 <= rdw_content;
			 when "101" =>
				r5 <= rdw_content;
			 when "110" =>
				r6 <= rdw_content;
			 when "111" =>
				r7 <= rdw_content;
			 when others=>
		  end case;
		
		end if ;
		end if;
	end process write_process;
	

-- Read process
	read_process: process(clock, reset)
	begin
	if (opcode(3 downto 0)="0001" or opcode(3 downto 0)="0010" or opcode(3 downto 0)="0011" or opcode(3 downto 0)="0101") then
	
		  case rs_index is
			 when "000" =>
				rs_content <= r0;
			 when "001" =>
				rs_content <= r1;
			 when "010" =>
				rs_content <= r2;
			 when "011" =>
				rs_content <= r3;
			 when "100" =>
				rs_content <= r4;
			 when "101" =>
				rs_content <= r5;
			 when "110" =>
				rs_content <= r6;
			 when "111" =>
				rs_content <= r7;
			 when others=>
		  end case;
		  
		  case rt_index is
			 when "000" =>
				rt_reg_read <= r0;
			 when "001" =>
				rt_reg_read <= r1;
			 when "010" =>
				rt_reg_read <= r2;
			 when "011" =>
				rt_reg_read <= r3;
			 when "100" =>
				rt_reg_read <= r4;
			 when "101" =>
				rt_reg_read <= r5;
			 when "110" =>
				rt_reg_read <= r6;
			 when "111" =>
				rt_reg_read <= r7;
			 when others=>
		  end case;
		  
		  case rd_index is
			 when "000" =>
				rd_content <= r0;
			 when "001" =>
				rd_content <= r1;
			 when "010" =>
				rd_content <= r2;
			 when "011" =>
				rd_content <= r3;
			 when "100" =>
				rd_content <= r4;
			 when "101" =>
				rd_content <= r5;
			 when "110" =>
				rd_content <= r6;
			 when "111" =>
				rd_content <= r7;
			 when others=>
		  end case;
		
		end if;
		
	end process read_process;
	
	se_inst: se_6to8 port map (imm_field,imm_val_se);
	mux_inst: mux2x1_8bit_a port map (clock,imm_val_se,rt_reg_read,opcode(3 downto 0),rt_content);
	
	rd_instant_pr : process(rd_index)
	begin
		  case rd_index is
			 when "000" =>
				rd_instant <= r0;
			 when "001" =>
				rd_instant <= r1;
			 when "010" =>
				rd_instant <= r2;
			 when "011" =>
				rd_instant <= r3;
			 when "100" =>
				rd_instant <= r4;
			 when "101" =>
				rd_instant <= r5;
			 when "110" =>
				rd_instant <= r6;
			 when "111" =>
				rd_instant <= r7;
			 when others=>
		  end case;
	end process;
	
	rs_instant_pr : process(rs_index)
	begin
		  case rs_index is
			 when "000" =>
				rs_instant <= r0;
			 when "001" =>
				rs_instant <= r1;
			 when "010" =>
				rs_instant <= r2;
			 when "011" =>
				rs_instant <= r3;
			 when "100" =>
				rs_instant <= r4;
			 when "101" =>
				rs_instant <= r5;
			 when "110" =>
				rs_instant <= r6;
			 when "111" =>
				rs_instant <= r7;
			 when others=>
		  end case;
	end process;
	r00 <= r0;
	r11 <= r1;
	r33 <= r3;
end struct;