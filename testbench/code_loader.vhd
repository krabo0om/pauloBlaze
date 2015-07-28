-- EMACS settings: -*- tab-width: 4; indent-tabs-mode: t -*-
-- vim: tabstop=4:shiftwidth=4:noexpandtab
-- kate: tab-width 4; replace-tabs off; indent-width 4;
--
-- =============================================================================
-- Authors: Paul Genssler
--
-- Description:
-- ------------------------------------
-- TODO
--
-- License:
-- =============================================================================
-- Copyright 2007-2015 Paul Genssler - Dresden, Germany
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS is" BASIS,
-- WITHOUT WARRANTIES or CONDITIONS of ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity code_loader is
	Port (
		address		: in	std_logic_vector(11 downto 0);
		instruction	: out	std_logic_vector(17 downto 0);
		enable		: in	std_logic;
		rdl			: out	std_logic;
		done		: out	std_logic;
		clk			: in	std_logic);
end code_loader;

architecture Behavioral of code_loader is

	type instr_t is array (0 to 1023) of std_logic_vector(17 downto 0);
	signal mem : instr_t;
	signal instruction_o : std_logic_vector(17 downto 0);
	signal clk_sim : std_logic;
	signal inst_sim : std_logic_vector(17 downto 0);
	signal addr_sim : std_logic_vector(11 downto 0);
	
begin

	instruction <= instruction_o;
	rdl <= '0';

	read_inst : process (clk)
	begin
		if (rising_edge(clk)) then
			if (enable = '1') then 
				instruction_o <= mem(to_integer(unsigned(address)));
			else
				instruction_o <= instruction_o;
			end if;
		end if;
	end process;
	

	load_mem : process
	begin
		done <= '0';		
		clk_sim <= '1';
		wait for 50 ps;
		clk_sim <= '0';
		wait for 50 ps;
		for i in 0 to 1023 loop
			addr_sim <= std_logic_vector(to_unsigned(i+1, 12));
			clk_sim <= '1';
			wait for 50 ps;
			clk_sim <= '0';
			wait for 51 ps;
			mem(i) <= inst_sim;
		end loop;
		done <= '1';
		wait;
	end process load_mem;

	prog_mem : entity work.my1stP6 generic map (
		C_FAMILY => "V6",
		C_RAM_SIZE_KWORDS => 1,
		C_JTAG_LOADER_ENABLE => 0)
	Port map (
		address => addr_sim,
		instruction => inst_sim,
		enable => '1',
		rdl => open,
		clk => clk_sim);

end Behavioral;

