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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;

use work.op_codes.all;

 
ENTITY tb_pauloB IS
END tb_pauloB;
 
ARCHITECTURE behavior OF tb_pauloB IS 
 
	--Inputs
	signal clk : std_logic := '0';
	signal clk_5ns_delayed : std_logic := '0';
	signal clk_5ns_enable : std_logic := '0';
	signal reset : std_logic := '0';
	signal sleep : std_logic := '0';
	signal instruction : unsigned(17 downto 0) := (others => '0');
	signal instruction_slv : std_logic_vector(17 downto 0) := (others => '0');
	signal in_port : unsigned(7 downto 0) := (others => '0');
	signal in_port_del : unsigned(7 downto 0) := (others => '0');
	signal interrupt : std_logic := '0';

	--Outputs
	signal address : unsigned(11 downto 0);
	signal bram_enable : std_logic;
	signal out_port : unsigned(7 downto 0);
	signal port_id : unsigned(7 downto 0);
	signal write_strobe : std_logic;
	signal k_write_strobe : std_logic;
	signal read_strobe : std_logic;
	signal interrupt_ack : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   
   type	io_data is array (0 to 4) of unsigned(7 downto 0);
   signal data : io_data := (x"00", x"AB", x"CD", x"12", x"00");
   signal prog_mem_en : std_logic;
   signal done : std_logic;
   signal sleep_en : std_logic := '0';
   signal inter_en : std_logic := '0';
   signal reset_en : std_logic := '0';
 
BEGIN 
	-- Instantiate the Unit Under Test (UUT)
	uut: entity work.pauloBlaze 
	generic map (
		debug => true,
		interrupt_vector => x"300", 
		hwbuild => x"41",
		scratch_pad_memory_size => 64 )
	PORT MAP (
--		clk => clk_5ns_delayed,
		clk => clk,
		reset => reset,
		sleep => sleep,
		address => address,
		instruction => instruction,
		bram_enable => bram_enable,
		in_port => in_port,
		out_port => out_port,
		port_id => port_id,
		write_strobe => write_strobe,
		k_write_strobe => k_write_strobe,
		read_strobe => read_strobe,
		interrupt => interrupt,
		interrupt_ack => interrupt_ack );
	-- end port map
	

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
 
	instruction <= unsigned(instruction_slv); 
	
	sleeping : process begin
		if (sleep_en = '1') then
			wait for 475 ns;
			sleep <= '1';
			wait for 137 ns;
			sleep <= '0';
		end if;
		wait;
	end process sleeping;
	
	inter_static : process 
	begin
		if (inter_en = '1') then
			wait for 499 ns;
			interrupt <= '1';
			wait until interrupt_ack = '1';
			interrupt <= '0';
		end if;
		wait;
	end process inter_static;

	prog_mem : entity work.code_loader
	Port map (
		address => std_logic_vector(address),
		instruction => instruction_slv,
		enable => bram_enable,
		done => done,
		rdl => open,
		clk => clk);
	
   reset_proc: process
   begin		
		reset <= '1';
		wait for clk_period*10;
		wait until done = '1';
		wait until clk = '1';
		reset <= '0';
		if (reset_en = '1') then
			wait for 465 ns;
			reset <= '1';
			wait for 86 ns;
			reset <= '0';
		end if;
		wait;
	end process;

	process begin
		wait for 20 ns;
		in_port <= in_port_del;
	end process;
	
	data_in_proc : process (port_id) begin
		case (port_id) is
			when x"05" => 
				in_port_del <= x"F3";
			when others =>
				in_port_del <= port_id;
		end case;
	end process data_in_proc;

END;
