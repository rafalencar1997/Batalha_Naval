-- tx_serial.vhd
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity tx_serial is
    port (
        clock, reset, partida, paridade: in std_logic;
        dados_ascii: in std_logic_vector (6 downto 0);
        transm_andamento, saida_serial, pronto : out std_logic;
		  estado: out std_logic_vector (6 downto 0)
    );
end tx_serial;

architecture tx_serial of tx_serial is
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim: std_logic;
    signal s_partida: std_logic; -- used by edge_detector
    signal s_estado: std_logic_vector(3 downto 0); 
	  
    component tx_serial_uc port ( 
            clock, reset, partida, tick, fim: in std_logic;
            zera, conta, carrega, desloca, pronto, transm_and: out STD_LOGIC;
			   estado: out STD_LOGIC_VECTOR(3 downto 0)	
				);
    end component;

    component tx_serial_fd 
		port (
			  clock, reset: in std_logic;
			  zera, conta, carrega, desloca, paridade: in std_logic;
			  dados_ascii: in std_logic_vector (6 downto 0);
			  estado: in std_logic_vector (3 downto 0);
			  saida_serial, fim : out std_logic;
			  estado7seg: out std_logic_vector (6 downto 0)
		);
    end component;
    
    component contador_m
	generic (
		constant M: integer;  -- modulo do contador
		constant N: integer   -- numero de bits da saida
	);
    port (
        CLK, zera, conta: in STD_LOGIC;
        Q: out STD_LOGIC_VECTOR (N-1 downto 0);
        fim: out STD_LOGIC);
    end component;
    
    component edge_detector is port ( 
             clk         : in  STD_LOGIC;
             signal_in   : in  STD_LOGIC;
             output      : out  STD_LOGIC);
    end component;
    
begin

    -- sinais reset e partida mapeados em botoes ativos em alto
    U1: tx_serial_uc port map (clock, reset, s_partida, s_tick, s_fim,
                               s_zera, s_conta, s_carrega, s_desloca, pronto, transm_andamento, s_estado);
    U2: tx_serial_fd port map (clock, reset, s_zera, s_conta, s_carrega, s_desloca, paridade, 
                               dados_ascii, s_estado, saida_serial, s_fim, estado);
    -- fator de divisao para 115200 bauds (434=50M/115200)
    U3: contador_m generic map (M => 434, N => 18) port map (clock, s_zera, '1', open, s_tick);
	 -- fator de divisao para simulacao
    -- U3: contador_m generic map (M => 10, N => 4) port map (clock, s_zera, '1', open, s_tick);
    U4: edge_detector port map (clock, partida, s_partida);
    
end tx_serial;

