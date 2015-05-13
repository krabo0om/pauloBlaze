--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:14:00 05/06/2015
-- Design Name:   
-- Module Name:   /home/pgenssler/pauloBlaze/sources/sim/tb_decoder.vhd
-- Project Name:  ise_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: decoder
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
 
ENTITY tb_decoder IS
END tb_decoder;
 
ARCHITECTURE behavior OF tb_decoder IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT decoder
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         sleep : IN  std_logic;
         interrupt : IN  std_logic;
         interrupt_ack : OUT  std_logic;
         instruction : IN  std_logic_vector(17 downto 0);
         opcode : OUT  std_logic_vector(5 downto 0);
         opA : OUT  std_logic_vector(3 downto 0);
         opB : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal sleep : std_logic := '0';
   signal interrupt : std_logic := '0';
   signal instruction : std_logic_vector(19 downto 0) := (others => '0');
   signal instruction_in : std_logic_vector(17 downto 0) := (others => '0');

 	--Outputs
   signal interrupt_ack : std_logic;
   signal opcode : std_logic_vector(5 downto 0);
   signal opA : std_logic_vector(3 downto 0);
   signal opB : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: decoder PORT MAP (
          clk => clk,
          reset => reset,
          sleep => sleep,
          interrupt => interrupt,
          interrupt_ack => interrupt_ack,
          instruction => instruction_in,
          opcode => opcode,
          opA => opA,
          opB => opB
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	-- copy and paste gives 20 bits
	instruction_in <= instruction(17 downto 0);

	-- Stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		reset <= '1';
		wait for 100 ns;	
		reset <= '0';

		wait for clk_period*10;
		
		instruction <= x"09000";
		wait for clk_period;
		instruction <= x"0D001";
		wait for clk_period;
		instruction <= x"32005";
		wait for clk_period;
		instruction <= x"19F01";
		wait for clk_period;
		instruction <= x"22006";
		wait for clk_period;
		instruction <= x"11F01";
		wait for clk_period;
		instruction <= x"2DF02";
		wait for clk_period;
		instruction <= x"09201";
		wait for clk_period;
		instruction <= x"09302";
		wait for clk_period;
		instruction <= x"02230";
		wait for clk_period;
		instruction <= x"2D208";
		wait for clk_period;
		instruction <= x"22000";
		
		wait;
	end process;

END;
