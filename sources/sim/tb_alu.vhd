--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:28:44 05/05/2015
-- Design Name:   
-- Module Name:   /home/pgenssler/pauloBlaze/sources/sim/tb_alu.vhd
-- Project Name:  ise_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ALU
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
 
use work.op_codes.all;
 
ENTITY tb_alu IS
END tb_alu;
 
ARCHITECTURE behavior OF tb_alu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         opcode : IN  std_logic_vector(5 downto 0);
         opA : IN  std_logic_vector(7 downto 0);
         opB : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal opcode : std_logic_vector(5 downto 0) := (others => '0');
   signal opA : std_logic_vector(7 downto 0) := (others => '0');
   signal opB : std_logic_vector(7 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          clk => clk,
          reset => reset,
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
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
		

		opcode <= OP_OR_SX_KK;
      wait for clk_period;

		opcode <= OP_LOAD_SX_KK;
		opA <= x"02";
		opB <= x"06";
		wait for clk_period;
		
		opcode <= OP_LOAD_SX_SY;
		opA <= x"03";
		opB <= x"02";
		wait for clk_period;
		
		opcode <= X"FF";
      wait;
   end process;

END;
