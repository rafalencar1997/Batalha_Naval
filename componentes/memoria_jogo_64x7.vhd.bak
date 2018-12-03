-- codigo ADAPTADO do código encontrado no livro 
-- VHDL Descricao e Sintese de Circuitos Digitais
-- Roberto D'Amore, LTC Editora.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memoria_jogo_64x7 IS
   PORT (linha, coluna : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
         we            : IN  STD_LOGIC;
         dado_entrada  : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
         dado_saida    : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END memoria_jogo_64x7;

ARCHITECTURE ram1 OF memoria_jogo_64x7 IS
  TYPE   arranjo_memoria IS ARRAY(0 TO 63) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL memoria : arranjo_memoria;
  attribute ram_init_file: string;
  attribute ram_init_file of memoria: signal is "campo_inicial.mif";
  signal endereco: STD_LOGIC_VECTOR(5 DOWNTO 0);
BEGIN

  PROCESS(we, endereco)
  BEGIN
	  endereco <= linha & coluna;
        IF rising_edge(we) THEN  
            memoria(to_integer(unsigned(endereco))) <= dado_entrada;
        END IF;
  END PROCESS;

  dado_saida <= memoria(to_integer(unsigned(endereco)));

END ram1;