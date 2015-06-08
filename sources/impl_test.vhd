--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:26:46 05/06/2015
-- Design Name:   
-- Module Name:   /home/pgenssler/pauloBlaze/sources/sim/tb_paulB.vhd
-- Project Name:  ise_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pauloBlaze
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- unsigned for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.math_real.all;
use work.debugSignals.all; 
use work.op_codes.all;

 
ENTITY mhzTest IS
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
END mhzTest;
 
ARCHITECTURE behavior OF mhzTest IS 
 
	--Inputs
	signal reset_r : std_logic := '0';
	signal sleep_r : std_logic := '0';
	signal instruction_r : unsigned(17 downto 0) := (others => '0');
	signal in_port_r : unsigned(7 downto 0) := (others => '0');
	signal interrupt_r : std_logic := '0';

	--Outputs
	signal address_r : unsigned(11 downto 0);
	signal bram_enable_r : std_logic;
	signal out_port_r : unsigned(7 downto 0);
	signal port_id_r : unsigned(7 downto 0);
	signal write_strobe_r : std_logic;
	signal k_write_strobe_r : std_logic;
	signal read_strobe_r : std_logic;
	signal interrupt_ack_r : std_logic;

	--Inputs
	signal reset_r_r : std_logic := '0';
	signal sleep_r_r : std_logic := '0';
	signal instruction_r_r : unsigned(17 downto 0) := (others => '0');
	signal in_port_r_r : unsigned(7 downto 0) := (others => '0');
	signal interrupt_r_r : std_logic := '0';

	--Outputs
	signal address_r_r : unsigned(11 downto 0);
	signal bram_enable_r_r : std_logic;
	signal out_port_r_r : unsigned(7 downto 0);
	signal port_id_r_r : unsigned(7 downto 0);
	signal write_strobe_r_r : std_logic;
	signal k_write_strobe_r_r : std_logic;
	signal read_strobe_r_r : std_logic;
	signal interrupt_ack_r_r : std_logic;
 
BEGIN 

	process (clk) begin
		if rising_edge(clk) then
			reset_r <= reset;
			sleep_r <= sleep;
			instruction_r <= instruction;
			in_port_r <= in_port;
			interrupt_r <= interrupt;

			reset_r_r <= reset_r;
			sleep_r_r <= sleep_r;
			instruction_r_r <= instruction_r;
			in_port_r_r <= in_port_r;
			interrupt_r_r <= interrupt_r;
					
			address <= address_r;
			bram_enable <= bram_enable_r;
			out_port <= out_port_r;
			port_id <= port_id_r;
			write_strobe <= write_strobe_r;
			k_write_strobe <= k_write_strobe_r;
			read_strobe <= read_strobe_r;
			interrupt_ack <= interrupt_ack_r;

			address_r <= address_r_r;
			bram_enable_r <= bram_enable_r_r;
			out_port_r <= out_port_r_r;
			port_id_r <= port_id_r_r;
			write_strobe_r <= write_strobe_r_r;
			k_write_strobe_r <= k_write_strobe_r_r;
			read_strobe_r <= read_strobe_r_r;
			interrupt_ack_r <= interrupt_ack_r_r;	
		end if;
	end process;
		

uut: entity work.pauloBlaze 
	generic map (
		debug => true,
		interrupt_vector => x"300", 
		hwbuild => x"41",
		scratch_pad_memory_size => 64 )
	PORT MAP (
--		clk => clk_5ns_delayed,
		clk => clk,
		reset => reset_r_r,
		sleep => sleep_r_r,
		instruction => instruction_r_r,
		in_port => in_port_r_r,
		interrupt => interrupt_r_r,
		
		address => address_r_r,
		bram_enable => bram_enable_r_r,
		out_port => out_port_r_r,
		port_id => port_id_r_r,
		write_strobe => write_strobe_r_r,
		k_write_strobe => k_write_strobe_r_r,
		read_strobe => read_strobe_r_r,
		interrupt_ack => interrupt_ack_r_r );

END;
