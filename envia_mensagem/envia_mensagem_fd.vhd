library IEEE;
use IEEE.std_logic_1164.all;

entity envia_mensagem_fd is
	port (
		clock: 					in STD_LOGIC;
		reset:					in STD_LOGIC;
		enviar:					in STD_LOGIC;
		mensagem: 				in STD_LOGIC_VECTOR(2 downto 0); -- seletor da mensagem no mux;
		caractere_jogada: 	in STD_LOGIC_VECTOR(2 downto 0);
		jogada_L, jogada_C:	in std_LOGIC_VECTOR(6 downto 0);
		saida_serial:			out STD_LOGIC;
		tx_pronto:				out STD_LOGIC
	);
end envia_mensagem_fd;

architecture arch of envia_mensagem_fd is 
				
	 component tx_serial
		port (
        clock, reset, partida: in std_logic;
        dados_ascii: in std_logic_vector (6 downto 0);
        transm_andamento, saida_serial, pronto : out std_logic;
		  estado: out std_logic_vector (6 downto 0)
    );
	 end component;
	 
	 signal s_mensagem: STD_LOGIC_VECTOR(6 downto 0);
	 signal s_caractere: STD_LOGIC_VECTOR(6 downto 0);
	 
	begin
		
	with caractere_jogada select
	s_caractere <= jogada_L   when "000",
						jogada_C   when "001",
					   "0000000"  when others;
	
	with mensagem select
	s_mensagem <= "1000101"   when "111",
					  "1011000"   when "110",
					  "1000001"   when "101",
					  "1010110"   when "010",
					  "1000101"   when "001",
					  s_caractere when "000",
					  "0000000"   when others;
	
	TX: tx_serial
	port map(
        clock 				 => clock,
		  reset 				 => reset,
		  partida 			 => enviar,
        dados_ascii 		 => s_mensagem,
        transm_andamento => open,
		  saida_serial 	 => saida_serial,
		  pronto 			 => tx_pronto,
		  estado 			 => open
	); 
	 
end arch;

