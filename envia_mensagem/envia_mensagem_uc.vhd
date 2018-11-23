library IEEE;
use IEEE.std_logic_1164.all;

entity envia_mensagem_uc is 
  port ( clock, pronto, envia_mensagem, reset_in: in STD_LOGIC;
			mensagem: in STD_LOGIC_VECTOR(2 downto 0); -- seletor de mensagem
         enviar, reset_out, envia_pronto: out STD_LOGIC;
			caractere_jogada: out STD_LOGIC_VECTOR(2 downto 0)
			);
end;

architecture arch_envia_mensagem_uc of envia_mensagem_uc is
	type State_type is (INICIAL, ENVIA_M, ENVIA_L, ENVIA_C, ESPERA_PRONTO_MENSAGEM, ESPERA_PRONTO_LINHA, ESPERA_PRONTO_COLUNA, FIM);
	signal Sreg, Snext: State_type;  -- current state and next state
	
begin
	
	process (reset_in, clock)
	begin
      if reset_in = '1' then
          Sreg <= INICIAL;
		elsif clock'event and clock = '1' then
          Sreg <= Snext; 
      end if;
	end process;
	
	process (envia_mensagem, pronto, Sreg) 
	begin
    case Sreg is
	 
		when INICIAL => if envia_mensagem='0' then Snext <= INICIAL;
							 elsif mensagem="000" then Snext <= ENVIA_L;
							 else Snext <= ENVIA_M;
							 end if;
		
		when ENVIA_M => Snext <= ESPERA_PRONTO_MENSAGEM;
		
		when ESPERA_PRONTO_MENSAGEM => if pronto='1' then Snext <= FIM;
									 else Snext <= ESPERA_PRONTO_MENSAGEM;
									 end if;
									 
		when ENVIA_L => Snext <= 	ESPERA_PRONTO_LINHA;
		
		when ESPERA_PRONTO_LINHA => if pronto='1' then Snext <= ENVIA_C;
									 else Snext <= ESPERA_PRONTO_LINHA;
									 end if;
									 
		when ENVIA_C => Snext <= ESPERA_PRONTO_COLUNA;
		
		when ESPERA_PRONTO_COLUNA => if pronto='1' then Snext <= FIM;
									 else Snext <= ESPERA_PRONTO_COLUNA;
									 end if;
									 
		when FIM => Snext <= INICIAL;
									 
		when others =>           Snext <= INICIAL;
		
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
		
	reset_out <= '0';

end arch_envia_mensagem_uc;
	 
	 
	 
	 
	 
	 
	 
	 
	 
	
	
	
	
	
	