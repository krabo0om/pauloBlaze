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
		clk2			: in  STD_LOGIC;
		reset			: in  std_logic;
		reg_value		: out unsigned (7 downto 0);
		reg_we			: out std_logic;
		reg_reg0		: in  unsigned (7 downto 0);
		reg_reg1		: in  unsigned (7 downto 0);
		out_data		: in  unsigned (7 downto 0);
		io_op_in		: in  std_logic;
		io_op_out		: in  std_logic;
		io_op_out_pp	: in  std_logic;
		io_kk_en		: in  std_logic;
		io_kk_port		: in  unsigned (3 downto 0);
		io_kk_data		: in  unsigned (7 downto 0);
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
	
	signal strobe_o : std_logic;

begin
	
	reg_value		<= in_port;
	read_strobe		<= io_op_in and strobe_o and clk2;
	write_strobe	<= io_op_out and strobe_o and clk2;
	k_write_strobe	<= io_kk_en and strobe_o and clk2;
	reg_we			<= io_op_in;			-- FIXME!! ???
	
	out_proc : process (reset, out_data, reg_reg0, reg_reg1, io_kk_en, io_kk_port, io_kk_data, io_op_out_pp) begin		
		if (reset = '1') then
			port_id <= (others => '0');
			out_port <= (others => '0');
		else
			if (io_kk_en = '1') then
				port_id <= x"0" & io_kk_port;
				out_port <= io_kk_data;
			else
				out_port <= reg_reg0;
				if (io_op_out_pp = '1') then			-- intermediate value pp
					port_id <= out_data;
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
			else
				if ((io_op_in or io_op_out) = '1') then
					strobe_o <= '1';
				else
					strobe_o <= '0';
				end if;
			end if;
		end if;
	end process;

end Behavioral;

