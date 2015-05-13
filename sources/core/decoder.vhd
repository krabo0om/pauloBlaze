----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:41:35 05/06/2015 
-- Design Name: 
-- Module Name:    decoder - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.op_codes.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
	Port (
		clk				: in  STD_LOGIC;
		reset			: in  STD_LOGIC;
		sleep			: in  STD_LOGIC;
		interrupt		: in  STD_LOGIC;
		interrupt_ack	: out STD_LOGIC;
		instruction		: in  unsigned (17 downto 0);
		opCode			: out unsigned (5 downto 0);
		opA				: out unsigned (3 downto 0);
		opB				: out unsigned (7 downto 0);
		carry			: in  STD_LOGIC;
		zero			: in  STD_LOGIC;
		jump			: out STD_LOGIC;
		jmp_addr		: out unsigned (11 downto 0);
		io_op_in		: out std_logic;
		io_op_out		: out std_logic;
		io_op_out_pp	: out std_logic;
		io_kk_en		: out std_logic;
		io_kk_port		: out unsigned (3 downto 0);
		io_kk_data		: out unsigned (7 downto 0);
		reg_address		: out unsigned (7 downto 0);
		reg_select		: out std_logic
	);
end decoder;

architecture Behavioral of decoder is
	
	signal reg_select_o : std_logic;
	signal opCode_o		: unsigned (5 downto 0);

begin
	opCode		<= opCode_o;
	opA			<= instruction(11 downto 8);
	opB			<= instruction(7 downto 0);
	jmp_addr	<= instruction(11 downto 0);

	reg_address	<= instruction(11 downto 4);
	reg_select	<= reg_select_o;
	
	io_op_out_pp <= instruction(12);			-- constant value (pp) or register as data on the output
	io_kk_data <= instruction(11 downto 4);
	io_kk_port <= instruction(3 downto 0);	

	decompse : process (instruction, reset, zero, carry) 
		variable opCode_v : unsigned(5 downto 0);
	begin
		opCode_v	:= instruction(17 downto 12);
		opCode_o	<= opCode_v;
		
		jump <= '0';
		io_op_in <= '0';
		io_op_out <= '0';
		io_kk_en <= '0';
		
		if (reset = '0') then
			case opCode_v is
			when OP_JUMP_AAA => 
				jump <= '1';
			when OP_JUMP_Z_AAA | OP_JUMP_NZ_AAA =>
				jump <= zero xor instruction(14);	-- inst(14) == opCode_o(2): 0 -> Z; 1 -> NZ
			when OP_JUMP_C_AAA | OP_JUMP_NC_AAA =>
				jump <= carry xor instruction(14);	-- inst(14) == opCode_o(2): 0 -> C; 1 -> NC
			when OP_INPUT_SX_SY | OP_INPUT_SX_PP =>
				io_op_in <= '1';
			when OP_OUTPUT_SX_SY | OP_OUTPUT_SX_PP =>
				io_op_out <= '1';
			when OP_OUTPUTK_KK_P =>
				io_op_out <= '1';
				io_kk_en <= '1';
			when others =>

			end case;
		end if;
		
	end process decompse;

	reg_proc : process (clk) begin
		if (rising_edge(clk)) then
			if (reset = '1') then 
				reg_select_o <= '0';
			else
				if (opCode_o = OP_REGBANK_A) then
					reg_select_o <= instruction(0);
				else
					reg_select_o <= reg_select_o;
				end if;
			end if;
		end if;
	end process reg_proc;

	placeholder : process (clk) begin
		if (rising_edge(clk)) then
			if (reset = '1') then 
				interrupt_ack <= '0';
			else
				interrupt_ack <= carry and zero;
			end if;
		end if;
	end process placeholder;

end Behavioral;

