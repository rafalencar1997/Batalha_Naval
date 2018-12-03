library IEEE;
use IEEE.std_logic_1164.all;

entity envia_mensagem_fd is
	port (
		clock: 				in STD_LOGIC;
		reset:				in STD_LOGIC;
		
		mensagem: 			in STD_LOGIC_VECTOR(2 downto 0); -- seletor da mensagem no mux;
		enviar:				in STD_LOGIC;
		
		jogada_1, jogada_2:		in std_LOGIC_VECTOR(6 downto 0);
		
		caractere_jogada: in STD_LOGIC_VECTOR(2 downto 0);
		
		saida_serial:		out STD_LOGIC;
		pronto:				out STD_LOGIC
	);

end envia_mensagem_fd;
 

architecture arch of envia_mensagem_fd is 

	component mux8x1_n
		  port(D5,	D4, D3, D2, D1, D0 : in std_logic_vector (6 downto 0);
					SEL: in std_logic_vector(2 downto 0);
					MX_OUT : out std_logic_vector (6 downto 0)
				);
	end component;
				
	component uart
		port ( 
			clock, reset: in  STD_LOGIC;
		
			rx_recebe_dado:       in  STD_LOGIC;
			rx_entrada:           in  STD_LOGIC;
			
			rx_paridade_ok:       out STD_LOGIC;
			rx_tem_dado_rec:      out STD_LOGIC;
			rx_dado_rec:			 out STD_LOGIC_VECTOR(6 downto 0);
			rx_estado:            out STD_LOGIC_VECTOR(6 downto 0);
		
			tx_transmite_dado:    in  STD_LOGIC;
			tx_dado_ascii:        in  STD_LOGIC_VECTOR(6 downto 0);
			tx_transm_andamento:  out STD_LOGIC;
			tx_saida:             out STD_LOGIC;
			tx_pronto:          	 out STD_LOGIC;
			tx_estado:            out STD_LOGIC_VECTOR(6 downto 0)
    );
	 end component;
	 
	 signal s_mensagem: STD_LOGIC_VECTOR(6 downto 0);
	 signal s_caractere: STD_LOGIC_VECTOR(6 downto 0);
	 
	 begin
		
	 with caractere_jogada select
				s_caractere <= jogada_1   when "000",
									jogada_2   when "001",
								   "0000000"  when others;
	
	with mensagem select
				s_mensagem <= "1000101"   when "111",
								  "1011000"   when "110",
								  "1000001"   when "101",
								  "1010110"   when "010",
								  "1000101"   when "001",
								  s_caractere when "000",
								  "0000000"   when others;
	 
	 UARTt: uart
	 		port map( 
			clock,
			reset,
		
			rx_recebe_dado => '0',
			rx_entrada => '0',
			rx_paridade_ok => open,
			rx_tem_dado_rec => open,
			rx_dado_rec => open,
			rx_estado => open,
		
			tx_transmite_dado => enviar,
			tx_dado_ascii => s_mensagem,
			tx_transm_andamento => open,
			tx_saida => saida_serial,
			tx_pronto => pronto,
			tx_estado => open
    );
	 
end arch;

