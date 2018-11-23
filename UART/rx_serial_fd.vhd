-- bt_tm_cr.vhd
--   circuito de interface com botao, timer integrado e contador de repeticao
--
-- LabDig 2018
--

library IEEE;
use IEEE.std_logic_1164.all;

entity rx_serial_fd is
    port ( 
		clock, reset:                           in  STD_LOGIC;
		desloca, dado_serial, pronto:  			 in  STD_LOGIC;
		clear_c, enable_c:             			 in  STD_LOGIC;  
		clear_tick, enable_tick1, enable_tick2: in  STD_LOGIC;
		estado: 											 in  STD_LOGIC_VECTOR(3 downto 0);
		par_ok, fim_c, tick:                    out STD_LOGIC;
		estado7seg:   									 out STD_LOGIC_VECTOR(6 downto 0);
		dado_recebido:   								 out STD_LOGIC_VECTOR(6 downto 0)	
    );
end rx_serial_fd;

architecture arch of rx_serial_fd is

	-- Deslocador N
	component deslocador_n
		generic (
			constant N: integer := 11
		);
		port (
			clock, reset: in std_logic;
			carrega, desloca, entrada_serial: in std_logic; 
			dados: in std_logic_vector (N-1 downto 0);
			saida: out  std_logic_vector (N-1 downto 0)
		); 
	end component;
	        
   -- Hexadecimal para 7 segmentos
	component hex7seg
      port (
        x : in STD_LOGIC_VECTOR(3 downto 0);
        enable : in STD_LOGIC;
        hex_output : out STD_LOGIC_VECTOR(6 downto 0)
      );
   end component;
	 		
	-- Contador M
	component contador_m is
		generic (
			constant M: integer := 50;  -- módulo do contador
			constant N: integer := 6    -- número de bits da saída
		);
		port (
        CLK, zera, conta: in STD_LOGIC;
        Q: out STD_LOGIC_VECTOR (N-1 downto 0);
        fim: out STD_LOGIC
		);
	end component;
		
	-- Gerador de Paridade
	component gerador_paridade_n
		generic (
			N: integer
		);
		port (
        dado:       in STD_LOGIC_VECTOR (N-1 downto 0);
        par, impar: out STD_LOGIC
		);
	end component;
	 
	signal s_dados_serial :STD_LOGIC_VECTOR(10 downto 0) := "00000000000"; 
	signal s_par_gerado: STD_LOGIC;
	signal s_pronto: STD_LOGIC;
	signal s_tick1, s_tick2: STD_LOGIC;
	
begin
    
	-- deslocador
	DESLOCADOR: deslocador_n 
		generic map(N=>11)
		port map (clock, reset,'0', 
					 desloca, dado_serial, s_dados_serial, s_dados_serial); 
	 
	-- gerador paridade
	PARIDADE: gerador_paridade_n 
		generic map(N=>11) 
		port map (s_dados_serial, s_par_gerado, open);
	 
	--contador dados
	CONT_DADOS: contador_m 
		generic map(M=>11, N=>4) 
		port map(clock, clear_c, enable_c, open, fim_c);
	 
	-- contador tick 
	CONT_TICK_1: contador_m 
		generic map (M => 217, N => 17)
		port map (clock, clear_tick, enable_tick1, open, s_tick1); 
		
	-- contador tick 
	CONT_TICK_2: contador_m 
		generic map (M => 434, N => 18) 
		port map (clock, clear_tick, enable_tick2, open, s_tick2);

	-- displays
   HEX5: hex7seg 
		port map (estado, '1', estado7seg);
		
	dado_recebido <= s_dados_serial(7 downto 1);
	par_ok <= s_par_gerado and pronto;
	tick <= s_tick1 or s_tick2;
end arch;