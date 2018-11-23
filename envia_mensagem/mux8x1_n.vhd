-- mux2x1_n.vhd
--             multiplexador 2x1 com entradas de n bits (generic)
--
-- adaptado a partir do c�digo my_4t1_mux.vhd do livro "Free Range VHDL" 
--
-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;

-- entity
entity mux8x1_n is
  port(D5, D4, D3, D2, D1, D0 : in std_logic_vector (6 downto 0);
       SEL: in std_logic_vector(2 downto 0);
       MX_OUT : out std_logic_vector (6 downto 0));
end mux8x1_n;

-- architecture
architecture arch_mux8x1_n of mux8x1_n is
begin
  MX_OUT <= D5 when (SEL = "111") else
				D4 when (SEL = "110") else
				D3 when (SEL = "101") else
				D2 when (SEL = "010") else
				D1 when (SEL = "001") else
            D0 when (SEL = "000") else
            (others => '0');
end arch_mux8x1_n;
