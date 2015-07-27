----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:47:33 05/11/2015 
-- Design Name: 
-- Module Name:    regFile - Behavioral 
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

library work;
use	work.op_codes.all;

--library poc;
--use poc.utils.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_file is
	generic (
		debug	: boolean := false;
		scratch_pad_memory_size	: integer := 64
	);
	port (
		clk			: in std_logic;
		reset		: in std_logic;
		value		: in unsigned (7 downto 0);
		write_en	: in std_logic;
		reg0		: out unsigned (7 downto 0);
		reg1		: out unsigned (7 downto 0);
		reg_address	: in unsigned (7 downto 0);
		reg_select	: in std_logic;
		spm_addr_ss	: in unsigned (7 downto 0);
		spm_ss		: in std_logic;				-- 0: spm_addr = reg1, 1: spm_addr = spm_addr_ss
		spm_we		: in std_logic;
		spm_rd		: in std_logic
	);
end reg_file;

architecture Behavioral of reg_file is

	-- Logarithms: log*ceil*
	-- From PoC-Library https://github.com/VLSI-EDA/PoC
	-- ==========================================================================
	function log2ceil(arg : positive) return natural is
	variable tmp : positive   := 1;
	variable log : natural    := 0;
	begin
	if arg = 1 then return 0; end if;
	while arg > tmp loop
	  tmp := tmp * 2;
	  log := log + 1;
	end loop;
	return log;
	end function;
	
	-- generate bit masks
	-- From PoC-Library https://github.com/VLSI-EDA/PoC
	-- ==========================================================================
	FUNCTION genmask_low(Bits : NATURAL; MaskLength : POSITIVE) RETURN STD_LOGIC_VECTOR IS
	BEGIN
	IF (Bits = 0) THEN
	  RETURN (MaskLength - 1 DOWNTO 0 => '0');
	ELSE
	  RETURN (MaskLength - 1 DOWNTO Bits => '0') & (Bits - 1 DOWNTO 0 => '1');
	END IF;
	END FUNCTION;	

	type reg_file_t is array (31 downto 0) of unsigned(7 downto 0);
	signal reg 			: reg_file_t := (others=>(others=>'0'));

	type scratchpad_t is array(integer range <>) of unsigned(7 downto 0);
	signal scratchpad	: scratchpad_t((scratch_pad_memory_size-1) downto 0) := (others=>(others=>'0')); 
 
	signal spm_addr_sel	: unsigned ( 7 downto 0);
	signal spm_addr		: unsigned ( 7 downto 0);
	constant spm_mask_w	: integer := log2ceil(scratch_pad_memory_size);	-- address failsafes into a truncated one
	signal spm_mask		: unsigned (7 downto 0);
	
	signal reg0_buf		: unsigned ( 7 downto 0);
	signal reg0_o		: unsigned ( 7 downto 0);

	signal reg1_buf		: unsigned ( 7 downto 0);
	signal reg1_o		: unsigned ( 7 downto 0);
begin

	reg0 <= reg0_o;
	reg1 <= reg1_o;
	
	spm_mask		<= unsigned(genmask_low(spm_mask_w, 8));
	spm_addr_sel	<= spm_addr_ss when spm_ss = '1' else reg1_buf;
	spm_addr		<= spm_addr_sel and spm_mask;

	write_reg : process (clk) begin
		if rising_edge(clk) then
			if (write_en = '1') then
				reg(to_integer(reg_select & reg_address(7 downto 4))) <= value;
			elsif (spm_rd = '1') then
				reg(to_integer(reg_select & reg_address(7 downto 4))) <=  scratchpad(to_integer(spm_addr));
			end if;
		end if;
	end process write_reg;
	
	write_spm : process (clk) begin
		if rising_edge(clk) then
			if (spm_we = '1') then
				scratchpad(to_integer(spm_addr)) <=  reg0_buf;
			end if;
		end if;
	end process write_spm;

	buf_reg0_p : process (clk) begin
		if rising_edge(clk) then
--			if (reset = '1') then
--				reg0_buf <= (others=>'0');
--				reg1_buf <= (others=>'0');
--			else
				reg0_buf <= reg0_o;
				reg1_buf <= reg1_o;
--			end if;
		end if;
	end process buf_reg0_p;

	read_reg : process(reset, reg, reg_address, reg_select, spm_rd, scratchpad, spm_addr) begin
--		if (reset = '1') then
--			reg0_o <= (others => '0');
--			reg1_o <= (others => '0');
--		else
			if (spm_rd = '1') then
				reg0_o <= scratchpad(to_integer(spm_addr));
			else
				reg0_o <= reg(to_integer(reg_select & reg_address(7 downto 4)));
			end if;
			reg1_o <= reg(to_integer(reg_select & reg_address(3 downto 0)));	
--		end if;
	end process read_reg;

	

end Behavioral;

