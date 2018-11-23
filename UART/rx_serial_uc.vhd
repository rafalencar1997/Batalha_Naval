-- unidade_controle.vhd
--   controle com interface com botao, timer integrado e contador de repeticao
-- LabDig 2018
--
library IEEE;
use IEEE.std_logic_1164.all;

entity rx_serial_uc is
    port ( clock, reset:  in   STD_LOGIC;
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
end rx_serial_uc;

architecture arch of rx_serial_uc is
    type tipo_Estado is (ESPERA_RECEBE, LEITURA_START, ESPERA_TICK_1, LEITURA_DADO_1, ESPERA_TICK_2, LEITURA_DADO_2, ESPERA_TIMER );
    signal Eatual, Eprox: tipo_Estado;
begin

    process (clock, reset)
    begin
        if reset = '1' then
            Eatual <= ESPERA_RECEBE;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    process (dado_serial, fim_cont, recebe_dado, tick, Eatual)
    begin
        case Eatual is
				when ESPERA_RECEBE =>  if recebe_dado = '1' then  Eprox <= LEITURA_START;
											    else  Eprox <= ESPERA_RECEBE;
											    end if;
			
            when LEITURA_START =>  if dado_serial = '0' then  Eprox <= ESPERA_TICK_1;
											  else  Eprox <= LEITURA_START;
											  end if;
					
			   when ESPERA_TICK_1 => if tick = '0' then   Eprox <= ESPERA_TICK_1;
                                  else                   Eprox <= LEITURA_DADO_1;
                                  end if;
												
            when LEITURA_DADO_1 => Eprox <= ESPERA_TICK_2;
												  
				when ESPERA_TICK_2 =>  if tick = '0' then  Eprox <= ESPERA_TICK_2;
                                   else                  Eprox <= LEITURA_DADO_2;
                                   end if;
												
            when LEITURA_DADO_2 => if fim_cont = '0' then Eprox <= ESPERA_TICK_2;
                                   else                    Eprox <= ESPERA_TIMER;
                                   end if;
                                      
            when ESPERA_TIMER  =>  if recebe_dado = '1' then Eprox <= LEITURA_START;
                                   else                   Eprox <= ESPERA_TIMER;
                                   end if;
            when others =>            Eprox <= ESPERA_RECEBE;
        end case;
    end process;
	 
    -- saidas de controle ativos em alto
	with Eatual select
		enable_tick1 <= '1' when ESPERA_TICK_1,
							   '0'   when others;
	with Eatual select
		enable_tick2 <= '1' when ESPERA_TICK_2 | LEITURA_DADO_2,
							   '0' when others;
	
	with Eatual select
		clear_tick <= '1' when LEITURA_START,
							 '0' when others;
	 
	with Eatual select
		pronto <= '1' when ESPERA_TIMER,
			     	 '0' when others;
	 
    with Eatual select
      clear_cont <= '1' when LEITURA_START,
                    '0' when others;

    with Eatual select
      enable_cont  <= '1' when LEITURA_DADO_1 | LEITURA_DADO_2,
                     '0' when others;
	  				  

	with Eatual select
      desloca <= '1' when LEITURA_DADO_1 |LEITURA_DADO_2 | LEITURA_START,
                 '0' when others;
	 					  
   with Eatual select
		estado   <= "0000" when ESPERA_RECEBE,
						"0001" when LEITURA_START,
						"0010" when ESPERA_TICK_1,
                  "0011" when LEITURA_DADO_1,
						"0100" when ESPERA_TICK_2,
                  "0101" when LEITURA_DADO_2,
                  "0110" when ESPERA_TIMER,                   
                  "1111" when others;
						  
end arch;