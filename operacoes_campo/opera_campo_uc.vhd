-- print_escreve_campo_uc.vhd
--

library IEEE;
use IEEE.std_logic_1164.all;

entity opera_campo_uc is 
	port ( 
		clock, reset: 				in std_logic; 
		opera_enable: 				in std_logic;
      operacao: 					in std_logic_vector(1 downto 0);
      pronto, fim, fim_linha: in std_logic;
      zera, reseta, conta: 	out std_logic;
		carrega, we: 				out std_logic; 
		partida, opera_pronto: 	out std_logic;
      sel: 							out std_logic_vector(1 downto 0);
		enable_led: 				out std_logic
	);
end opera_campo_uc;

architecture arch_opera_campo_uc of opera_campo_uc is

    type State_type is (inicial, envia, espera, incrementa, final, selecionaCR, 
								enviaCR, esperaCR, selecionaNL, enviaNL, esperaNL,
                        carrega_endereco, escreve_memoria, verifica_jogada);
								
    signal Sreg, Snext: State_type;

-- constantes
constant IMPRIME : std_logic_vector(1 downto 0) := "00";
constant ESCREVE : std_logic_vector(1 downto 0) := "01";
constant VERIFICA: std_logic_vector(1 downto 0) := "10";

begin

  process (reset, clock)
  begin
      if reset = '1' then
          Sreg <= inicial;
      elsif clock'event and clock = '1' then
          Sreg <= Snext; 
      end if;
  end process;

  -- proximo estado
  process (opera_enable, operacao, pronto, fim, fim_linha, Sreg) 
  begin
    case Sreg is
	 
      when inicial 			 => if 	 opera_enable='0'  then Snext <= inicial;
										 elsif operacao=IMPRIME  then Snext <= envia;
										 elsif operacao=ESCREVE  then Snext <= carrega_endereco;
										 elsif operacao=VERIFICA then Snext <= carrega_endereco;
										 else  							   Snext <= inicial;
                               end if;
										
      when envia 				 => Snext <= espera;
		
      when espera 			 => if 	 pronto='0' 	then Snext <= espera;
                               elsif fim_linha='0' then Snext <= incrementa;
                               else    					  Snext <= selecionaCR;
                               end if;
										 
      when incrementa 		 => Snext <= envia;
		
      when final 				 => Snext <= inicial;
		
      when selecionaCR 		 => Snext <= enviaCR;
		
      when enviaCR 			 => Snext <= esperaCR;
		
      when esperaCR 			 => if pronto='0' then Snext <= esperaCR;
										 else 					Snext <= selecionaNL;
										 end if;
										
      when selecionaNL 		 => Snext <= enviaNL;
		
      when enviaNL 			 => Snext <= esperaNL;
		
      when esperaNL 			 => if pronto='0' then Snext <= esperaNL;
										 elsif fim='0' then Snext <= incrementa;
										 else 					 Snext <= final;
										 end if;
								
      when carrega_endereco => if operacao=ESCREVE then Snext <= escreve_memoria;
										 else 						  Snext <= verifica_jogada;
										 end if;
										 
      when escreve_memoria  => Snext <= final;
		
		when verifica_jogada  => Snext <= final;
										
      when others 			 => Snext <= inicial;
    end case;
  end process;

  -- saidas
  with Sreg select
      zera <= '1' when inicial, '0' when others;
		
  with Sreg select
      reseta <= '1' when inicial, '0' when others;
		
  with Sreg select
      partida <= '1' when envia | enviaCR | enviaNL, '0' when others;
		
  with Sreg select
      conta <= '1' when incrementa, '0' when others;
		
  with Sreg select
      opera_pronto <= '1' when final, '0' when others;
		
  with Sreg select
      sel <= "10" when selecionaCR | enviaCR | esperaCR,
             "01" when selecionaNL | enviaNL | esperaNL,
             "00" when others;
				 
  with Sreg select
      we <= '0' when escreve_memoria, '1' when others;
		

  with Sreg select
      carrega <= '1' when carrega_endereco, '0' when others;
		
	
  with Sreg select
      enable_led <= '1' when verifica_jogada, '0' when others;
		
end arch_opera_campo_uc;