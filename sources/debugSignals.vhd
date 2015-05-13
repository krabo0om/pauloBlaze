--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package debugSignals is

type register_file is array (31 downto 0) of unsigned(7 downto 0);

type scratchpad_t is array(integer range <>) of unsigned(7 downto 0);

type debug_signals is
record
	regFile			: register_file;
	scratchpad		: scratchpad_t(63 downto 0);
	scratch_valid	: std_logic;
	scratchAddr		: unsigned(7 downto 0);
	carry			: std_logic;
	zero			: std_logic;
	regSelect		: std_logic;
	opA_value		: unsigned (7 downto 0);
	opB_value		: unsigned (7 downto 0);
	result_v		: unsigned(8 downto 0);
end record;

function to_hstring (value : unsigned) return STRING;
function to_string (arg : unsigned) return string;
function to_slv(uns : unsigned) return std_logic_vector;

procedure copy_debug(src : in debug_signals; dst : out debug_signals);

constant NUS  : STRING(2 downto 1) := (others => ' ');     -- null STRING

end debugSignals;

package body debugSignals is

	function to_hstring (value : unsigned) return STRING is
		constant ne     : INTEGER := (value'length+3)/4;
		variable pad    : unsigned(0 to (ne*4 - value'length) - 1);
		variable ivalue : unsigned(0 to ne*4 - 1);
		variable result : STRING(1 to ne);
		variable quad   : unsigned(0 to 3);
	begin
		if value'length < 1 then
			return NUS;
		else
			if value (value'left) = 'Z' then
				pad := (others => 'Z');
			else
				pad := (others => '0');
			end if;
			ivalue := pad & value;
			for i in 0 to ne-1 loop
				quad := unsigned(To_X01Z(to_slv(ivalue(4*i to 4*i+3))));
				case quad is
					when x"0"   => result(i+1) := '0';
					when x"1"   => result(i+1) := '1';
					when x"2"   => result(i+1) := '2';
					when x"3"   => result(i+1) := '3';
					when x"4"   => result(i+1) := '4';
					when x"5"   => result(i+1) := '5';
					when x"6"   => result(i+1) := '6';
					when x"7"   => result(i+1) := '7';
					when x"8"   => result(i+1) := '8';
					when x"9"   => result(i+1) := '9';
					when x"A"   => result(i+1) := 'A';
					when x"B"   => result(i+1) := 'B';
					when x"C"   => result(i+1) := 'C';
					when x"D"   => result(i+1) := 'D';
					when x"E"   => result(i+1) := 'E';
					when x"F"   => result(i+1) := 'F';
					when "ZZZZ" => result(i+1) := 'Z';
					when others => result(i+1) := 'X';
				end case;
			end loop;
			return result;
		end if;
	end function to_hstring;
 
	function to_string (arg : unsigned) return string is
		variable result : string (1 to arg'length);
		variable v : unsigned (result'range) := arg;
	begin
		for i in result'range loop
			case v(i) is
			when 'U' =>
				result(i) := 'U';
			when 'X' =>
				result(i) := 'X';
			when '0' =>
				result(i) := '0';
			when '1' =>
				result(i) := '1';
			when 'Z' =>
				result(i) := 'Z';
			when 'W' =>
				result(i) := 'W';
			when 'L' =>
				result(i) := 'L';
			when 'H' =>
				result(i) := 'H';
			when '-' =>
				result(i) := '-';
			end case;
		end loop;
		return result;
	end;
		

	function to_slv(uns : unsigned) return std_logic_vector is
	begin
		return std_logic_vector(uns);
	end function to_slv;

	procedure copy_debug(src : in debug_signals; dst : out debug_signals) is
	begin
		dst.regFile			:= src.regFile;
		dst.scratchpad		:= src.scratchpad;
		dst.scratch_valid	:= src.scratch_valid;
		dst.scratchAddr		:= src.scratchAddr;
		dst.carry			:= src.carry;
		dst.zero			:= src.zero;
		dst.regSelect		:= src.regSelect;
		dst.opA_value		:= src.opA_value;
		dst.opB_value		:= src.opB_value;
		dst.result_v		:= src.result_v;
	end procedure;
end debugSignals;
