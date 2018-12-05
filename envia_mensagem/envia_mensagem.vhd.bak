library IEEE;
use IEEE.std_logic_1164.all;

entity envia_mensagem is

	port (
		enviar, reset, clock: 	in std_logic;
		mensagem: 					in std_logic_vector(2 downto 0);
		
		jogada_1, jogada_2:		in std_LOGIC_VECTOR(6 downto 0);
		
		saida_serial, pronto, envia_pronto:	out std_logic
	);
	
end envia_mensagem;

architecture arch_envia_mensagem of envia_mensagem is
	
	component envia_mensagem_uc 
		port ( clock, pronto, envia_mensagem, reset_in: in STD_LOGIC;
			mensagem: in STD_LOGIC_VECTOR(2 downto 0);
         enviar, reset_out, envia_pronto: out STD_LOGIC ;
			caractere_jogada: out STD_LOGIC_VECTOR(2 downto 0)
			
			);
	end component;
	
	component envia_mensagem_fd
	port (
		clock: 				in STD_LOGIC;
		reset:				in STD_LOGIC;
		
		mensagem: 			in STD_LOGIC_VECTOR(2 downto 0); -- seletor da mensagem no mux;
		enviar:				in STD_LOGIC;
		
		jogada_1, jogada_2: in std_LOGIC_VECTOR(6 downto 0);
		
		caractere_jogada: in STD_LOGIC_VECTOR(2 downto 0);
		
		saida_serial:		out STD_LOGIC;
		pronto:				out STD_LOGIC
	);
	
	end component;
	
	signal s_pronto: std_logic;
	signal s_reset: std_logic;
	signal s_enviar: std_logic;
	signal s_caractere_jogada: std_logic_vector(2 downto 0);
	
	begin
	
	UC: envia_mensagem_uc 
		port map (
			clock => clock,
			mensagem => mensagem,
			pronto => s_pronto, 
			envia_mensagem => enviar, 
			reset_in => '0',
         enviar => s_enviar,
			reset_out => s_reset,
			caractere_jogada => s_caractere_jogada,
			envia_pronto => envia_pronto
			);
	
	FD: envia_mensagem_fd
		port map (
		clock => clock,
		reset => s_reset,
		
		mensagem => mensagem, -- seletor da mensagem no mux;
		enviar => s_enviar,
		
		caractere_jogada => s_caractere_jogada,
		
					
		jogada_1 => jogada_1,
		jogada_2 => jogada_2,
		
		saida_serial => saida_serial,
		pronto => s_pronto
	);
	
	pronto <= s_pronto;
	
end arch_envia_mensagem;
	
	