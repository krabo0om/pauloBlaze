----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:05:07 05/06/2015 
-- Design Name: 
-- Module Name:    program_counter - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity program_counter is
	Port (
		clk		: in  STD_LOGIC;
		reset	: in  STD_LOGIC;
		jump	: in  STD_LOGIC;
		jmp_addr: in  unsigned (11 downto 0);
		address	: out  unsigned (11 downto 0));
end program_counter;

architecture Behavioral of program_counter is

	signal counter : unsigned (12 downto 0);
	signal jmp_done : std_logic;

begin

	clken : process (clk) begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				counter <= (others => '0');
				address <= (others => '0');
				jmp_done <= '0';
			else
				if (jump = '1' and jmp_done <= '0') then
					counter <= (jmp_addr & '1');
					address <= jmp_addr;
					jmp_done <= '1';
				else
					jmp_done <= '0';
					counter <= counter + 1;
					address <= counter(12 downto 1);
				end if;
			end if;
		end if;	
	end process clken;

end Behavioral;

