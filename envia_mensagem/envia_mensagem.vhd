library IEEE;
use IEEE.std_logic_1164.all;

entity envia_mensagem is
	port (
		clock, reset: 			in std_logic;
		enviar_enable:       in std_logic;
		mensagem: 				in std_logic_vector(2 downto 0);
		jogada_L, jogada_C:	in std_LOGIC_VECTOR(6 downto 0);
		saida_serial:			out std_logic;
		envia_pronto:			out std_logic
	);
	
end envia_mensagem;

architecture arch_envia_mensagem of envia_mensagem is
	
	component envia_mensagem_uc 
		port ( 
			clock, reset: 			 in STD_LOGIC; 
			tx_pronto: 				 in STD_LOGIC; 
			envia_mensagem: 		 in STD_LOGIC;
			mensagem: 				 in STD_LOGIC_VECTOR(2 downto 0);
			enviar, envia_pronto: out STD_LOGIC;
			caractere_jogada: 	 out STD_LOGIC_VECTOR(2 downto 0)	
		);
	end component;
	
	component envia_mensagem_fd
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
	
	end component;
	
	signal s_tx_pronto: 			std_logic;
	signal s_enviar: 				std_logic;
	signal s_caractere_jogada: std_logic_vector(2 downto 0);
	
	begin
	
	UC: envia_mensagem_uc 
		port map (
			clock 				=> clock,
			reset 				=> reset,
			tx_pronto 			=> s_tx_pronto,
			envia_mensagem 	=> enviar_enable, 
			mensagem 			=> mensagem,
         enviar 				=> s_enviar,
			envia_pronto 		=> envia_pronto,
			caractere_jogada 	=> s_caractere_jogada
		);
	
	FD: envia_mensagem_fd
		port map (
		clock 				=> clock,
		reset 				=> reset,
		enviar 				=> s_enviar,
		mensagem 			=> mensagem, -- seletor da mensagem no mux;
		caractere_jogada 	=> s_caractere_jogada,
		jogada_L 			=> jogada_L,
		jogada_C				=> jogada_C,
		saida_serial 		=> saida_serial,
		tx_pronto 			=> s_tx_pronto
	);
	
end arch_envia_mensagem;
	
	