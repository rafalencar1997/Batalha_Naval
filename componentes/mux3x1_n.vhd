-- mux3x1_n.vhd
--             multiplexador 3x1 com entradas de n bits (generic)
--
-- adaptado a partir do codigo my_4t1_mux.vhd do livro "Free Range VHDL" 
--
-- declaracao do componente
-- component mux3x1_n
--   generic (
--         constant BITS: integer := 4);
--   port(D2, D1, D0 : in std_logic_vector (BITS-1 downto 0);
--        SEL: in std_logic_vector (1 downto 0);
--        MX_OUT : out std_logic_vector (BITS-1 downto 0));
-- end component;
--
library IEEE;
use IEEE.std_logic_1164.all;

entity mux3x1_n is
  generic (
       constant BITS: integer := 4);
  port(D2, D1, D0 : in std_logic_vector (BITS-1 downto 0);
       SEL: in std_logic_vector (1 downto 0);
       MX_OUT : out std_logic_vector (BITS-1 downto 0));
end mux3x1_n;

-- architecture
architecture arch_mux3x1_n of mux3x1_n is
begin
  MX_OUT <= D2 when (SEL = "10") else
            D1 when (SEL = "01") else
            D0 when (SEL = "00") else
            (others => '1');
end arch_mux3x1_n;
