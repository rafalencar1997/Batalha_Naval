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
	component recebe_mensagem 
		port ( 
			-- Entradas Controle
			clock, reset:   in STD_LOGIC; 
			recebe_enable:  in STD_LOGIC;
			jog_Nmsg:       in STD_LOGIC;
			--Entrada Dados     
			entrada_serial: in STD_LOGIC; 
			--Saídas Controle
			recebe_erro:    out STD_LOGIC;
			recebe_pronto:  out STD_LOGIC;
			--Saídas Dados
			reg_jogada_L:	 out STD_LOGIC_VECTOR(6 downto 0);
			reg_jogada_C:	 out STD_LOGIC_VECTOR(6 downto 0);
			reg_mensagem:	 out STD_LOGIC_VECTOR(6 downto 0);
			estado:		 	 out STD_LOGIC_VECTOR(6 downto 0)
		);
	end component;
	
	-- Envia Mensagem
	component envia_mensagem
		port (
			clock, reset: 			in std_logic;
			enviar_enable:       in std_logic;
			mensagem: 				in std_logic_vector(2 downto 0);
			jogada_L, jogada_C:	in std_LOGIC_VECTOR(6 downto 0);
			saida_serial:			out std_logic;
			envia_pronto:			out std_logic
		);
	end component;
	
	-- Operações do Campo
	component print_escreve_campo
		port (
         clock, reset, iniciar, vez: in std_logic;
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
	
	component ascii_to_7seg
		port ( 
			jogada_linha, jogada_coluna: in std_logic_vector(6 downto 0);
         linha, coluna: out std_logic_vector (6 downto 0) 
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
	RJ: recebe_mensagem
	port map(
		clock          => clock, 
		reset  			=> reset,
		recebe_enable	=> recebe_enable,
		jog_Nmsg			=> jog_Nmsg, 	
		entrada_serial => s_entrada_serial,  
		recebe_erro		=> recebe_erro, 
		recebe_pronto	=> recebe_pronto, 
		reg_jogada_L	=> s_jogada_L, 
		reg_jogada_C	=> s_jogada_C, 
		reg_mensagem	=> s_mensagem,
		estado 			=> open
	);

	-- Envia Mensagem
	EM: envia_mensagem
	port map(
		clock         => clock,
		reset         => reset,
		enviar_enable => enviar_enable,
		mensagem      => mensagem,
		jogada_L      => s_jogada_L,
		jogada_C		  => s_jogada_C,
		saida_serial  => saida_serial_adversario,
		envia_pronto  => enviar_pronto
	);
	
	-- Operações Campo
	OC: print_escreve_campo
	port map(
		clock				  => clock, 
		reset            => reset, 
		iniciar          => opera_enable,
		vez				  => vez,
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
	
	ASC_7SEG: ascii_to_7seg
	port map ( 
			jogada_linha =>  s_jogada_L,
			jogada_coluna => s_jogada_C,
         linha         => jogada_L,
			coluna        => jogada_C
	);
	
end batalha_naval_fd_arc;