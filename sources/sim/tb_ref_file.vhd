--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:42:08 05/11/2015
-- Design Name:   
-- Module Name:   /home/pgenssler/pauloBlaze/sources/sim/tb_ref_file.vhd
-- Project Name:  ise_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: reg_file
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_ref_file IS
END tb_ref_file;
 
ARCHITECTURE behavior OF tb_ref_file IS 
   --Inputs
   signal reset : std_logic := '0';
   signal address : unsigned(7 downto 0) := (others => '0');
   signal reg_select : std_logic := '0';
   signal value : unsigned(7 downto 0) := (others => '0');
   signal write_en : std_logic := '0';

 	--Outputs
   signal reg0 : unsigned(7 downto 0);
   signal reg1 : unsigned(7 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
--   constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.reg_file PORT MAP (
          reset => reset,
          address => address,
          reg_select => reg_select,
          value => value,
          write_en => write_en,
          reg0 => reg0,
          reg1 => reg1
        );

   -- Clock process definitions
--   clock_process :process
--   begin
--		<clock> <= '0';
--		wait for <clock>_period/2;
--		<clock> <= '1';
--		wait for <clock>_period/2;
--   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
		wait for 100 ns;	
		reset <= '0';

		address <= x"0D";
		reg_select <= '0';
		value <= x"45";
		write_en <= '0';
		
		wait for 10 ns;
		
		write_en <= '1';

		wait for 10 ns;
		
		reg_select <= '1';
		
		value <= x"12";
		write_en <= '1';
		
		wait for 10 ns;
		
		write_en <= '0';
		
		wait for 10 ns;
		address <= x"D4";
		wait for 10 ns;
		reg_select <= '0';
		
		wait for 10 ns;	
      wait;
   end process;

END;
