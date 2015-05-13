--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:49:08 05/07/2015
-- Design Name:   
-- Module Name:   /home/pgenssler/pauloBlaze/sources/sim/tb_io.vhd
-- Project Name:  ise_project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: io_module
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
 
ENTITY tb_io IS
END tb_io;
 
ARCHITECTURE behavior OF tb_io IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT io_module
    PORT(
         clk : IN  std_logic;
         opCode : IN  std_logic_vector(5 downto 0);
         port_id : OUT  std_logic_vector(7 downto 0);
         in_port : IN  std_logic_vector(7 downto 0);
         read_strobe : OUT  std_logic;
         write_strobe : OUT  std_logic;
         out_port : OUT  std_logic_vector(7 downto 0);
         data_i2reg : OUT  std_logic_vector(7 downto 0);
         data_reg2o : IN  std_logic_vector(7 downto 0);
         io_addr : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal opCode : std_logic_vector(5 downto 0) := (others => '0');
   signal in_port : std_logic_vector(7 downto 0) := (others => '0');
   signal data_reg2o : std_logic_vector(7 downto 0) := (others => '0');
   signal io_addr : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal port_id : std_logic_vector(7 downto 0);
   signal read_strobe : std_logic;
   signal write_strobe : std_logic;
   signal out_port : std_logic_vector(7 downto 0);
   signal data_i2reg : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: io_module PORT MAP (
          clk => clk,
          opCode => opCode,
          port_id => port_id,
          in_port => in_port,
          read_strobe => read_strobe,
          write_strobe => write_strobe,
          out_port => out_port,
          data_i2reg => data_i2reg,
          data_reg2o => data_reg2o,
          io_addr => io_addr
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
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
