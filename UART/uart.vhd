-- bt_tm_cr.vhd
--   circuito de interface com botao, timer integrado e contador de repeticao
--
-- LabDig 2018
--

library IEEE;
use IEEE.std_logic_1164.all;

entity uart is
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
end uart;

architecture arch of uart is

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

	-- Transmissão
	component tx_serial 
		port (
			clock, reset: 	  in std_logic; 
			partida: 			  in std_logic;
			dados_ascii: 	  in std_logic_vector (6 downto 0);
			transm_andamento: out std_logic;
			saida_serial: 	  out std_logic;
			pronto:           out std_logic;
			estado:     		  out STD_LOGIC_VECTOR(6 downto 0)
		);
	end component;
	 
begin

	-- Recepção
   RX: rx_serial 
		port map (
		-- Entradas
		clock 			=> clock, 
		reset				=> reset, 
		recebe_dado		=> rx_recebe_dado, 
		dado_serial		=> rx_entrada,
		-- Saídas	
      par_ok			=> rx_paridade_ok, 
      pronto			=> rx_tem_dado_rec, 
      dado_recebido	=> rx_dado_rec, 
      estado			=> rx_estado
	);
	
	-- Transmissão
	TX: tx_serial 
		port map (
		-- Entradas
		clock 				=> clock, 
		reset					=> reset, 
		partida				=> tx_transmite_dado, 
		dados_ascii			=> tx_dado_ascii, 
		-- Saídas
		transm_andamento	=> tx_transm_andamento, 
		saida_serial		=> tx_saida, 
		pronto				=> tx_pronto, 
		estado				=> tx_estado 
	);
    
end arch;