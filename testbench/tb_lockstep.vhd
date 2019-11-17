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
-- Copyright 2007-2019 Paul Genssler - Germany
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

 
ENTITY tb_lockstep IS
END tb_lockstep;
 
ARCHITECTURE behavior OF tb_lockstep IS 
 
	--Inputs
	signal clk : std_logic := '0';
	signal clk_5ns_delayed : std_logic := '0';
	signal clk_5ns_enable : std_logic := '0';
	signal reset : std_logic := '0';
	signal sleep : std_logic := '0';
	signal instruction : std_logic_vector(17 downto 0) := (others => '0');
	signal in_port : std_logic_vector(7 downto 0) := (others => '0');
	signal in_port_del : std_logic_vector(7 downto 0) := (others => '0');
	signal interrupt : std_logic := '0';

	--Outputs
	signal address : std_logic_vector(11 downto 0);
	signal bram_enable : std_logic;
	signal out_port : std_logic_vector(7 downto 0);
	signal port_id : std_logic_vector(7 downto 0);
	signal write_strobe : std_logic;
	signal k_write_strobe : std_logic;
	signal read_strobe : std_logic;
	signal interrupt_ack : std_logic;

    -- PicoBlaze Outputs
    signal pico_address : std_logic_vector(11 downto 0);
    signal pico_instruction : std_logic_vector(17 downto 0) := (others => '0');
    signal pico_bram_enable : std_logic;
    signal pico_out_port : std_logic_vector(7 downto 0);
    signal pico_port_id : std_logic_vector(7 downto 0);
    signal pico_write_strobe : std_logic;
    signal pico_k_write_strobe : std_logic;
    signal pico_read_strobe : std_logic;
    signal pico_interrupt_ack : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   
   type	io_data is array (0 to 4) of unsigned(7 downto 0);
   signal data : io_data := (x"00", x"AB", x"CD", x"12", x"00");
   signal prog_mem_en : std_logic;
   signal done : std_logic;
   signal pico_done : std_logic;
   signal sleep_en : std_logic := '1';
   signal inter_en : std_logic := '1';
   signal reset_en : std_logic := '1';
 
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
	
  picoblaze: entity work.kcpsm6
      generic map ( hwbuild => X"41", 
                    interrupt_vector => X"300",
                    scratch_pad_memory_size => 64)
      port map(      address => pico_address,
                 instruction => pico_instruction,
                 bram_enable => pico_bram_enable,
                     port_id => pico_port_id,
                write_strobe => pico_write_strobe,
              k_write_strobe => pico_k_write_strobe,
                    out_port => pico_out_port,
                 read_strobe => pico_read_strobe,
                     in_port => in_port,
                   interrupt => interrupt,
               interrupt_ack => pico_interrupt_ack,
                       sleep => sleep,
                       reset => reset,
                         clk => clk);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
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
            wait for 490 ns;
            interrupt <= '1';
            wait for 3 * clk_period;
            interrupt <= '0';
			wait for 875 ns;
			interrupt <= '1';
			wait until interrupt_ack = '1';
			interrupt <= '0';
		end if;
		wait;
	end process inter_static;

	prog_mem : entity work.code_loader
	Port map (
		address => address,
		instruction => instruction,
		enable => bram_enable,
		done => done,
		rdl => open,
		clk => clk);

	prog_mem_pico : entity work.code_loader
	Port map (
		address => pico_address,
		instruction => pico_instruction,
		enable => pico_bram_enable,
		done => pico_done,
		rdl => open,
		clk => clk);
	
	
   reset_proc: process
   begin		
		reset <= '1';
		wait until (done = '1' and pico_done = '1');
		wait until clk = '0';
		reset <= '0';
		if (reset_en = '1') then
			wait for 465 ns;
			reset <= '1';
			wait for 86 ns;
			reset <= '0';
		end if;
		wait for 1337 ns;
		wait until rising_edge(clk);
		if (reset_en = '1') then
            wait for 85 ns;
            reset <= '1';
            wait for 35 ns;
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
	
    compare_process: process begin
            wait until reset = '0';
            loop
                wait until rising_edge(clk);
                wait until rising_edge(clk);
                assert pico_address = address report "address is different" severity error;
                assert pico_bram_enable = bram_enable report "bram_enable is different" severity error;
                assert pico_write_strobe = write_strobe report "write_strobe is different" severity error;
                assert pico_k_write_strobe = k_write_strobe report "k_write_strobe is different" severity error;
                                
                if (pico_write_strobe = '1' or write_strobe = '1' or
                      pico_k_write_strobe = '1' or k_write_strobe = '1' ) then
                    assert pico_out_port = out_port report "out_port is different" severity error;
                    if (pico_k_write_strobe = '1' or k_write_strobe = '1' ) then
                        assert pico_port_id(3 downto 0) = port_id(3 downto 0) report "port_id is different" severity error;
                    else
                        assert pico_port_id = port_id report "port_id is different" severity error;
                    end if;
                end if;
                
                assert pico_read_strobe = read_strobe report "read_strobe is different" severity error;
                assert pico_interrupt_ack = interrupt_ack report "interrupt_ack is different" severity error;
            end loop;
        end process;
END;
