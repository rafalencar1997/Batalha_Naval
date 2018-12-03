-- decodificador_jogada.vhd
--                    decodificador de jogada
--
-- o bit 3 das saidas indica a ocorrencia de
-- uma entrada invalida

library IEEE;
use IEEE.std_logic_1164.all;

entity ascii_to_7seg is
  port ( jogada_linha, jogada_coluna: in std_logic_vector(6 downto 0);
         linha, coluna: out std_logic_vector (6 downto 0) );
end ascii_to_7seg;

architecture ascii_to_7seg_arch of ascii_to_7seg is
begin

    with jogada_linha select
        linha <= "0001000" when "1000001" | "1100001", -- A ou a
                 "0000011" when "1000010" | "1100010", -- B ou b
                 "1000110" when "1000011" | "1100011", -- C ou c
                 "0100001" when "1000100" | "1100100", -- D ou d
                 "0000110" when "1000101" | "1100101", -- E ou e
                 "0001110" when "1000110" | "1100110", -- F ou f
                 "0010000" when "1000111" | "1100111", -- G ou g
                 "0001001" when "1001000" | "1101000", -- H ou h
                 "1111111" when others;                -- erro
                 
    with jogada_coluna select
        coluna <= "1111001" when "0110001",  -- 1
                  "0100100" when "0110010",  -- 2
                  "0110000" when "0110011",  -- 3
                  "0011001" when "0110100",  -- 4
                  "0010010" when "0110101",  -- 5
                  "0000010" when "0110110",  -- 6
                  "1111000" when "0110111",  -- 7
                  "0000000" when "0111000",  -- 8
                  "1111111" when others;     -- erro
  
end ascii_to_7seg_arch;