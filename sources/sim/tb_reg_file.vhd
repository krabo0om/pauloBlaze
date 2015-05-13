--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:28:45 05/11/2015
-- Design Name:   
-- Module Name:   /home/pgenssler/pauloBlaze/sources/sim/tb_reg_file.vhd
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
-- unsigned for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_reg_file IS
END tb_reg_file;
 
ARCHITECTURE behavior OF tb_reg_file IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT reg_file
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         address : IN  unsigned(7 downto 0);
         reg_select : IN  std_logic;
         value : IN  unsigned(7 downto 0);
         write_en : IN  std_logic;
         reg0 : OUT  unsigned(7 downto 0);
         reg1 : OUT  unsigned(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal address : unsigned(7 downto 0) := (others => '0');
   signal reg_select : std_logic := '0';
   signal value : unsigned(7 downto 0) := (others => '0');
   signal write_en : std_logic := '0';

 	--Outputs
   signal reg0 : unsigned(7 downto 0);
   signal reg1 : unsigned(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: reg_file PORT MAP (
          clk => clk,
          reset => reset,
          address => address,
          reg_select => reg_select,
          value => value,
          write_en => write_en,
          reg0 => reg0,
          reg1 => reg1
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

	-- Stimulus process
	stim_proc: process
	begin		
		reset <= '1';
		wait for 100 ns;	
		reset <= '0';

		address <= x"0D";
		reg_select <= '0';
		value <= x"45";
		write_en <= '0';

		wait for clk_period;

		write_en <= '1';

		wait for clk_period;

		address <= x"1F";
		value <= x"12";
		write_en <= '1';

		wait for clk_period;

		write_en <= '0';

		wait for clk_period;
		address <= x"D4";
		wait for clk_period;
		address <= x"1F";
		wait for clk_period;
		reg_select <= '0';
		address <= x"FD";
		wait for clk_period;
		

		wait for clk_period;	

		wait;
	end process;

END;
