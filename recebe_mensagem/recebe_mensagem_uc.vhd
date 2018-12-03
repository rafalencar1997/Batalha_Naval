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
			  recebe_pronto: out STD_LOGIC;
			  estado:		 out STD_LOGIC_VECTOR(3 downto 0)
    );
end recebe_mensagem_uc;

architecture arch of recebe_mensagem_uc is

    type tipo_Estado is (ESPERA_ENABLE, RECEBE_L, REGISTRA_L, RECEBE_C, 
								 ENABLE_RX_L, ENABLE_RX_C, ENABLE_RX_M,
								 REGISTRA_C, RECEBE_M, REGISTRA_M, PRONTO, DECIDE);
	 
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
				when ESPERA_ENABLE => if    enable = '0'   then Eprox <= ESPERA_ENABLE;
											 else              			Eprox <= DECIDE;
											 end if;
											
				when DECIDE			 => if jog_Nmsg = '1' then Eprox <= ENABLE_RX_L;
											 else							Eprox <= ENABLE_RX_M;
											 end if;
											
				when ENABLE_RX_L   => Eprox <= RECEBE_L;
			 
            when RECEBE_L 		 => if rx_pronto = '1' then Eprox <= REGISTRA_L;
											 else  							  Eprox <= RECEBE_L;
											 end if;
					
			   when REGISTRA_L    => Eprox <= ENABLE_RX_C;
				
				when ENABLE_RX_C   => Eprox <= RECEBE_C;
												
            when RECEBE_C      => if rx_pronto = '1' then Eprox <= REGISTRA_C;
											 else  							 Eprox <= RECEBE_C;
											 end if;
												  
				when REGISTRA_C    => Eprox <= PRONTO;
				
				when ENABLE_RX_M   => Eprox <= RECEBE_M;
				
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
		recebe_dado <= '1' when ENABLE_RX_L | ENABLE_RX_C | ENABLE_RX_M,
					      '0' when others;						
	with Eatual select
		estado <= "0000" when ESPERA_ENABLE, 
					 "0001" when RECEBE_L, 
					 "0010" when REGISTRA_L, 
					 "0011" when RECEBE_C, 
					 "0100" when ENABLE_RX_L, 
					 "0101" when ENABLE_RX_C, 
					 "0110" when ENABLE_RX_M,
					 "0111" when REGISTRA_C, 
					 "1000" when RECEBE_M, 
					 "1001" when REGISTRA_M, 
					 "1010" when PRONTO,
					 "1111" when others; 

	
end arch;