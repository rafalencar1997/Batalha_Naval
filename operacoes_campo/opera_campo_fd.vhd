-- print_escreve_campo.vhd
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity opera_campo_fd is
    port (
        clock, reset: 			in std_logic;
        partida: 					in std_logic;                     -- tx_serial
        we, vez:			 		in std_logic;                     -- memoria_jogo_64x7
        conta, zera, carrega: in std_logic;        				 -- contador_m_load
        endereco: 				in std_logic_vector(13 downto 0); -- contador_m_load
        sel: 						in std_logic_vector(1 downto 0);  -- mux3x1_n
		  dado: 						in std_logic_vector(6 downto 0);
		  enable_led: 				in std_logic;
        fim, fim_linha: 		out std_logic;             		 -- contador_m_load
        saida_serial, pronto:	out std_logic;      					 -- tx_serial
		  resultado_jogada: 		out std_logic_vector(1 downto 0);
        db_q: 						out std_logic_vector(5 downto 0);
        db_dados: 				out std_logic_vector(6 downto 0)
    );
end opera_campo_fd;

architecture arch_opera_campo_fd of opera_campo_fd is

	-- TX Serial
	component tx_serial 
	port (
		clock, reset, partida, paridade: in std_logic;
      dados_ascii: 						  in std_logic_vector(6 downto 0);
      saida_serial, pronto: 			  out std_logic
	);
	end component;
	 
	component registrador_n is
	generic (
      constant N: integer := 8 
	);
	port (
		clock, clear, enable: in STD_LOGIC;
      D: 						 in STD_LOGIC_VECTOR(N-1 downto 0);
      Q: 						 out STD_LOGIC_VECTOR (N-1 downto 0) 
	);
	end component;
	 
	-- Campo do Adversário
	component memoria_jogo_64x7_adv 
	port (
      linha, coluna : in  std_logic_vector(2 downto 0);
      we            : in  std_logic;
      dado_entrada  : in  std_logic_vector(6 downto 0);
		dado_saida    : out std_logic_vector(6 downto 0)
	);
   end component;
    
	-- Campo do Jogador
   component memoria_jogo_64x7
	port (
      linha, coluna : in  std_logic_vector(2 downto 0);
      we            : in  std_logic;
      dado_entrada  : in  std_logic_vector(6 downto 0);
		dado_saida    : out std_logic_vector(6 downto 0)
	);
	end component;

   component contador_m_load
   generic (
		constant M: integer;  -- modulo do contador
      constant N: integer   -- numero de bits da saida
   );
   port (
		CLK, zera, conta, carrega: in STD_LOGIC;
      D: in STD_LOGIC_VECTOR (N-1 downto 0);
      Q: out STD_LOGIC_VECTOR (N-1 downto 0);
      fim: out STD_LOGIC 
	);
   end component;
    
	component decodificador_resultado_jogada 
	port(
		memoria:    in std_logic_vector(6 downto 0);
		jogada_cod: out std_logic_vector (1 downto 0)
	);
	end component;
	 
	component decodificador_jogada 
	port (
		jogada_linha, jogada_coluna: in std_logic_vector(6 downto 0);
		linha, coluna: 				  out std_logic_vector (3 downto 0)
	);
	end component;
	 
	component mux3x1_n
	generic (
		constant BITS: integer := 4
	);
	port(
		D2, D1, D0 : in std_logic_vector (BITS-1 downto 0);
      SEL: in std_logic_vector (1 downto 0);
      MX_OUT : out std_logic_vector (BITS-1 downto 0)	
	);
	end component;
	 
	signal s_contagem, s_endereco: 									  std_logic_vector(5 downto 0);
   signal s_dados, s_mux, s_entrada: 								  std_logic_vector(6 downto 0); 
	signal s_dados_adv,s_imprime_memoria, s_dados_resultado:  std_logic_vector(6 downto 0);
	signal s_resultado_jogada, s_resultado_jogada_verificado: std_logic_vector(1 downto 0);
	signal s_linha, s_coluna: 										  std_logic_vector(3 downto 0);
	signal s_endereco_invalido: 										  std_logic;

begin

   -- Transmissor Serial
	TX: tx_serial 
	port map (
		clock				=> clock, 
		reset				=> reset, 
		partida			=> partida, 
		paridade			=> '0',
      dados_ascii		=> s_mux, 
		saida_serial	=> saida_serial, 
		pronto			=> pronto
	);
    
	-- Campo do Jogador
	C_JOG: memoria_jogo_64x7 
	port map (
		linha				=> s_contagem(5 downto 3), 
		coluna			=> s_contagem(2 downto 0), 
      we					=> we or vez, 
		dado_entrada	=> dado, 
		dado_saida		=> s_dados
	);
	 
	-- Campo do Adversário
	C_ADV: memoria_jogo_64x7_adv
	port map (
		linha				=> s_contagem(5 downto 3), 
		coluna			=> s_contagem(2 downto 0), 
      we					=> we or (not vez), 
		dado_entrada	=> dado, 
		dado_saida		=> s_dados_adv
	);
			
   U3: contador_m_load generic map (M => 64, N => 6) 
	port map (
		CLK		=> clock, 
		zera		=> zera, 
		conta		=> conta, 
		carrega	=> carrega,
      D			=> s_endereco, 
		q			=> s_contagem, 
		fim		=> fim
	);
		
	-- Decodificador Resultado de ASCII para código 
	D_RES: decodificador_resultado_jogada 
	port map (
		memoria 	  => s_dados_resultado, 
		jogada_cod => s_resultado_jogada
	);
	
	-- Decodificador Jogada de ASCII para código 
	D_JOG: decodificador_jogada 
	port map(
		jogada_linha 	=> endereco(13 downto 7),
		jogada_coluna	=> endereco(6 downto 0),
		linha				=> s_linha, 
		coluna			=> s_coluna
	);
	
	REG1: registrador_n generic map(N=>2) 
	port map(
		clock=> clock, 
		clear=>'0', 
		enable=>enable_led, 
		D=>s_resultado_jogada_verificado, 
		Q=>resultado_jogada
	);
													
	s_endereco <= s_linha(2 downto 0) & s_coluna( 2 downto 0);
	
	MUX_IMPRIME:mux3x1_n
	generic map(BITS=> 7)
	port map(
		D2     => "0001101", 
		D1     => "0001010", 
		D0     => s_imprime_memoria,
      SEL    => sel,
      MX_OUT => s_mux	
	);

	
	with vez select
	s_dados_resultado <= s_dados_adv when '1',
								s_dados 	   when others;
	  
	with vez select
	s_imprime_memoria <= s_dados 		when '0',
								s_dados_adv when others;
	 
	with s_contagem(2 downto 0) select
   fim_linha <= '1' when "111", 
					 '0' when others;
	 
	with s_endereco_invalido select
	s_resultado_jogada_verificado <= "11" 					 when '1', 
												s_resultado_jogada when others; 
	
	s_endereco_invalido <= s_linha(3) or s_coluna(3);
	
	-- depuracao
	db_q <= s_contagem;
	db_dados <= s_mux;
    
end arch_opera_campo_fd;

