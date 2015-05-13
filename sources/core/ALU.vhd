----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:21:39 05/05/2015 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
--use ieee.std_logic_unsigned.all;	-- yeah yeah i know, not standardiesd and has problems
									-- TODO switch every slv + slv to unsigned(slv) + unsigned(slv) -_-
use IEEE.NUMERIC_STD.ALL;
use work.op_codes.all;
use work.debugSignals.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
	generic (
		debug	: boolean := false
--		scratch_pad_memory_size	: integer := 64
		);
	Port (
		clk					: in	STD_LOGIC;
		reset				: in	STD_LOGIC;
		opcode				: in	unsigned (5 downto 0);
--		opA					: in	unsigned (3 downto 0);
		opB					: in	unsigned (7 downto 0);
		carry				: out	STD_LOGIC;
		zero				: out	STD_LOGIC;
		reg_value			: out	unsigned (7 downto 0);
		reg_we				: out	std_logic;
		reg_reg0	 		: in	unsigned (7 downto 0);
		reg_reg1	 		: in	unsigned (7 downto 0)
		
--		debugS_alu	: out	debug_signals
		);
end ALU;

architecture Behavioral of ALU is

					
	signal result			: unsigned(7 downto 0);
	signal res_valid		: std_logic;	-- result should be written to register
--	signal scratch_valid	: std_logic;	-- result should be written to scratchpad
--	signal scratchAddr		: unsigned(7 downto 0);
	signal clk_cycle2		: std_logic;	-- toogles every cycle, high = write back cycle
	
	signal carry_c	: std_logic;
	signal carry_o	: std_logic;
	signal zero_c	: std_logic;	
	signal zero_o	: std_logic;
	
--	signal io_input_valid	: std_logic;
	
	signal debug_opA_value : unsigned(7 downto 0);
	signal debug_opB_value : unsigned(7 downto 0);

begin

	
	debug_assignments : if (debug = true) generate begin	-- TODO doesn't work 
--		debugS_alu.regFile			<= regFile;
--		debugS_alu.scratchpad((scratch_pad_memory_size-1) downto 0)	<= scratchpad;
--		debugS_alu.scratch_valid	<= scratch_valid;
--		debugS_alu.scratchAddr		<= scratchAddr;
--		debugS_alu.carry			<= carry_o;
--		debugS_alu.zero				<= zero_o;
--		debugS_alu.reg_select		<= reg_select;
	end generate debug_assignments;

	
	reg_value	<= result;
	reg_we		<= clk_cycle2 and res_valid;

	carry		<= carry_o;
	zero		<= zero_o;

	op : process (reset, opcode, opB, carry_o, zero_o, reg_reg0, reg_reg1, clk_cycle2) 
		variable opB_value	: unsigned(7 downto 0);
		variable opA_value	: unsigned(7 downto 0);
		variable result_v	: unsigned(8 downto 0);
		variable partiy_v	: std_logic;
		variable padding	: std_logic;
	begin
		if (debug) then
			padding := '0';			--looks better during simulation
		else
			padding := '-';
		end if;
		res_valid <= '0';
		carry_c <= carry_o;
		zero_c <= zero_o;
		result_v := (others => padding);
		partiy_v := '0';
--		io_input_valid <= '0';
		
		opA_value := reg_reg0;
		if (opcode (0) = '0') then	-- LSB 0 = op_x sx, sy
			opB_value := reg_reg1;
		else						-- LSB 1 = op_x sx, kk
			opB_value := opB;
		end if;
		
		debug_opA_value <= opA_value;
		debug_opB_value <= opB_value;
--		debugS_alu.opA_value	<= opA_value;
--		debugS_alu.opB_value	<= opB_value;
		
		if (reset = '0') then
			case opcode is 
				--Register loading
				when OP_LOAD_SX_SY | OP_LOAD_SX_KK=> 
					result_v := padding & opB_value;
					res_valid <= '1';
				when OP_STAR_SX_SY =>
				--Logical
				when OP_AND_SX_SY | OP_AND_SX_KK =>
					result_v := padding & (opA_value and opB_value);
					res_valid <= '1';
					if (result_v(7 downto 0) = "00000000") then 
						zero_c <= '1';
					else
						zero_c <= '0';
					end if;
					carry_c <= '0';
				when OP_OR_SX_SY | OP_OR_SX_KK =>
					result_v := padding & (opA_value or opB_value);
					res_valid <= '1';
					if (result_v(7 downto 0) = "00000000") then 
						zero_c <= '1';
					else
						zero_c <= '0';
					end if;
					carry_c <= '0';
				when OP_XOR_SX_SY | OP_XOR_SX_KK =>
					result_v := padding & (opA_value xor opB_value);
					res_valid <= '1';
					if (result_v(7 downto 0) = "00000000") then 
						zero_c <= '1';
					else
						zero_c <= '0';
					end if;
					carry_c <= '0';
				--Arithmetic
				when OP_ADD_SX_SY | OP_ADD_SX_KK | OP_SUB_SX_SY | OP_SUB_SX_KK |
						OP_ADDCY_SX_SY | OP_ADDCY_SX_KK | OP_SUBCY_SX_SY | OP_SUBCY_SX_KK =>
					if (opcode(3) = '0') then			
						result_v := ('0' & opA_value) + ('0' & opB_value) + ("" & (carry_o and opCode(1)));
					else 
						result_v := ('0' & opA_value) - ('0' & opB_value) - ("" & (carry_o and opCode(1)));
					end if;
					
					if (result_v(7 downto 0) = "00000000") then 
						zero_c <= '1';
					else
						zero_c <= '0';
					end if;
					carry_c <= result_v(8);
					res_valid <= '1';
				--Test and Compare
				when OP_TEST_SX_SY | OP_TEST_SX_KK | OP_TESTCY_SX_SY | OP_TESTCY_SX_KK =>
					result_v := (padding & (opA_value and opB_value));
					-- opCode(1) == 0 : TEST
					-- opCode(1) == 1 : TESTCY
					if (result_v(7 downto 0) = "00000000") then 
						if (opCode(1) = '0') then
							zero_c <= '1';
						else
							zero_c <= zero_o;
						end if;
					else
						zero_c <= '0';
					end if;
					
					for i in 0 to 7 loop 
						partiy_v := partiy_v xor result_v(i);
					end loop;
					partiy_v := (partiy_v and not opCode(1)) or (carry_o and opCode(1));
					carry_c <= partiy_v;
				when OP_COMPARE_SX_SY | OP_COMPARE_SX_KK | OP_COMPARECY_SX_SY | OP_COMPARECY_SX_KK =>
					-- opCode(1) == 0 : COMAPRE
					-- opCode(1) == 1 : COMAPRECY
					if (opCode(1) = '0') then
						result_v := ('0' & opA_value) - ("" & opB_value);
					else 
						result_v := ('0' & opA_value) - ('0' & opB_value) - ("" & carry_o);
					end if;
					
					if (result_v(7 downto 0) = "00000000") then 
						if (opCode(1) = '0') then
							zero_c <= '1';
						else
							zero_c <= zero_o;
						end if;
					else
						zero_c <= '0';	-- dont care also possible
					end if;
					
					carry_c <= result_v(8);
				--Shift and Rotate
				when OP_SL0_SX =>
					
					case opB(2 downto 0) is
						when "110" | "111" =>
							result_v(0) := opB(0);
						when "100" | "010" =>	-- rotate and 
							result_v(0) := opA_value(0);
						when "000" => 
							result_v(0) := carry_o;
						when others =>
							result_v(0) := '0';
					end case;
		--			result_v(0) := opB(0) or (opB_value(2 downto 0) and carry_o) or opA_value(0);
					
					carry_c <= result_v(8);
					if (result_v(7 downto 0) = "00000000") then 
						zero_c <= '1';
					else
						zero_c <= '0';
					end if;
		--		when OP_SL1_SX =>
		--		when OP_SLX_SX =>
		--		when OP_SLA_SX =>
		--		when OP_RL_SX =>
		--		when OP_SR0_SX =>
		--		when OP_SR1_SX =>
		--		when OP_SRX_SX =>
		--		when OP_SRA_SX =>
		--		when OP_RR_SX =>
				--Register Bank Selection
--				when OP_REGBANK_A =>
--					reg_select_c <= opB_value(0);
		--		when OP_REGBANK_B =>
				-- Scratch Pad Mem
--				when OP_STORE_SX_SY | OP_STORE_SX_SS =>
	--				result_v := padding & opA_value;
	--				scratch_valid <= '1';
	--				scratchAddr <= opB_value;
--				when OP_FETCH_SX_SY | OP_FETCH_SX_SS =>
	--				result_v := padding & scratchpad(to_integer(unsigned(opB_value)));
	--				res_valid <= '1';
				when others =>
					result_v := (others => 'X');
			end case;
		end if;
		result <= result_v(7 downto 0);
--		debugS_alu.result_v <= result_v;
	end process;

	clken : process (clk) begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				carry_o <= '0';
				zero_o <= '0';
--				reg_select_o <= '0';
				clk_cycle2 <= '1';
			else 
--				if (scratch_valid = '1' and clk_cycle2 = '1') then
--					scratchpad(to_integer(unsigned(scratchAddr))) <= result;
--				end if;
				if (clk_cycle2 = '1') then
					carry_o <= carry_c;
					zero_o <= zero_c;
--					reg_select_o <= reg_select_c;
				else
					carry_o <= carry_o;
					zero_o <= zero_o;
--					reg_select_o <= reg_select_o;
				end if;
			
				clk_cycle2 <= not clk_cycle2;
			end if;
		end if;

	end process;

end Behavioral;

