---- edge detector circuit
----
---- based on code avaialable at http://fpgacenter.com/examples/basic/edge_detector.php
--
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--
--entity edge_detector is
--      port ( clk         : in  STD_LOGIC;
--             signal_in   : in  STD_LOGIC;
--             output      : out  STD_LOGIC);
--end edge_detector;
--
--architecture Behavioral of edge_detector is
--     signal signal_d:STD_LOGIC;
--begin
--    process(clk)
--    begin
--         if clk= '1' and clk'event then
--               signal_d<=signal_in;
--         end if;
--    end process;
--    output<= (not signal_d) and signal_in; 
--end Behavioral;




library ieee;
use ieee.std_logic_1164.all;
entity edge_detector_2 is
port (
  i_clk                       : in  std_logic;
  i_rstb                      : in  std_logic;
  i_input                     : in  std_logic;
  o_pulse                     : out std_logic);
end edge_detector_2;
architecture rtl of edge_detector_2 is
signal r0_input                           : std_logic;
signal r1_input                           : std_logic;
begin
p_rising_edge_detector : process(i_clk,i_rstb)
begin
  if(i_rstb='0') then
    r0_input           <= '0';
    r1_input           <= '0';
  elsif(rising_edge(i_clk)) then
    r0_input           <= i_input;
    r1_input           <= r0_input;
  end if;
end process p_rising_edge_detector;
o_pulse            <= not r1_input and r0_input;
end rtl;