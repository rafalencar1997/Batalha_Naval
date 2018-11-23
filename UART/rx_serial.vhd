-- bt_tm_cr.vhd
--   circuito de interface com botao, timer integrado e contador de repeticao
--
-- LabDig 2018
--

library IEEE;
use IEEE.std_logic_1164.all;

entity rx_serial is
    port ( clock, reset: in  STD_LOGIC;
		recebe_dado:       in  STD_LOGIC;
		dado_serial:       in  STD_LOGIC;
      par_ok:            out STD_LOGIC;
      pronto:          	 out STD_LOGIC;
      dado_recebido:     out STD_LOGIC_VECTOR(6 downto 0);
      estado:            out STD_LOGIC_VECTOR(6 downto 0)
    );
end rx_serial;

architecture arch of rx_serial is

	-- Unidade de Controle
	component rx_serial_uc
		port (
			clock, reset:  in   STD_LOGIC;
			recebe_dado:   in   STD_LOGIC;
			dado_serial:   in   STD_LOGIC;
			fim_cont:      in   STD_LOGIC;
			tick:          in   STD_LOGIC;
			enable_tick1:  out  STD_LOGIC;
			enable_tick2:  out  STD_LOGIC;
			clear_tick:    out  STD_LOGIC;
			pronto:        out  STD_LOGIC;
			clear_cont:    out  STD_LOGIC;
			enable_cont:   out  STD_LOGIC;
			desloca:       out  STD_LOGIC;	
         estado:        out  STD_LOGIC_VECTOR(3 downto 0)
       );
   end component;
	
	-- Fluxo de Dados
	component rx_serial_fd
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
   end component;
	
	signal s_desloca, s_pronto: STD_LOGIC;
	signal s_clear_c, s_enable_c: STD_LOGIC;
	signal s_clear_tick, s_enable_tick1, s_enable_tick2: STD_LOGIC; 
	signal s_fim_c, s_tick: STD_LOGIC;
	signal s_estado: STD_LOGIC_VECTOR(3 downto 0);
	
begin

	-- Unidade de Controle
   UC: rx_serial_uc 
		port map ( 
			-- Entradas
			clock, reset, recebe_dado, dado_serial, s_fim_c, s_tick,
			-- Saidas
			s_enable_tick1, s_enable_tick2, s_clear_tick, s_pronto, 
			s_clear_c, s_enable_c, s_desloca, s_estado
		);
    
	-- Fluxo de Dados 
	FD: rx_serial_fd
		port map(
			-- Entradas
			clock, reset, s_desloca, dado_serial, s_pronto, s_clear_c, s_enable_c, 
			s_clear_tick, s_enable_tick1, s_enable_tick2,
			s_estado,
			-- Saidas
			par_ok, s_fim_c, s_tick, estado, dado_recebido
		);
	
	pronto <= s_pronto;

end arch;