-- decodificador_jogada.vhd
--                    decodificador de jogada
--
-- o bit 3 das saidas indica a ocorrencia de
-- uma entrada invalida

library IEEE;
use IEEE.std_logic_1164.all;

entity decodificador_jogada is
  port ( jogada_linha, jogada_coluna: in std_logic_vector(6 downto 0);
         linha, coluna: out std_logic_vector (3 downto 0) );
end decodificador_jogada;

architecture decodificador_jogada_arch of decodificador_jogada is
begin

    with jogada_linha select
        linha <= "0000" when "1000001" | "1100001", -- A ou a
                 "0001" when "1000010" | "1100010", -- B ou b
                 "0010" when "1000011" | "1100011", -- C ou c
                 "0011" when "1000100" | "1100100", -- D ou d
                 "0100" when "1000101" | "1100101", -- E ou e
                 "0101" when "1000110" | "1100110", -- F ou f
                 "0110" when "1000111" | "1100111", -- G ou g
                 "0111" when "1001000" | "1101000", -- H ou h
                 "1111" when others;                -- erro
                 
    with jogada_coluna select
        coluna <= "0000" when "0110001",  -- 1
                  "0001" when "0110010",  -- 2
                  "0010" when "0110011",  -- 3
                  "0011" when "0110100",  -- 4
                  "0100" when "0110101",  -- 5
                  "0101" when "0110110",  -- 6
                  "0110" when "0110111",  -- 7
                  "0111" when "0111000",  -- 8
                  "1111" when others;     -- erro
  
end decodificador_jogada_arch;


