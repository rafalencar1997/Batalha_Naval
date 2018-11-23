-- mux2x1_n.vhd
--             multiplexador 2x1 com entradas de n bits (generic)
--
-- adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL" 
--

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2x1_n is
  port(D1, D0 : in std_logic;
       SEL:     in std_logic;
       MX_OUT : out std_logic
	);
end mux2x1_n;

-- architecture
architecture arch_mux2x1_n of mux2x1_n is
begin
	with SEL select
		MX_OUT <= D1 when '1',
					 D0 when others;
				
end arch_mux2x1_n;