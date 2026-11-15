library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity proc is
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
	 --lol4 : out std_logic_vector(30 downto 0)
	r0,r1,r3: out std_logic_vector(7 downto 0)
	 
	);
end proc;

architecture rtl of proc is
	-- Signals connecting the different pipeline stages
	
	-- Dummy signals to copy entries from IMEM to DMEM
	signal rd_en_IMEM,n : std_logic;
	signal data1,pc_in,pc_o,pc_on,pc_on1,data1rd11: std_logic_vector(15 downto 0);
	signal data2: std_logic_vector(30 downto 0);
	signal data3: std_logic_vector(22 downto 0);
	signal data4: std_logic_vector(22 downto 0);
	signal rd_valid_IMEM : std_logic;
	signal data : std_logic_vector(RAM_WIDTH - 1 downto 0);
	signal data1rd,data1rs,data1rt,data1rt0,mux1o,mux2o,rd_data_DMEM,alu1o: std_logic_vector(7 downto 0);
	signal r00, r11, r33: std_logic_vector(7 downto 0);
	signal rd_inst, rs_inst: std_logic_vector(7 downto 0);
	
	signal wr_en_DMEM : std_logic;

	component pr_4_5 is
   port(
      clock: in std_logic; 
      reset: in std_logic;
      opcode_in: in std_logic_vector(3 downto 0);
      mem_data_in, alu_result_in: in std_logic_vector(7 downto 0);
      rd_index_in: in std_logic_vector(2 downto 0);
      pr_4_5_out: out std_logic_vector(22 downto 0)
   );
end component;
	component pr_3_4 is
   port(
        clock, reset: in std_logic; 
        opcode_in: in std_logic_vector(3 downto 0);
        rd_val_in, alu_result_in: in std_logic_vector(7 downto 0);
        rd_index_in: in std_logic_vector(2 downto 0);
        pr_3_4_out: out std_logic_vector(22 downto 0)
   );
end component;
	component pr_2_3 is
   port(
        clock, reset: in std_logic; 
        opcode_in: in std_logic_vector(3 downto 0);
        rd_val_in, rs_val_in, sec_opr_val_in: in std_logic_vector(7 downto 0);
        rd_index_in: in std_logic_vector(2 downto 0);	
        pr_2_3_out: out std_logic_vector(30 downto 0)
   );
end component;
component pr_1_2 is
   port(clock, reset: in std_logic; 
			instr_in: in std_logic_vector(15 downto 0);
			PC_in: in std_logic_vector(15 downto 0);
			instr_out: out std_logic_vector(15 downto 0):=(others => '0');
			PC_out: out std_logic_vector(15 downto 0):="0000000000000100"
			);
end component;


	component mux2X1_8bit_b is 
 port(
 clock: in std_logic;
 A,B: in std_logic_vector(7 downto 0);
 opcode: in std_logic_vector(3 downto 0);
 Y: out std_logic_vector(7 downto 0));
end component;

	component mux2X1_8bit_a is 
 port(clock: in std_logic;
 A,B: in std_logic_vector(7 downto 0);
 opcode: in std_logic_vector(3 downto 0);
 Y: out std_logic_vector(7 downto 0));
end component;
	component ALU1 is
		 port (
			  clk    : in  std_logic;
			  reset  : in  std_logic;
			  A      : in  std_logic_vector(7 downto 0);  -- Operand 1
			  B      : in  std_logic_vector(7 downto 0);  -- Operand 2 or Immediate
			  opcode : in  std_logic_vector(3 downto 0);  -- 4-bit operation code
			  C      : out std_logic_vector(7 downto 0)   -- ALU result
			  -- Z   : out std_logic                      -- Zero flag
		 );
	end component ALU1;
	component  se_6to8 is
    port (
        A: in std_logic_vector(5 downto 0);
        C: out std_logic_vector(7 downto 0)
    );
    end component ;
	 
	component reg_file is
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
	end component;
	
	component ring_buffer is
	   generic (
    -- 16 bit data
    
    RAM_DEPTH : integer := 32;
	 RAM_WIDTH : integer := 16
	 
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
	 opcode: in std_logic_vector(3 downto 0);
    -- Write port
    wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0):=(others => '0');
  
    -- Read port
 
    rd_valid : out std_logic;
    rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0);
  
    -- Flags
    empty : out std_logic;
    empty_next : out std_logic;
    full : out std_logic;
    full_next : out std_logic;
    n_pc: in std_logic;
	 pc_update: in std_logic_vector(RAM_WIDTH - 1 downto 0); 
    -- The number of elements in the FIFO
    fill_count : out integer range RAM_DEPTH - 1 downto 0
  );
	end component;
	component program_counter is
  port(
		clock, reset: in std_logic;
		n_pc: in std_logic;
		PC_in: in std_logic_vector(15 downto 0);
		PC_out: out std_logic_vector(15 downto 0);
		PC_out_next: out std_logic_vector(15 downto 0));
   end component;
	component ring_buffermem is
	   generic (
    -- 16 bit data
    
    RAM_DEPTH : integer := 32;
	 RAM_WIDTH : integer := 8
	 
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
	 opcode: in std_logic_vector(3 downto 0);
    -- Write port
    wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0):=(others => '0');
  
    -- Read port
 
    rd_valid : out std_logic;
    rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0):=(others => '0');
  
    -- Flags
    empty : out std_logic;
    empty_next : out std_logic;
    full : out std_logic;
    full_next : out std_logic;
  
    -- The number of elements in the FIFO
    fill_count : out integer range RAM_DEPTH - 1 downto 0
  );
	end component;
	component next_addr_bl is
  port(
	 opcode: in std_logic_vector(3 downto 0);
	 ec_opr1, ec_opr2: in std_logic_vector(7 downto 0); 
	 imm6: in std_logic_vector(5 downto 0);
	 imm9: in std_logic_vector(8 downto 0);
	 base_read, incr_pc: in std_logic_vector(15 downto 0);
	 addr_flag: out std_logic;
	 pc_write: out std_logic_vector(15 downto 0)
  );
  end component;
  component se8to16 is
    port (
        A: in std_logic_vector(7 downto 0);
        C: out std_logic_vector(15 downto 0)
    );
end component;
	---- 2. Fetch stage
	---- 3. And so on
	
	begin
	rd_en_IMEM <= '1';
	wr_en_DMEM <= '1';
	
	IMEM: ring_buffer
			port map(
				clk => clk,
				rst => rst,
				opcode=>"1111",
		
				wr_data => open,
		
				rd_valid => open,
				rd_data => data,
				empty => open,
				empty_next => open,
				full => open,
				full_next => open,
				n_pc =>  n ,
	         pc_update => pc_o,
	   			
				fill_count => open	
			);
			
	
	pip_1:pr_1_2 port map(clk,rst,data,pc_on,data1,pc_on1);
	pc: program_counter port map(clk,rst,n,pc_in,pc_o,pc_on);
	hehe: se8to16 port map(rd_inst,data1rd11);
	naddr: next_addr_bl port map(data1(15 downto 12),rd_inst,rs_inst,data1(5 downto 0),data1(8 downto 0),data1rd11,pc_on,n,pc_in);
	reglol:reg_file port map(clk,rst,data1(15 downto 12),data4(22 downto 19),data1(11 downto 9),data1(8 downto 6),data1(5 downto 3),rd_inst,rs_inst,data1rd,data1rs,
	      data1rt,data1(5 downto 0),data4(2 downto 0),mux2o,r00,r11,r33);
	--se_8:se_6to8 port map(data1(5 downto 0),data1rt0);
	--mux_1: mux2x1_8bit_a port map (clk,data1rt0,data1rt,data1(15 downto 12),mux1o);
	pip_2:pr_2_3 port map(clk,rst,data1(15 downto 12),data1rd,data1rs,data1rt,data1(11 downto 9),data2);
	--lol4<=data2;
	alu_1:ALU1 port map(clk,rst,data2(18 downto 11),data2(10 downto 3),data2(30 downto 27),alu1o);
	lol1<= alu1o;
	pip_3:pr_3_4 port map(clk,rst,data2(30 downto 27),data2(26 downto 19),alu1o,data2(2 downto 0),data3);
	lol3<= data4;
	DMEM: ring_buffermem
		port map(
			clk => clk,
			rst => rst,
			opcode=>data3(22 downto 19),
			wr_data => data3(18 downto 11),
			rd_valid => open,
			rd_data => rd_data_DMEM,
			empty => open,
			empty_next => open,
			full => open,
			full_next => open,
			fill_count => open
		);
	lol<=data1;
	pip_4:pr_4_5 port map(clk,rst,data3(22 downto 19),rd_data_DMEM,data3(10 downto 3),data3(2 downto 0),data4);
	mux_2:mux2X1_8bit_b port map(clk,data4(18 downto 11),data4(10 downto 3),data4(22 downto 19),mux2o);
	lol2<=mux2o;
	
	r0<=r00;
	r1<=r11;
	r3<=r33;
end architecture;