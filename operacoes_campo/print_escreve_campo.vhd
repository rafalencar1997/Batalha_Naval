-- print_escreve_campo.vhd
--
-- constantes para operacao
--  IMPRIME := "00"
--  ESCREVE := "01"
--
-- LabDig 2018
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity print_escreve_campo is
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
end print_escreve_campo;

architecture print_escreve_campo of print_escreve_campo is
    signal s_iniciar, s_reseta, s_partida, s_zera, s_conta, s_carrega, s_pronto, s_we, s_fim, s_fim_linha: std_logic;
    signal s_sel: std_logic_vector(1 downto 0);
	 signal s_enable_led: std_logic;
    -- depuracao
    signal s_q: std_logic_vector(5 downto 0);
	 
     
    component print_escreve_campo_uc port ( 
         clock, reset, iniciar: in std_logic;
         operacao: in std_logic_vector(1 downto 0);
         pronto, fim, fim_linha: in std_logic;
         zera, reseta, conta, carrega, we, partida, pronto_out: out std_logic;
         sel: out std_logic_vector(1 downto 0);
			enable_led: out std_logic
    );
    end component;

    component print_escreve_campo_fd port (
        clock, reset: in std_logic;
        partida : in std_logic;                    -- tx_serial
        we: in std_logic;                          -- memoria_jogo_64x7
        conta, zera, carrega: in std_logic;        -- contador_m_load
        endereco: in std_logic_vector(13 downto 0); -- contador_m_load
        dado: in std_logic_vector(6 downto 0);
		  sel: in std_logic_vector(1 downto 0);      -- mux3x1_n
		  enable_led: in std_logic;
        fim, fim_linha: out std_logic;             -- contador_m_load
        saida_serial, pronto : out std_logic;      -- tx_serial
		  resultado_jogada: out std_logic_vector(1 downto 0);
        db_q: out std_logic_vector(5 downto 0);
        db_dados: out std_logic_vector(6 downto 0)
    );
    end component;
    
    component edge_detector_2 is port (
  i_clk                       : in  std_logic;
  i_rstb                      : in  std_logic;
  i_input                     : in  std_logic;
  o_pulse                     : out std_logic);
    end component;

begin

    -- sinais reset e partida mapeados em botoes ativos em alto
    U1: print_escreve_campo_uc port map (clock=>clock, reset=> reset, iniciar=>s_iniciar, operacao=>operacao, pronto=>s_pronto, 
                                 fim=>s_fim, fim_linha=>s_fim_linha, zera=>s_zera, reseta=>s_reseta, conta=>s_conta,
                                 carrega=>s_carrega, we=>s_we, partida=>s_partida, pronto_out=>pronto, sel=>s_sel, enable_led=>s_enable_led);
    U2: print_escreve_campo_fd port map (clock=>clock, reset=>s_reseta, partida=>s_partida , we=>s_we, enable_led=>s_enable_led,
                                 conta=>s_conta, zera=>s_zera, carrega=>s_carrega, endereco=>endereco, dado=>dado, sel=>s_sel, 
                                 fim=>s_fim, fim_linha=>s_fim_linha, 
                                 saida_serial=>saida_serial, pronto=>s_pronto, resultado_jogada=>resultado_jogada,
                                 db_q=>s_q, db_dados=>db_dados);
    U3: edge_detector_2 port map (clock, '1', not iniciar, s_iniciar);


-- depuracao
db_reseta<= s_reseta;
db_partida<=s_partida;
db_zera<=s_zera;
db_conta<=s_conta;
db_carrega<=s_carrega;
db_pronto<=s_pronto;
db_we<=s_we;
db_fim<=s_fim;
db_q<=s_q;
db_sel <= s_sel;

end print_escreve_campo;
