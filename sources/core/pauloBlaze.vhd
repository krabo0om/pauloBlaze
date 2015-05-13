----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:01:17 05/05/2015 
-- Design Name: 
-- Module Name:    pauloBlaze - Behavioral 
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
use work.debugSignals.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pauloBlaze is
	generic(
		debug					: boolean := false;
		hwbuild					: unsigned(7 downto 0) := X"00";
		interrupt_vector		: unsigned(11 downto 0) := X"3FF";
		scratch_pad_memory_size	: integer := 64);
	port (
		-- control
		clk				: in std_logic;
		reset			: in std_logic;
		sleep			: in std_logic;
		-- instruction memory
		address			: out unsigned(11 downto 0);
		instruction		: in  unsigned(17 downto 0);
		bram_enable		: out std_logic;
		-- i/o ports
		in_port			: in  unsigned(7 downto 0);
		out_port		: out unsigned(7 downto 0);
		port_id			: out unsigned(7 downto 0);
		write_strobe	: out std_logic;
		k_write_strobe	: out std_logic;
		read_strobe 	: out std_logic;
		-- interrupts
		interrupt		: in  std_logic;
		interrupt_ack	: out std_logic
		-- debug
--		debugS			: out debug_signals
		);
end pauloBlaze;


architecture Behavioral of pauloBlaze is

	-- signals alu in
	signal opcode			: unsigned(5 downto 0);
	signal opA				: unsigned(3 downto 0);
	signal opB				: unsigned(7 downto 0);
	-- signals alu out
	signal carry			: STD_LOGIC;
	signal zero				: STD_LOGIC;

	-- signals pc in
	signal jump			: STD_LOGIC;
	signal jmp_addr		: unsigned (11 downto 0);

	signal debug_alu	: debug_signals;
	
	-- signals decoder
	signal io_op_in		: std_logic;
	signal io_op_out	: std_logic;	
	signal io_op_out_pp	: std_logic;	
	signal io_kk_en		: std_logic;
	signal io_kk_port	: unsigned (3 downto 0);
	signal io_kk_data	: unsigned (7 downto 0);
	
	-- general register file signals
	signal reg_select	: std_logic;
	signal reg_reg0		: unsigned (7 downto 0);
	signal reg_reg1		: unsigned (7 downto 0);
	signal reg_address	: unsigned (7 downto 0);	
	signal reg_value	: unsigned (7 downto 0);
	signal reg_we		: std_logic;
	-- signals register file from alu
	signal reg_value_a	: unsigned (7 downto 0);
	signal reg_we_a		: std_logic;
	-- signals register file from io
	signal reg_value_io	: unsigned (7 downto 0);
	signal reg_we_io	: std_logic;

	
begin
	
--	debug_assignments : if (debug = true) generate begin
--		assert false report "du bist doof" severity note;
----		debugS.regFile			<= debug_alu.regFile;
----		debugS.scratchpad		<= debug_alu.scratchpad;
----		debugS.scratch_valid	<= debug_alu.scratch_valid;
----		debugS.scratchAddr		<= debug_alu.scratchAddr;
----		debugS.carry			<= debug_alu.carry;
----		debugS.zero				<= debug_alu.zero;
----		debugS.regSelect		<= debug_alu.regSelect;
----		debugS.opA_value		<= debug_alu.opA_value;
----		debugS.opB_value		<= debug_alu.opB_value;
----		debugS.result_v			<= debug_alu.result_v;
--	debugS <= debug_alu;
--	end generate debug_assignments;

	pc : entity work.program_counter port map (
		clk		=> clk,
		reset	=> reset,
		jump	=> jump,
		jmp_addr=> jmp_addr,
		address	=> address
	);
	
	alu_inst : entity work.ALU generic map (
		debug	=> debug
--		scratch_pad_memory_size => scratch_pad_memory_size
	) PORT MAP (
		clk					=> clk,
		reset				=> reset,
		opcode				=> opcode,
--		opA					=> opA,
		opB					=> opB,
		carry				=> carry,
		zero				=> zero,
		reg_value			=> reg_value_a,
		reg_we				=> reg_we_a,
		reg_reg0	 		=> reg_reg0,
		reg_reg1	 		=> reg_reg1
--		debugS_alu			=> debugS
	);
	
	decoder_inst : entity work.decoder PORT MAP (
		clk				=> clk,
		reset			=> reset,
		sleep			=> sleep,
		interrupt		=> interrupt,
		interrupt_ack	=> interrupt_ack,
		instruction		=> instruction,
		opcode			=> opcode,
		opA				=> opA,
		opB				=> opB,
		carry			=> carry,
		zero			=> zero,
		jmp_addr		=> jmp_addr,
		jump			=> jump,
		io_op_in		=> io_op_in,
		io_op_out		=> io_op_out,
		io_op_out_pp	=> io_op_out_pp,
		io_kk_en		=> io_kk_en,
		io_kk_port		=> io_kk_port,
		io_kk_data		=> io_kk_data,
		reg_address		=> reg_address,
		reg_select		=> reg_select
	);
	
	reg_value <= reg_value_io when (io_op_in or io_op_out) = '1' else reg_value_a;
	reg_we <= reg_we_io when (io_op_in or io_op_out) = '1' else reg_we_a;

	register_file : entity work.reg_file port map (
		clk			=> clk,
		reset		=> reset,
		reg_address	=> reg_address,
		reg_select	=> reg_select,
		value		=> reg_value,
		write_en	=> reg_we,
		reg0		=> reg_reg0,
		reg1		=> reg_reg1
	);

	io_inst	: entity work.io_module PORT MAP (
		clk				=> clk,
		reset			=> reset,
		reg_value		=> reg_value_io,
		reg_we			=> reg_we_io,
		reg_reg0		=> reg_reg0,
		reg_reg1		=> reg_reg1,
		out_data		=> opB,
		io_op_in		=> io_op_in,
		io_op_out		=> io_op_out,
		io_op_out_pp	=> io_op_out_pp,
		io_kk_en		=> io_kk_en,
		io_kk_port		=> io_kk_port,
		io_kk_data		=> io_kk_data,
		-- actual i/o module ports
		in_port			=> in_port,
		port_id			=> port_id,
		out_port		=> out_port,
		read_strobe		=> read_strobe,
		write_strobe	=> write_strobe,
		k_write_strobe	=> k_write_strobe
	);

end Behavioral;

