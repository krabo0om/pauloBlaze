--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:33:40 05/06/2015
-- Design Name:   
-- Module Name:   /home/pgenssler/pauloBlaze/sources/sim/tb_programCounter.vhd
-- Project Name:  ise_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: program_counter
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_programCounter IS
END tb_programCounter;
 
ARCHITECTURE behavior OF tb_programCounter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT program_counter
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         address : OUT  std_logic_vector(11 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal address : std_logic_vector(11 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: program_counter PORT MAP (
          clk => clk,
          reset => reset,
          address => address
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
		-- hold reset state for 100 ns.
		reset <= '1';
		wait for 100 ns;	

		reset <= '0';

		wait for clk_period*10;

		-- insert stimulus here 

		wait;
	end process;

END;
