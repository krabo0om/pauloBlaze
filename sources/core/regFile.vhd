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
use	work.op_codes.all;

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
		reg_select	: in std_logic
	);
end reg_file;

architecture Behavioral of reg_file is

	type reg_file_t is array (31 downto 0) of unsigned(7 downto 0);
	signal reg : reg_file_t;

	type scratchpad_t is array(integer range <>) of unsigned(7 downto 0);
	signal scratchpad		: scratchpad_t((scratch_pad_memory_size-1) downto 0); 

begin

	write_p : process (clk) begin
		if rising_edge(clk) then
			if (reset = '1') then
				reg <= (others=>(others=>'0'));
				scratchpad <= (others=>(others=>'0'));
			else
				if (write_en = '1') then
					reg(to_integer(reg_select & reg_address(7 downto 4))) <= value;
				end if;
			end if;
		end if;
	end process write_p;

	read_p : process(reset, reg, reg_address, reg_select) begin
		if (reset = '1') then
			reg0 <= (others => '0');
			reg1 <= (others => '0');
		else			
			reg0 <= reg(to_integer(unsigned(reg_select & std_logic_vector(reg_address(7 downto 4)))));
			reg1 <= reg(to_integer(unsigned(reg_select & std_logic_vector(reg_address(3 downto 0)))));	
		end if;
	end process read_p;

end Behavioral;

