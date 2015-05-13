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
use work.debugSignals.all; 
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
	signal debugS : debug_signals;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   
   type	io_data is array (0 to 4) of unsigned(7 downto 0);
   signal data : io_data := (x"00", x"AB", x"CD", x"12", x"00");
   signal pre_s : debug_signals;
   signal post_s : debug_signals;
   signal prog_mem_en : std_logic;
      
   constant real_prog : boolean := true;
 
BEGIN 
	-- Instantiate the Unit Under Test (UUT)
	uut: entity work.pauloBlaze generic map (
		debug => true
	) PORT MAP (
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
		interrupt_ack => interrupt_ack
--		debugS => debugS
	);
	
	instruction <= unsigned(instruction_slv); 

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
 
	clk5ns_process :process
	begin
		if (clk_5ns_enable = '0') then
			wait for 5 ns;
			clk_5ns_enable <= '1';
		end if;
		clk_5ns_delayed <= '0';
		wait for clk_period/2;
		clk_5ns_delayed <= '1';
		wait for clk_period/2;
	end process;
 
	real_program : if real_prog generate

		prog_mem_en <= not reset;

		prog_mem : entity work.my1stP6 generic map (
			C_FAMILY => "V6",
			C_RAM_SIZE_KWORDS => 1,
			C_JTAG_LOADER_ENABLE => 0)
		Port map (
			address => std_logic_vector(address),
			instruction => instruction_slv,
			enable => prog_mem_en,
			rdl => open,
			clk => clk);
	
--		input_delay : process begin
--			wait for clk_period/2 *3;
--			in_port <= data(to_integer(unsigned(port_id)));
--		end process input_delay;
	
	   -- Stimulus process
	   stim_proc: process
	   begin		
			reset <= '1';
			wait for clk_period*10;
			reset <= '0';
			
			wait for clk_period*10;
	
			-- insert stimulus here
			
			wait;
		end process;
	
		data_in_proc : process (port_id) begin
			case (port_id) is
				when x"05" => 
					in_port <= x"F3";
				when others =>
					in_port <= port_id;
			end case;
		end process data_in_proc;
	
	end generate real_program;

	auto_test : if not real_prog generate
		auto_alu : process
			procedure test_2clk(inst : in unsigned(17 downto 0); pre : in debug_signals; post : in debug_signals) is
			begin
				wait for 0 ns;
--				debugS <= pre;
				wait for 0 ns;
				instruction <= inst;
				wait for clk_period * 2;
				wait for 0 ns;
				wait for 0 ns;
				wait for 0 ns;
				assert debugS = post report (to_hstring(inst) & " failed at " & time'image(now)) severity error;
			end test_2clk;
		
			variable pre : debug_signals;
			variable post : debug_signals;
		begin
			reset <= '1';
			wait for 100 ns;
			reset <= '0';
			
			copy_debug(debugS, pre);
			copy_debug(debugS, post);
--			pre := debugS;
--			post := debugS;
			post.regFile(0) :=  x"45";
			wait for 0 ns;
			test_2clk(OP_LOAD_SX_KK & x"0" & x"45", pre, post);
			wait for 0 ns;
			pre_s <= pre;
			post_s <= post;				
		
			pre := debugS;
			post := debugS;
			post.regFile(1) := x"45";
			test_2clk(OP_LOAD_SX_SY & x"0" & x"10", pre, post);
			
--			assert debugS.regFile(0) = x"45" report "OP_LOAD_SX_KK failed" severity error;
--			assert debugS.regFile(1) = x"AA" report "OP_LOAD_SX_KK failed" severity error;
--			instruction <= OP_AND & x"0" & x"AA";
			wait;
		end process auto_alu;

	end generate auto_test;

END;
