library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity batalha_naval is
    port (clock, reset: 				 in  STD_LOGIC;
			 vez:								 in  STD_LOGIC;
			 entrada_serial_terminal: 	 in  STD_LOGIC;
			 entrada_serial_adversario: in  STD_LOGIC;
			 saida_serial_terminal: 	 out STD_LOGIC;
			 saida_serial_adversario:   out STD_LOGIC;
			 jogada_L: 						 out STD_LOGIC_VECTOR(6 downto 0);
			 jogada_C: 						 out STD_LOGIC_VECTOR(6 downto 0);
			 resultado_jogada: 			 out STD_LOGIC_VECTOR(1 downto 0);
			 jogador_da_vez: 				 out STD_LOGIC_VECTOR(6 downto 0);
			 --placar_jogador: 				 out STD_LOGIC_VECTOR(6 downto 0);
			 --placar_adversario: 			 out STD_LOGIC_VECTOR(6 downto 0)
			 
			 -- Depuração
			 estado: 						 out STD_LOGIC_VECTOR(6 downto 0);
			 estado_REC: 					out STD_LOGIC_VECTOR(6 downto 0)
    );
end batalha_naval;

architecture batalha_naval_arc of batalha_naval is

	-- Unidade de Controle Central
	component batalha_naval_uc  
		port(	
			clock, reset: 			in STD_LOGIC;
			vez: 						in STD_LOGIC;	
			resposta_jogada:     in STD_LOGIC_VECTOR(1 downto 0);
			estado: 					out STD_LOGIC_VECTOR(3 downto 0);
			-- Controle Recebe
			recebe_erro:         in STD_LOGIC;
			recebe_pronto: 		in STD_LOGIC;
			recebe_enable:       out STD_LOGIC;
			jog_Nmsg:            out STD_LOGIC;
			term_Nadv:           out STD_LOGIC;
			-- Controle Envia
			envia_pronto:   		in STD_LOGIC;
			enviar_enable:       out STD_LOGIC;
			mensagem:            out STD_LOGIC_VECTOR(2 downto 0);
			-- Controle Operações 
			opera_pronto: 			in STD_LOGIC; 
			opera_enable:        out STD_LOGIC;
			operacao:            out STD_LOGIC_VECTOR(1 downto 0)		
	);
	end component;

	-- Fluxo de Dados
	component batalha_naval_fd
		port (clock, reset: 		       in STD_LOGIC;
			 vez:						       in STD_LOGIC;
			 
			 -- Controle Recebe
			 term_Nadv:                 in  STD_LOGIC;
			 jog_Nmsg:                  in  STD_LOGIC;
			 recebe_enable: 				 in  STD_LOGIC;
			 recebe_erro: 					 out STD_LOGIC;
			 recebe_pronto:				 out STD_LOGIC;
			 
			 -- Dados Recebe
			 entrada_serial_terminal:   in STD_LOGIC;
			 entrada_serial_adversario: in STD_LOGIC;
			 jogada_L: 						 out STD_LOGIC_VECTOR(6 downto 0);
			 jogada_C: 						 out STD_LOGIC_VECTOR(6 downto 0);
			 resultado_jogada: 			 out STD_LOGIC_VECTOR(1 downto 0);
			 estado_REC:                out STD_LOGIC_VECTOR(6 downto 0);
			 -- Controle Enviar
			 enviar_enable:   in  STD_LOGIC;
			 mensagem:        in  STD_LOGIC_VECTOR(2 downto 0);
			 enviar_pronto:   out STD_LOGIC;
			 
			 -- Dados Enviar
			 saida_serial_adversario: 		out STD_LOGIC;
			 
			 -- Controle Operações
			 opera_enable: in STD_LOGIC;
			 operacao: 		in STD_LOGIC_VECTOR(1 downto 0);
			 opera_pronto: out STD_LOGIC;
		
			 -- Dados Operações
			 saida_serial_terminal: 		out STD_LOGIC
			 
			 --jogador_da_vez: 		out STD_LOGIC_VECTOR(6 downto 0);
			 --placar_jogador: 		out STD_LOGIC_VECTOR(6 downto 0);
			 --placar_adversario: 	out STD_LOGIC_VECTOR(6 downto 0)    
    );
	end component;
	
	component hex7seg
	port (
		x : in std_logic_vector(3 downto 0);
		enable : in std_logic;
		hex_output : out std_logic_vector(6 downto 0)
		);
	end component;
	
	signal s_recebe_pronto: 		 STD_LOGIC; 
	signal s_operacao_pronto: 		 STD_LOGIC; 
	signal s_envia_pronto:  		 STD_LOGIC;

	signal s_recebe_enable: 		 STD_LOGIC; 
	signal s_operacao_enable: 		 STD_LOGIC; 
	signal s_envia_enable:  		 STD_LOGIC; 
	
	
	signal s_jog_Nmsg: 		 	 STD_LOGIC; 
	signal s_term_Nadv:  		 STD_LOGIC; 
	signal s_recebe_erro:       STD_LOGIC;
	signal s_mensagem:          STD_LOGIC_VECTOR(2 downto 0);
	
	signal s_operacao:          STD_LOGIC_VECTOR(1 downto 0);
	signal s_estado:          STD_LOGIC_VECTOR(3 downto 0);	

begin 
	
	-- Unidade de Controle
	UC: batalha_naval_uc
	port map(	
		clock           => clock, 
		reset				 => not reset,
		vez				 => vez,
		resposta_jogada => "11", 
		estado  			 => s_estado,
		-- Controle Recebe
		recebe_erro		 => s_recebe_erro,
		recebe_pronto	 => s_recebe_pronto, 
		recebe_enable	 => s_recebe_enable,
		jog_Nmsg			 => s_jog_Nmsg,
		term_Nadv		 => s_term_Nadv,
		-- Controle Envia
		envia_pronto	 => s_envia_pronto,
		enviar_enable	 => s_envia_enable,
		mensagem        => s_mensagem,
		-- Controle Operações
		opera_pronto	 => s_operacao_pronto, 
		opera_enable    => s_operacao_enable,
		operacao        => s_operacao
	);

	-- Fluxo de Dados
	FD: batalha_naval_fd
	port map(
		clock								=> clock,  
		reset								=> not reset , 
		vez								=> vez, 		 
		-- Controle Recebe
		term_Nadv  						=> s_term_Nadv,                 
		jog_Nmsg							=> s_jog_Nmsg, 
		recebe_enable					=> s_recebe_enable, 
		recebe_erro						=> s_recebe_erro, 
		recebe_pronto					=> s_recebe_pronto, 
		-- Dados Recebe
		entrada_serial_terminal		=> entrada_serial_terminal, 
		entrada_serial_adversario	=> entrada_serial_adversario, 
		jogada_L							=> jogada_L, 
		jogada_C							=> jogada_C, 
		resultado_jogada				=> resultado_jogada, 
		estado_REC                 => estado_REC,
		-- Controle Enviar
		enviar_enable				=> s_envia_enable, 
		mensagem						=> s_mensagem, 
		enviar_pronto				=> s_envia_pronto, 
		-- Dados Enviar
		saida_serial_adversario	=> saida_serial_adversario, 
		-- Controle Operações
		opera_enable				=> s_operacao_enable, 
		operacao						=> s_operacao, 
		opera_pronto				=> s_operacao_pronto, 
		-- Dados Operações
		saida_serial_terminal	=> saida_serial_terminal   
	); 

	
	HEX: hex7seg
	port map(
		x => s_estado,
		enable => '1',
		hex_output => estado
	);
	
end batalha_naval_arc;