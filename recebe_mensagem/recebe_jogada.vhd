library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity recebe_jogada is
	port ( 
		clock, reset:   in STD_LOGIC;       
		entrada_serial: in STD_LOGIC; 
		enable:         in STD_LOGIC;
		jog_Nmsg:       in STD_LOGIC;
		erro:           out STD_LOGIC;
		recebe_pronto:  out STD_LOGIC;
		reg_jogada_L:	 out STD_LOGIC_VECTOR(6 downto 0);
		reg_jogada_C:	 out STD_LOGIC_VECTOR(6 downto 0);
		reg_mensagem:	 out STD_LOGIC_VECTOR(6 downto 0)
	);
end recebe_jogada;

architecture recebe_jogada_arch of recebe_jogada is

	-- UART
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
  
   -- Unidade de Controle
   component recebe_jogada_uc
		port ( 
			clock, reset:  in  STD_LOGIC;
			enable:        in  STD_LOGIC;
			tem_dado_rec:  in  STD_LOGIC;
			jog_Nmsg:      in  STD_LOGIC;
         enable_regL:   out STD_LOGIC;
         enable_regC:   out STD_LOGIC;
         enable_regM:   out STD_LOGIC;
			recebe_dado:   out STD_LOGIC;
			pronto:        out STD_LOGIC
		);
	end component;
	--dvdvdv
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
	
	-- Sinais
	signal s_tem_dado_rec: 							 STD_LOGIC;
   signal s_enable_L, s_enable_C, s_enable_M: STD_LOGIC;
	signal s_dado_rec: 								 STD_LOGIC_VECTOR(6 downto 0);
	signal s_recebe_dado: 							 STD_LOGIC;
	signal s_erro: 									 STD_LOGIC;
	
begin
	
	-- UART
	UART_C: uart
	port map(
		clock 				  => clock,  
		reset 				  => reset,
		rx_recebe_dado 	  => s_recebe_dado,
		rx_entrada 			  => entrada_serial,
		rx_paridade_ok 	  => s_erro,
		rx_tem_dado_rec 	  => s_tem_dado_rec,
		rx_dado_rec 		  => s_dado_rec,
      rx_estado 			  => open,
		tx_transmite_dado   => '0',
		tx_dado_ascii 		  => "0000000",
      tx_transm_andamento => open,
		tx_saida 			  => open,
      tx_pronto 			  => open,
		tx_estado 			  => open
   );
	
	-- Registrador Linha 
	REG_L: registrador_n
	generic map (N => 7)
   port map(
		clock  => clock,
		clear  => reset, 
		enable => s_enable_L,
		D      => s_dado_rec,
		Q      => reg_jogada_L
	);
	
	-- Registrador Coluna 
	REG_C: registrador_n
	generic map (N => 7)
   port map(
		clock  => clock,
		clear  => reset, 
		enable => s_enable_C,
		D      => s_dado_rec,
		Q      => reg_jogada_C
	);
	
	-- Registrador Mensagem 
	REG_M: registrador_n
	generic map (N => 7)
   port map(
		clock  => clock,
		clear  => reset, 
		enable => s_enable_M,
		D      => s_dado_rec,
		Q      => reg_mensagem
	);
	
	-- Unidade de Controle
	UC: recebe_jogada_uc
	port map( 
		clock        => clock,  
		reset        => reset, 
		enable       => enable, 
		tem_dado_rec => s_tem_dado_rec, 
		jog_Nmsg     => jog_Nmsg,
		enable_regL  => s_enable_L, 
		enable_regC  => s_enable_C,
		enable_regM  => s_enable_M, 
		recebe_dado  => s_recebe_dado,
		pronto       => recebe_pronto
    );
	
	erro <= s_erro;
  
  
end recebe_jogada_arch;