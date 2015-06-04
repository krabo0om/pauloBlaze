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
	generic (
		interrupt_vector : unsigned(11 downto 0) := X"3FF"
	);
	Port (
		clk			: in  STD_LOGIC;
		reset		: in  STD_LOGIC;
		sleep_int	: in  STD_LOGIC;
		bram_pause	: in  STD_LOGIC;
		call		: in  STD_LOGIC;
		ret			: in  std_logic;
		inter_j		: in  std_logic;
		jump		: in  STD_LOGIC;
		jmp_addr	: in  unsigned (11 downto 0);
		address		: out unsigned (11 downto 0));
end program_counter;

architecture Behavioral of program_counter is

	type stack_t is array (29 downto 0) of unsigned(11 downto 0);
	signal stack	: stack_t;
	signal pointer	: integer range 0 to 29;
	signal counter	: unsigned (12 downto 0);
	signal jmp_int	: std_logic;
	signal jmp_done	: std_logic;
	signal addr_o	: unsigned (11 downto 0);

begin

	jmp_int <= jump or call or inter_j;
	address	<= interrupt_vector when inter_j = '1' else addr_o ;

	clken : process (clk) 
		variable p : integer;
		variable addr_next : unsigned (11 downto 0);
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				counter <= x"000" & '1';
				addr_o <= (others => '0');
				jmp_done <= '0';
				stack <= (others => (others => '0'));
				pointer <= 0;
			else
				if (bram_pause = '1') then
					counter <= addr_o & '1';
					jmp_done <= jmp_done;
					addr_o <= counter(12 downto 1);
				elsif (ret = '1' and jmp_done <= '0') then
					p := pointer - 1;
					pointer <= p;
					addr_next := stack(p);
--					if (inter_j = '0') then
--						addr_next := addr_next + 1;
--					end if;
					counter <= addr_next & '1';
					addr_o <= addr_next;
					jmp_done <= '1';
				elsif (inter_j = '1') then
					if (call = '1' or jump = '1') then
						-- use target address in case of interrupted jump or call
						stack(pointer) <= jmp_addr;
					else
						stack(pointer) <= addr_o-1;
					end if;
					pointer <= pointer + 1;
					counter <= (interrupt_vector & '1') + ("" & '1');
					addr_o <= interrupt_vector;
					jmp_done <= '1';
				elsif (jmp_int = '1' and jmp_done <= '0') then
					if (call = '1') then
						stack(pointer) <= addr_o+1;
						pointer <= pointer + 1;
					end if;
					counter <= jmp_addr & '1';
					addr_o <= jmp_addr;
					jmp_done <= '1';			
				else
					jmp_done <= '0';
					counter <= counter + 1;
					addr_o <= counter(12 downto 1);
				end if;
			end if;
		end if;	
	end process clken;

end Behavioral;

