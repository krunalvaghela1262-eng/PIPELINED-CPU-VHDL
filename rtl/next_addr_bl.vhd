library ieee;
use ieee.std_logic_1164.all;

entity next_addr_bl is
  port(
	 opcode: in std_logic_vector(3 downto 0);
	 ec_opr1, ec_opr2: in std_logic_vector(7 downto 0); 
	 imm6: in std_logic_vector(5 downto 0);
	 imm9: in std_logic_vector(8 downto 0);
	 base_read, incr_pc: in std_logic_vector(15 downto 0);
	 addr_flag: out std_logic;
	 pc_write: out std_logic_vector(15 downto 0)
  );
end next_addr_bl;

architecture struct of next_addr_bl is
signal eq_flag: std_logic;
signal imm6_sig, imm9_sig: std_logic_vector(15 downto 0);
signal mux1_out, mux2_out, mux3_out: std_logic_vector(15 downto 0);
signal PC_out_sig: std_logic_vector(15 downto 0);
signal a_flag: std_logic;

component beq_check is
    port (
        opcode    : in  std_logic_vector(3 downto 0);
        A, B      : in  std_logic_vector(7 downto 0);
        beq_flag  : out std_logic
    );
end component;

component concat_2z_ze is
  port(
        A: in std_logic_vector(8 downto 0);
        C: out std_logic_vector(15 downto 0)
  );
end component;

component concat_2z_ze6 is
  port(
        A: in std_logic_vector(5 downto 0);
        C: out std_logic_vector(15 downto 0)
  );
end component;

component mux2X1_16bit is 
    port(
        A, B: in std_logic_vector(15 downto 0);
        s : in std_logic;
        Y      : out std_logic_vector(15 downto 0) := (others => '0')
    );
end component;

component add_16bit is
    port (
        opcode      : in  std_logic_vector(3 downto 0);
        A, B        : in  std_logic_vector(15 downto 0);
        result      : out std_logic_vector(15 downto 0);
        adder_flag  : out std_logic
    );
end component;

component mux2X1_16bito is 
    port(
        opcode : in std_logic_vector(3 downto 0);
        A, B: in std_logic_vector(15 downto 0);
        Y      : out std_logic_vector(15 downto 0) := (others => '0')
    );
end component;

component mux2X1_zero is 
    port(
        opcode : in std_logic_vector(3 downto 0);
        A, B: in std_logic_vector(15 downto 0);
        Y      : out std_logic_vector(15 downto 0) := (others => '0')
    );
end component;

begin
	beq_check_inst: beq_check port map
	(
		opcode => opcode,
		A => ec_opr1,
		B => ec_opr2,
		beq_flag => eq_flag
	);
	
	imm6_inst: concat_2z_ze6 port map
	(
		A=>imm6,
		C=>imm6_sig
	);
	
	imm9_inst: concat_2z_ze port map
	(
		A=>imm9,
		C=>imm9_sig
	);

	mux_inst1: mux2X1_16bit port map
	(
		A=>imm9_sig,
		B=>imm6_sig,
		s=>eq_flag,
		Y=>mux1_out
	);
	
	mux_inst2: mux2X1_16bito port map
	(
		opcode=>opcode,
		A=>base_read,
		B=>incr_pc,
		Y=>mux2_out
	);
	
	mux_inst3: mux2X1_zero port map
	(
		opcode=>opcode,
		A=>mux1_out,
		B=>"0000000000000000",
		Y=>mux3_out
	);
	
	adder_inst: add_16bit port map
	(
		opcode=>opcode,
		A=>mux2_out,
		B=>mux3_out,
		result=> PC_out_sig,
		adder_flag=>a_flag
	);
	
	pc_write<=PC_out_sig;		
	addr_flag <= a_flag;
	
end struct;