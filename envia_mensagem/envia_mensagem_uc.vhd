library IEEE;
use IEEE.std_logic_1164.all;

entity envia_mensagem_uc is 
	port ( 
		clock, reset: 			 in STD_LOGIC; 
		tx_pronto: 				 in STD_LOGIC; 
		envia_mensagem: 		 in STD_LOGIC;
		mensagem: 				 in STD_LOGIC_VECTOR(2 downto 0);
		enviar, envia_pronto: out STD_LOGIC;
		caractere_jogada: 	 out STD_LOGIC_VECTOR(2 downto 0)	
	);
end;

architecture arch_envia_mensagem_uc of envia_mensagem_uc is

	type State_type is (INICIAL, ENVIA_M, ENVIA_L, ENVIA_C,
							  ESPERA_PRONTO_MENSAGEM, ESPERA_PRONTO_LINHA, ESPERA_PRONTO_COLUNA, FIM);
							  
	signal Sreg, Snext: State_type;  -- current state and next state
	
begin
	
	process (reset, clock)
	begin
      if reset = '1' then
          Sreg <= INICIAL;
		elsif clock'event and clock = '1' then
          Sreg <= Snext; 
      end if;
	end process;
	
	process (envia_mensagem, tx_pronto, Sreg) 
	begin
    case Sreg is
	 
		when INICIAL => if 	 envia_mensagem='0' then Snext <= INICIAL;
							 elsif mensagem="000" 	  then Snext <= ENVIA_L;
							 else 							    Snext <= ENVIA_M;
							 end if;
		
		when ENVIA_M => Snext <= ESPERA_PRONTO_MENSAGEM;
		
		when ESPERA_PRONTO_MENSAGEM => if 	tx_pronto='1' then Snext <= FIM;
												 else 						 Snext <= ESPERA_PRONTO_MENSAGEM;
												 end if;
									 
		when ENVIA_L => Snext <= 	ESPERA_PRONTO_LINHA;
		
		when ESPERA_PRONTO_LINHA => if tx_pronto='1' then Snext <= ENVIA_C;
											 else 					  Snext <= ESPERA_PRONTO_LINHA;
											 end if;
									 
		when ENVIA_C => Snext <= ESPERA_PRONTO_COLUNA;
		
		when ESPERA_PRONTO_COLUNA => if tx_pronto='1' then Snext <= FIM;
											  else 					   Snext <= ESPERA_PRONTO_COLUNA;
											  end if;
									 
		when FIM 	=> Snext <= INICIAL;
									 
		when others => Snext <= INICIAL;
		
	 end case;
	end process;
	
	with Sreg select 
      enviar <= '1' when ENVIA_M | ENVIA_L | ENVIA_C,
					 '0' when others;
						
	with Sreg select					
		caractere_jogada <= "001" when ENVIA_C | ESPERA_PRONTO_COLUNA,
									"000" when others;
	
	with Sreg select
		envia_pronto <= '1' when FIM,
							 '0' when others;
		
end arch_envia_mensagem_uc;
	 
	 
	 
	 
	 
	 
	 
	 
	 
	
	
	
	
	
	