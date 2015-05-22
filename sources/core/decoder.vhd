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
	generic (
		interrupt_vector : unsigned(11 downto 0) := X"3FF"
	);
	Port (
		clk				: in	STD_LOGIC;
		clk2			: in	STD_LOGIC;
		reset			: in	STD_LOGIC;
		sleep			: in	STD_LOGIC;
		sleep_int		: out	STD_LOGIC;
		bram_pause		: out	STD_LOGIC;
		clk2_reset		: out	STD_LOGIC;
		interrupt		: in	STD_LOGIC;
		interrupt_ack	: out	STD_LOGIC;
		instruction		: in	unsigned (17 downto 0);
		opCode			: out	unsigned (5 downto 0);
		opA				: out	unsigned (3 downto 0);
		opB				: out	unsigned (7 downto 0);
		carry			: in	STD_LOGIC;
		zero			: in	STD_LOGIC;
		call			: out	STD_LOGIC;
		ret				: out	std_logic;
		inter_j			: out	std_logic;
		jump			: out	STD_LOGIC;
		jmp_addr		: out	unsigned (11 downto 0);
		io_op_in		: out	std_logic;
		io_op_out		: out	std_logic;
		io_op_out_pp	: out	std_logic;
		io_kk_en		: out	std_logic;
		io_kk_port		: out	unsigned (3 downto 0);
		io_kk_data		: out	unsigned (7 downto 0);
		reg_address		: out	unsigned (7 downto 0);
		reg_select		: out	std_logic;
		spm_addr_ss		: out	unsigned (7 downto 0);
		spm_ss			: out	std_logic;				-- 0: spm_addr = reg1, 1: spm_addr = spm_addr_ss		
		spm_we			: out	std_logic;
		spm_rd			: out	std_logic
	);
end decoder;

architecture Behavioral of decoder is
	
	signal reg_select_o : std_logic;
	signal opCode_o		: unsigned (5 downto 0);
	signal fetch		: std_logic;
	signal store		: std_logic;
	signal inter_en		: std_logic;
	signal inter_j_o	: std_logic;
	signal sleep_int_o	: std_logic;
	
	type sleep_state_t is (awake, sunset, lights_off, sleeping, dawn, sunrise);
	signal sleep_state : sleep_state_t;

begin
	opCode		<= opCode_o;
	opCode_o	<= instruction(17 downto 12);
	opA			<= instruction(11 downto 8);
	opB			<= instruction(7 downto 0);
	jmp_addr	<= instruction(11 downto 0);

	reg_address	<= instruction(11 downto 4);
	reg_select	<= reg_select_o;
	
	spm_addr_ss	<= instruction(7 downto 0);
	spm_ss 		<= opCode_o(0);
	spm_rd 		<= fetch;
	spm_we 		<= store;	
	
	io_op_out_pp	<= instruction(12);			-- constant value (pp) or register as data on the output
	io_kk_data		<= instruction(11 downto 4);
	io_kk_port		<= instruction(3 downto 0);
	
	sleep_int		<= sleep_int_o;
	inter_j			<= inter_j_o;

	decompose : process (instruction, reset, zero, carry, opCode_o) 
	begin
		jump <= '0';
		call <= '0';
		ret <= '0';
		io_op_in <= '0';
		io_op_out <= '0';
		io_kk_en <= '0';
		fetch <= '0';
		store <= '0';
		
		if (reset = '0') then
			case opCode_o is
			when OP_JUMP_AAA => 
				jump <= '1';
			when OP_JUMP_Z_AAA | OP_JUMP_NZ_AAA =>
				jump <= zero xor instruction(14);	-- inst(14) == opCode_o(2): 0 -> Z; 1 -> NZ
			when OP_JUMP_C_AAA | OP_JUMP_NC_AAA =>
				jump <= carry xor instruction(14);	-- inst(14) == opCode_o(2): 0 -> C; 1 -> NC
			when OP_CALL_AAA =>
				call <= '1';
			when OP_CALL_Z_AAA | OP_CALL_NZ_AAA =>
				call <= zero xor instruction(14);	-- inst(14) == opCode_o(2): 0 -> Z; 1 -> NZ
			when OP_CALL_C_AAA | OP_CALL_NC_AAA =>
				call <= carry xor instruction(14);	-- inst(14) == opCode_o(2): 0 -> C; 1 -> NC
			when OP_RETURN | OP_RETURNI_DISABLE =>
				ret <= '1';
			when OP_RETURN_Z | OP_RETURN_NZ =>
				ret <= zero xor instruction(14);	-- inst(14) == opCode_o(2): 0 -> Z; 1 -> NZ
			when OP_RETURN_C | OP_RETURN_NC =>
				ret <= carry xor instruction(14);	-- inst(14) == opCode_o(2): 0 -> C; 1 -> NC
			when OP_INPUT_SX_SY | OP_INPUT_SX_PP =>
				io_op_in <= '1';
			when OP_OUTPUT_SX_SY | OP_OUTPUT_SX_PP =>
				io_op_out <= '1';
			when OP_OUTPUTK_KK_P =>
				io_op_out <= '1';
				io_kk_en <= '1';
			when OP_FETCH_SX_SY | OP_FETCH_SX_SS =>
--				spm_rd <= '1';
				fetch <= '1';
			when OP_STORE_SX_SY | OP_STORE_SX_SS =>
--				spm_we <= '1';
				store <= '1';				
			when others =>

			end case;
		end if;
	end process decompose;

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

	inter_p : process (clk) begin
		if (rising_edge(clk)) then
			if (reset = '1') then 
				inter_en <= '0';
				inter_j_o <= '0';
			else
				inter_j_o <= inter_en and interrupt and clk2;
				if (opCode_o = OP_ENABLE_INTERRUPT or opCode_o = OP_RETURNI_ENABLE or inter_j_o = '1') then
					inter_en <= instruction(0) or inter_j_o;
				else
					inter_en <= inter_en;
				end if;
			end if;
		end if;
	end process inter_p;

	sleep_sm : process (clk) begin
		if (rising_edge(clk)) then
			if (reset = '1') then 
				if (sleep = '1') then
					sleep_state <= sleeping;
				else 
					sleep_state <= awake;
				end if;
			else
				bram_pause <= '0';
				sleep_int_o <= '0';
				clk2_reset <= '0';
				case sleep_state is
				when awake =>
					if (sleep = '1') then
						sleep_state <= sunset;
					end if;
				when sunset =>
					if (clk2 = '1') then
						bram_pause <= '1';
						sleep_state <= lights_off;
					end if;
				when lights_off =>
					bram_pause <= '1';
					if (clk2 = '1') then
						sleep_int_o <= '1';
						sleep_state <= sleeping;
					end if;
				when sleeping =>
					bram_pause <= '1';
					sleep_int_o <= '1';
					if (sleep = '0') then
						clk2_reset <= '1';
						sleep_state <= dawn;
					end if;
				when dawn =>
					sleep_int_o <= '1';
					sleep_state <= sunrise;
				when sunrise =>
					sleep_int_o <= '1';
					if (clk2 = '1') then
						sleep_int_o <= '0';
						sleep_state <= awake;
					end if;
				when others =>
					sleep_state <= awake;
				end case;
			end if;
		end if;	
	end process sleep_sm;

	placeholder : process (clk) begin
		if (rising_edge(clk)) then
			if (reset = '1') then 
				interrupt_ack <= '0';
			else
				interrupt_ack <= inter_j_o;
			end if;
		end if;
	end process placeholder;

end Behavioral;

