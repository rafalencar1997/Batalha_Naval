library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity recebe_mensagem is
	port ( 
		-- Entradas Controle
		clock, reset:   in STD_LOGIC; 
		recebe_enable:  in STD_LOGIC;
		recebe_reset:   in STD_LOGIC;
		jog_Nmsg:       in STD_LOGIC;
		--Entrada Dados     
		entrada_serial: in STD_LOGIC; 
		--Saídas Controle
		recebe_erro:    out STD_LOGIC;
		recebe_pronto:  buffer STD_LOGIC;
		recebe_vez:     out STD_LOGIC;
		--Saídas Dados
		reg_jogada_L:	 out STD_LOGIC_VECTOR(6 downto 0);
		reg_jogada_C:	 out STD_LOGIC_VECTOR(6 downto 0);
		reg_mensagem:	 buffer STD_LOGIC_VECTOR(6 downto 0);
		estado:		 	 out STD_LOGIC_VECTOR(6 downto 0)
	);
end recebe_mensagem;

architecture recebe_mensagem_arch of recebe_mensagem is

	-- Recepção
	component rx_serial 
		port ( 
			clock, reset:  in  STD_LOGIC;
			recebe_dado:   in  STD_LOGIC;
			dado_serial:   in  STD_LOGIC;
			par_ok:        out STD_LOGIC;
			pronto:        out STD_LOGIC;
			dado_recebido: out STD_LOGIC_VECTOR(6 downto 0);
			estado:        out STD_LOGIC_VECTOR(6 downto 0)
    );
   end component;
  
   -- Unidade de Controle
   component recebe_mensagem_uc
		port ( 
			clock, reset:  in  STD_LOGIC;
			enable:        in  STD_LOGIC;
			rx_pronto:     in  STD_LOGIC;
			jog_Nmsg:      in  STD_LOGIC;
         enable_regL:   out STD_LOGIC;
         enable_regC:   out STD_LOGIC;
         enable_regM:   out STD_LOGIC;
			recebe_dado:   out STD_LOGIC;
			recebe_pronto: out STD_LOGIC;
			estado:		 out STD_LOGIC_VECTOR(3 downto 0)
		);
	end component;
	-- Registrador
	component registrador_n
		generic (
			constant N: integer := 8 
		);
		port (
		   clock, clear, enable: in STD_LOGIC;
			D: in STD_LOGIC_VECTOR(N-1 downto 0);
			Q: out STD_LOGIC_VECTOR (N-1 downto 0) 
		);
	end component;
	
	component hex7seg is
		port (
			x : in std_logic_vector(3 downto 0);
			enable : in std_logic;
			hex_output : out std_logic_vector(6 downto 0)
		);
	end component;
	
	-- Sinais
	signal s_rx_pronto: 							    STD_LOGIC;
   signal s_enable_L, s_enable_C, s_enable_M: STD_LOGIC;
	signal s_dado_rec: 								 STD_LOGIC_VECTOR(6 downto 0);
	signal s_recebe_dado: 							 STD_LOGIC;
	signal s_estado: 									 STD_LOGIC_VECTOR(3 downto 0);
	
begin
	
	RX: rx_serial 
		port map (
		-- Entradas
		clock 			=> clock, 
		reset				=> reset, 
		recebe_dado		=> s_recebe_dado, 
		dado_serial		=> entrada_serial,
		-- Saídas	
      par_ok			=> recebe_erro, 
      pronto			=> s_rx_pronto, 
      dado_recebido	=> s_dado_rec, 
      estado			=> open
	);
	
	-- Registrador Linha 
	REG_L: registrador_n
	generic map (N => 7)
   port map(
		clock  => clock,
		clear  => recebe_reset, 
		enable => s_enable_L,
		D      => s_dado_rec,
		Q      => reg_jogada_L
	);
	
	-- Registrador Coluna 
	REG_C: registrador_n
	generic map (N => 7)
   port map(
		clock  => clock,
		clear  => recebe_reset, 
		enable => s_enable_C,
		D      => s_dado_rec,
		Q      => reg_jogada_C
	);
	
	-- Registrador Mensagem 
	REG_M: registrador_n
	generic map (N => 7)
   port map(
		clock  => clock,
		clear  => recebe_reset, 
		enable => s_enable_M,
		D      => s_dado_rec,
		Q      => reg_mensagem
	);
	
	-- Unidade de Controle
	UC: recebe_mensagem_uc
	port map( 
		-- Entradas
		clock         => clock,  
		reset         => reset, 
		enable        => recebe_enable, 
	   rx_pronto     => s_rx_pronto, 
		jog_Nmsg      => jog_Nmsg,
		-- Saídas
		enable_regL   => s_enable_L, 
		enable_regC   => s_enable_C,
		enable_regM   => s_enable_M, 
		recebe_dado   => s_recebe_dado,
		recebe_pronto => recebe_pronto,
		estado        => s_estado 
    );
  
	HEX: hex7seg
	port map(
			x => s_estado,
			enable => '1',
			hex_output => estado
	);
	
	recebe_vez <= '1' when (reg_mensagem = "1010110" and recebe_pronto = '1') else '0';

  
end recebe_mensagem_arch;