----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:25:37 05/07/2015 
-- Design Name: 
-- Module Name:    io_module - Behavioral 
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

entity io_module is
    Port (
		clk				: in  STD_LOGIC;
		reset			: in  std_logic;
		reg_value		: out unsigned (7 downto 0);
		reg_we			: out std_logic;
		reg_reg0		: in  unsigned (7 downto 0);
		reg_reg1		: in  unsigned (7 downto 0);
		instruction		: in  unsigned (17 downto 0);
		-- actual i/o module ports
		in_port			: in  unsigned (7 downto 0);
		port_id			: out unsigned (7 downto 0);
		out_port		: out unsigned (7 downto 0);
		read_strobe		: out STD_LOGIC;
		write_strobe	: out STD_LOGIC;
		k_write_strobe	: out STD_LOGIC
	);
end io_module;

architecture Behavioral of io_module is
	
	signal in_out : std_logic;	-- 0 = in, 1 = out
	signal strobe_o : std_logic;
	signal clk_cycle2 : std_logic;

begin
	
	in_out			<= instruction(17);
	reg_value		<= in_port;
	read_strobe		<= (not in_out) and strobe_o and clk_cycle2;
	write_strobe	<= in_out and strobe_o and clk_cycle2;
	reg_we			<= '0';			-- FIXME!!
	
	out_proc : process (reset, instruction, reg_reg0, reg_reg1) begin		
		if (reset = '1') then
			port_id <= (others => '0');
			out_port <= (others => '0');
		else
			if (instruction(17 downto 12) = OP_OUTPUTK_KK_P) then
				port_id <= x"0" & instruction(3 downto 0);
				out_port <= instruction (11 downto 4);
			else
				out_port <= reg_reg0;
				if (instruction(12) = '1') then			-- intermediate value pp
					port_id <= instruction(7 downto 0);
				else
					port_id <= reg_reg1;
				end if;
			end if;
		end if;
	end process out_proc;
		
	process (clk) begin
		if (rising_edge(clk)) then		
			if (reset = '1') then
				strobe_o <= '0';
				clk_cycle2 <= '0';
			else
				case instruction(17 downto 12) is
					when OP_INPUT_SX_SY | OP_INPUT_SX_PP | OP_OUTPUT_SX_SY 
							| OP_OUTPUT_SX_PP | OP_OUTPUTK_KK_P =>
						strobe_o <= '1';
					when others =>
						strobe_o <= '0';
				end case;
				clk_cycle2 <= not clk_cycle2;
			end if;
		end if;
	end process;

end Behavioral;

