library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU1 is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        A      : in  std_logic_vector(7 downto 0);  -- Operand 1
        B      : in  std_logic_vector(7 downto 0);  -- Operand 2 or Immediate
        opcode : in  std_logic_vector(3 downto 0);  -- 4-bit operation code
        C      : out std_logic_vector(7 downto 0):=(others => '0')   -- ALU result
        -- Z   : out std_logic                      -- Zero flag
    );
end ALU1;

architecture behavioral of ALU1 is

    signal result : std_logic_vector(7 downto 0);
    -- signal zero   : std_logic;

    -- Fix function parameter declarations
    function add(a : std_logic_vector(7 downto 0); b : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(to_integer(signed(a)) + to_integer(signed(b)), 8));
    end function;

    function sub(a : std_logic_vector(7 downto 0); b : std_logic_vector(7 downto 0)) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(to_integer(signed(a)) - to_integer(signed(b)), 8));
    end function;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            result <= (others => '0');
            -- zero <= '0';

        else
            case opcode is
                when "0010" =>  -- ADD
                    result <= add(A, B);

                when "0011" =>  -- SUB
                    result <= sub(A, B);

                when "0101" =>  -- ADDI (B = immediate)
                    result <= add(A, B);

                when "0000" | "0001" =>  -- LW or SW (pass-through operand B)
                    result <= A;

                when others =>
                    result <= (others => '0');
            end case;
        end if;
    end process;

    -- Output assignment
    C <= result;
    -- Z <= zero;

end behavioral;
