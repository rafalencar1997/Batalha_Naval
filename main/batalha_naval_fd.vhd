library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity batalha_naval_fd is
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
end batalha_naval_fd;

architecture batalha_naval_fd_arc of batalha_naval_fd is

	-- Multiplexador de duas entradas
	component mux2x1_n
		port(
			D1, D0 : in std_logic;
			SEL:     in std_logic;
			MX_OUT : out std_logic
		);
	end component;

	-- Recebe Jogada
	component recebe_jogada 
		port ( 
			clock, reset:   in STD_LOGIC;       
			entrada_serial: in STD_LOGIC; 
			enable:         in STD_LOGIC;
			jog_Nmsg:       in STD_LOGIC;
			erro:           out STD_LOGIC;
			pronto: 			 out STD_LOGIC;
			reg_jogada_L:	 out STD_LOGIC_VECTOR(6 downto 0);
			reg_jogada_C:	 out STD_LOGIC_VECTOR(6 downto 0);
			reg_mensagem:	 out STD_LOGIC_VECTOR(6 downto 0)
		);
	end component;
	
	-- Envia Mensagem
	component envia_mensagem
		port (
		enviar, reset, clock: 	in std_logic;
		mensagem: 					in std_logic_vector(2 downto 0);
		
		jogada_1, jogada_2:		in std_LOGIC_VECTOR(6 downto 0);
		
		saida_serial, pronto, envia_pronto:	out std_logic
	);
	end component;
	
	-- Operações do Campo
	component print_escreve_campo
		port (
        clock, reset, iniciar: in std_logic;
        operacao: in std_logic_vector(1 downto 0);
		  dado: in std_logic_vector(6 downto 0);
        endereco: in std_logic_vector(13 downto 0);
        saida_serial, pronto : out std_logic;
		  resultado_jogada : out std_logic_vector(1 downto 0);
        -- depuracao
        db_reseta, db_partida, db_zera, db_conta, db_carrega, db_pronto, db_we, db_fim: out std_logic;
        db_q: out std_logic_vector(5 downto 0);
        db_sel: out std_logic_vector(1 downto 0);
        db_dados: out std_logic_vector(6 downto 0)
    );
	end component;
	
	component hex7seg
	port (
		x : in std_logic_vector(3 downto 0);
		enable : in std_logic;
		hex_output : out std_logic_vector(6 downto 0)
	);
	end component;
	
	signal s_entrada_serial: STD_LOGIC; 
	signal s_jogada_L:       STD_LOGIC_VECTOR(6 downto 0);
	signal s_jogada_C:       STD_LOGIC_VECTOR(6 downto 0);
	signal s_mensagem:       STD_LOGIC_VECTOR(6 downto 0);
	
begin 
		
	with term_Nadv select
		s_entrada_serial <= entrada_serial_terminal when '1',
							     entrada_serial_adversario when others; 
	
	
	-- Recebe Jogada
	RJ: recebe_jogada
	port map(
		clock          => clock, 
		reset  			=> reset,      
		entrada_serial => s_entrada_serial,  
		enable			=> recebe_enable, 
		jog_Nmsg			=> jog_Nmsg, 
		erro				=> recebe_erro, 
		pronto			=> recebe_pronto, 
		reg_jogada_L	=> s_jogada_L, 
		reg_jogada_C	=> s_jogada_C, 
		reg_mensagem	=> s_mensagem 
	);
	
	-- Envia Mensagem
	EM: envia_mensagem
	port map(
		clock        => clock,
		reset        => reset,
		enviar       => enviar_enable,
		mensagem     => mensagem,
		jogada_1     => s_jogada_L,
		jogada_2		 => s_jogada_C,
		saida_serial => saida_serial_adversario,
		pronto       => open,
		envia_pronto => enviar_pronto
	);
	
	-- Operações Campo
	OC: print_escreve_campo
	port map(
		clock				  => clock, 
		reset            => reset, 
		iniciar          => opera_enable,
		operacao         => operacao,  
		dado             => s_mensagem,
		endereco         => s_jogada_L & s_jogada_C,
		saida_serial     => saida_serial_terminal, 
		pronto           => opera_pronto,
		resultado_jogada => resultado_jogada,
		-- depuracao
		db_reseta        	=> open, 
		db_partida			=> open, 
		db_zera				=> open,
		db_conta				=> open, 
		db_carrega			=> open, 
		db_pronto			=> open, 
		db_we					=> open, 
		db_fim				=> open,
		db_q					=> open,
		db_sel				=> open,
		db_dados				=> open
	);
		
	jogada_L<= s_jogada_L;
	jogada_C<= s_jogada_L;
	
	
end batalha_naval_fd_arc;