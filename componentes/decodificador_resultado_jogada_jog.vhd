-- decodificador_jogada.vhd
--                    decodificador de jogada
--
-- o bit 3 das saidas indica a ocorrencia de
-- uma entrada invalida

library IEEE;
use IEEE.std_logic_1164.all;

entity decodificador_resultado_jogada_jog is
  port ( memoria: in std_logic_vector(6 downto 0);
         jogada_cod: out std_logic_vector (1 downto 0) );
end decodificador_resultado_jogada_jog;

architecture arch of decodificador_resultado_jogada_jog is
begin
	
    with memoria select
        jogada_cod <= "01" when "1000001" | "1100001", -- A ou a
							 "10" when "1011000" | "1111000", -- X ou x
							 "11" when others;    				 -- erro
end arch;