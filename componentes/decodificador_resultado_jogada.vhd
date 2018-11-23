-- decodificador_jogada.vhd
--                    decodificador de jogada
--
-- o bit 3 das saidas indica a ocorrencia de
-- uma entrada invalida

library IEEE;
use IEEE.std_logic_1164.all;

entity decodificador_resultado_jogada is
  port ( memoria: in std_logic_vector(6 downto 0);
         jogada_cod: out std_logic_vector (1 downto 0) );
end decodificador_resultado_jogada;

architecture decodificador_resultado_jogada_arch of decodificador_resultado_jogada is
begin
	
    with memoria select
        jogada_cod <= "01" when "1011111", --Resultado Agua quando memoria esta livre
                 "10" when "0100100", -- Acerto quando memoria possui embarcaçao
                 "11" when others;    -- erro
end decodificador_resultado_jogada_arch;


