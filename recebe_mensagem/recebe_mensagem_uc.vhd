-- unidade_controle.vhd
--   controle com interface com botao, timer integrado e contador de repeticao
-- LabDig 2018
--
library IEEE;
use IEEE.std_logic_1164.all;

entity recebe_mensagem_uc is
    port ( clock, reset:  in  STD_LOGIC;
			  enable:        in  STD_LOGIC;
			  rx_pronto:     in  STD_LOGIC;
			  jog_Nmsg:      in  STD_LOGIC;
           enable_regL:   out STD_LOGIC;
           enable_regC:   out STD_LOGIC;
           enable_regM:   out STD_LOGIC;
			  recebe_dado:   out STD_LOGIC;
			  recebe_pronto: out STD_LOGIC
    );
end recebe_mensagem_uc;

architecture arch of recebe_mensagem_uc is
    type tipo_Estado is (ESPERA_ENABLE, RECEBE_L, REGISTRA_L, RECEBE_C, REGISTRA_C, RECEBE_M, REGISTRA_M, PRONTO);
    signal Eatual, Eprox: tipo_Estado;
begin

    process (clock, reset)
    begin
        if reset = '1' then
            Eatual <= ESPERA_ENABLE;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    process (enable, rx_pronto, jog_Nmsg, Eatual)
    begin
        case Eatual is
				when ESPERA_ENABLE => 	if    enable = '1'   then Eprox <= ESPERA_ENABLE;
											elsif jog_Nmsg = '1' then Eprox <= RECEBE_L;
											else              			Eprox <= RECEBE_M;
											end if;
			
            when RECEBE_L 		 => if rx_pronto = '1' then Eprox <= REGISTRA_L;
											 else  							  Eprox <= RECEBE_L;
											 end if;
					
			   when REGISTRA_L    => Eprox <= RECEBE_C;
												
            when RECEBE_C      => if rx_pronto = '1' then Eprox <= REGISTRA_C;
											 else  							 Eprox <= RECEBE_C;
											 end if;
												  
				when REGISTRA_C    => Eprox <= PRONTO;
				
				when RECEBE_M      => if rx_pronto = '1' then Eprox <= REGISTRA_M;
									       else  				           Eprox <= RECEBE_M;
									       end if;
												  
				when REGISTRA_M    => Eprox <= PRONTO;
				
				when PRONTO => Eprox <= ESPERA_ENABLE;
				
            when others        => Eprox <= ESPERA_ENABLE;
        end case;
    end process;
	 
    -- saidas de controle ativos em alto
	with Eatual select
		enable_regL <= '1' when REGISTRA_L,
							'0' when others;
	with Eatual select
		enable_regC <= '1' when REGISTRA_C,
							'0' when others;
	with Eatual select
		enable_regM <= '1' when REGISTRA_M,
							'0' when others;
	with Eatual select
		recebe_pronto <= '1' when PRONTO,
					 '0' when others;		
	with Eatual select
		recebe_dado <= '1' when RECEBE_L | RECEBE_C | RECEBE_M,
					      '0' when others;						
						  			 
end arch;