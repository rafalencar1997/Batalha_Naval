library IEEE;
use IEEE.std_logic_1164.all;

entity batalha_naval_uc is 
	port(	
		clock, reset: 			in STD_LOGIC;
		jogar:					in STD_LOGIC;
		vez_inicio: 			in STD_LOGIC;
		fim_jog, fim_adv:		in STD_LOGIC;
		placar_adv_enable: 	out STD_LOGIC;
		placar_jog_enable: 	out STD_LOGIC;
		vez: 						out STD_LOGIC;
		resposta_jogada_jog: in STD_LOGIC_VECTOR(1 downto 0);
		resposta_jogada_adv: in STD_LOGIC_VECTOR(1 downto 0);
		gan_per:					out STD_LOGIC_VECTOR(1 downto 0);
		estado: 					out STD_LOGIC_VECTOR(3 downto 0);
		-- Controle Recebe
		recebe_vez: 			in STD_LOGIC;
		recebe_erro:         in STD_LOGIC;
		recebe_pronto: 		in STD_LOGIC;
		recebe_enable:       out STD_LOGIC;
		recebe_reset:        out STD_LOGIC;
		jog_Nmsg:            out STD_LOGIC;
		term_Nadv:           out STD_LOGIC;
		-- Controle Envia
		envia_pronto:   		in STD_LOGIC;
		enviar_enable:       out STD_LOGIC;
		mensagem:            out STD_LOGIC_VECTOR(2 downto 0);
		-- Controle Operações 
		opera_pronto: 			in STD_LOGIC; 
		opera_enable:        out STD_LOGIC;
		operacao:            out STD_LOGIC_VECTOR(1 downto 0)		
	);
end;

architecture batalha_naval_uc_arc of batalha_naval_uc is

	constant IMPRIME  : STD_LOGIC_VECTOR(1 downto 0) := "00";
	constant ESCREVE  : STD_LOGIC_VECTOR(1 downto 0) := "01";
	constant VERIFICA : STD_LOGIC_VECTOR(1 downto 0) := "10";

	type State_type is (
		INICIAL, DECIDE_JOGADOR, 
		ESPERA_VEZ, PASSA_VEZ,
		ENVIA_JOGADA, ENVIA_RESPOSTA, RECEBE_RESPOSTA, 
		IMPRIME_A_1,  IMPRIME_A_2, IMPRIME_J, PLACAR_ADV, PLACAR_JOG,
		MARCA_JOGADA_ADVERSARIO,    MARCA_JOGADA_TERMINAL, 
		RECEBE_JOGADA_ADVERSARIO,   RECEBE_JOGADA_TERMINAL,
		VERIFICA_JOGADA_ADVERSARIO, VERIFICA_RESPOSTA, 
		VERIFICA_FIM_ADV, VERIFICA_FIM_JOG, GANHOU, PERDEU, MENSAGEM_ERRO
	);
	 
   signal Sreg, Snext: State_type;  -- current state and next state
	 
begin

	-- state memory
	process (RESET, CLOCK)
	begin
		if RESET = '1' then
			Sreg <= inicial;
      elsif CLOCK'event and CLOCK = '1' then
         Sreg <= Snext; 
      end if;
	end process;

	-- next-state logic
	process (jogar, vez_inicio, recebe_vez, recebe_pronto, 
				resposta_jogada_jog, resposta_jogada_adv, envia_pronto, opera_pronto, 
				fim_adv, fim_jog, Sreg) 
	begin
		case Sreg is
	 
			when INICIAL                     => if jogar ='1' then Snext <= DECIDE_JOGADOR;
															else               Snext <= INICIAL;
															end if;
															
			when DECIDE_JOGADOR					=> if vez_inicio ='1' then Snext <= IMPRIME_A_1;
															else             			Snext <= RECEBE_JOGADA_ADVERSARIO;
															end if;
		 														
			when IMPRIME_A_1						=>	if opera_pronto = '1' then Snext <= RECEBE_JOGADA_TERMINAL;
															else             		 		Snext <= IMPRIME_A_1;
															end if; 									
															
			when RECEBE_JOGADA_TERMINAL 		=> if recebe_pronto ='1' then Snext <= ENVIA_JOGADA;
															else                       Snext <= RECEBE_JOGADA_TERMINAL;
															end if;
											 
			when ENVIA_JOGADA 					=> if envia_pronto ='1' then Snext <= RECEBE_RESPOSTA;
															else            			  Snext <= ENVIA_JOGADA;
															end if;
					
			when RECEBE_RESPOSTA 				=> if recebe_pronto ='1' then Snext <= VERIFICA_RESPOSTA;
															else            				Snext <= RECEBE_RESPOSTA;
															end if; 
															
			when VERIFICA_RESPOSTA				=> if resposta_jogada_jog ="11" then Snext <= RECEBE_JOGADA_TERMINAL;
															else            				       Snext <= MARCA_JOGADA_TERMINAL;
															end if;
			
			
			when MARCA_JOGADA_TERMINAL 		=> if opera_pronto='1' then Snext <= PLACAR_JOG;
															else 						    Snext <= MARCA_JOGADA_TERMINAL;
															end if;
			-- MARCAR PONTO NO PLACAR JOG												
			when PLACAR_JOG						=> Snext <= VERIFICA_FIM_JOG;
			
			when VERIFICA_FIM_JOG				=> if fim_jog = '1' then Snext <= GANHOU;
															else 					  Snext <= IMPRIME_A_2;
															end if;
																														
			when IMPRIME_A_2						=>	if opera_pronto = '1' then Snext <= PASSA_VEZ;
															else             		 		   Snext <= IMPRIME_A_2;
															end if; 
			
			when PASSA_VEZ 						=> if envia_pronto ='1' then Snext <= RECEBE_JOGADA_ADVERSARIO;
															else            			  Snext <= PASSA_VEZ;
															end if; 											
											 
			when RECEBE_JOGADA_ADVERSARIO 	=> if recebe_pronto ='1' then Snext <= VERIFICA_JOGADA_ADVERSARIO;
															else            			  Snext <= RECEBE_JOGADA_ADVERSARIO;
															end if;
			
			when VERIFICA_JOGADA_ADVERSARIO 	=> if resposta_jogada_adv ="11" then Snext <= MENSAGEM_ERRO;
															elsif	opera_pronto='1'       then Snext <= PLACAR_ADV;
															else 							          Snext <= VERIFICA_JOGADA_ADVERSARIO;
															end if;
			-- MARCAR PONTO NO PLACAR ADV												
			when PLACAR_ADV						=> Snext <= MARCA_JOGADA_ADVERSARIO;
			
			when MARCA_JOGADA_ADVERSARIO     => if opera_pronto='1' then Snext <= ENVIA_RESPOSTA;
															else 						    Snext <= MARCA_JOGADA_ADVERSARIO;
															end if;
										 
			when ENVIA_RESPOSTA 					=> if envia_pronto ='1' then Snext <= IMPRIME_J;
															else            			  Snext <= ENVIA_RESPOSTA;
															end if;
															
			when IMPRIME_J							=>	if opera_pronto = '1' then Snext <= VERIFICA_FIM_ADV;
															else             		 		Snext <= IMPRIME_J;
															end if;
															
			when VERIFICA_FIM_ADV				=> if fim_adv = '1' then Snext <= PERDEU;
															else 					    Snext <= ESPERA_VEZ;
															end if;												
			
			when ESPERA_VEZ 				 		=> if recebe_vez ='1' then Snext <= IMPRIME_A_1;
															else             			Snext <= ESPERA_VEZ;
															end if;
			
			when GANHOU								=> Snext <= GANHOU;
				
			when PERDEU								=> Snext <= PERDEU; 
			
			
			when MENSAGEM_ERRO 					=> if envia_pronto ='1' then Snext <= RECEBE_JOGADA_ADVERSARIO;
															else            			  Snext <= MENSAGEM_ERRO;
															end if;
			
			when others 							=> Snext <= INICIAL;
		end case;
	end process;

	-- output logic (based on state only)
	with Sreg select
		jog_Nmsg <= '1' when RECEBE_JOGADA_TERMINAL | RECEBE_JOGADA_ADVERSARIO,
						'0' when others;
						
	with Sreg select
		term_Nadv <= '1' when RECEBE_JOGADA_TERMINAL ,
						 '0' when others;
						 
	with Sreg select
		recebe_enable <= '1' when RECEBE_JOGADA_TERMINAL | RECEBE_JOGADA_ADVERSARIO | 
										  RECEBE_RESPOSTA | ESPERA_VEZ,
				           '0' when others;
	with Sreg select
		recebe_reset <= '1' when INICIAL | DECIDE_JOGADOR | PASSA_VEZ | IMPRIME_A_1,
							 '0' when others;
		
	with Sreg select
		mensagem  <= "000" 					      when ENVIA_JOGADA,
				       "010" 					      when PASSA_VEZ,
						 '1' & resposta_jogada_adv when ENVIA_RESPOSTA,
						 "111" when others;
						 
	with Sreg select
		enviar_enable  <= '1' when ENVIA_JOGADA | ENVIA_RESPOSTA | PASSA_VEZ | MENSAGEM_ERRO,
				            '0' when others;	
								
	with Sreg select
		opera_enable  <= '1' when VERIFICA_JOGADA_ADVERSARIO |
										  MARCA_JOGADA_ADVERSARIO    | MARCA_JOGADA_TERMINAL | 
										  IMPRIME_A_1 | IMPRIME_A_2  | IMPRIME_J,
				           '0' when others;
							  
	with Sreg select
		operacao  <= IMPRIME  when IMPRIME_A_1 | IMPRIME_A_2 | IMPRIME_J,
				       ESCREVE  when MARCA_JOGADA_TERMINAL     | MARCA_JOGADA_ADVERSARIO,
						 VERIFICA when VERIFICA_JOGADA_ADVERSARIO,
						 "11" when others;
						 
	with Sreg select
		vez  <= vez_inicio when INICIAL | DECIDE_JOGADOR, 
				  '0'        when PASSA_VEZ      | RECEBE_JOGADA_ADVERSARIO | VERIFICA_JOGADA_ADVERSARIO |
										MENSAGEM_ERRO  | PLACAR_ADV | MARCA_JOGADA_ADVERSARIO | 
										ENVIA_RESPOSTA | IMPRIME_J  | VERIFICA_FIM_ADV | ESPERA_VEZ, 
				  '1'  		 when others;
				  
	with Sreg select
		placar_adv_enable <= '1' when PLACAR_ADV,
									'0' when others;
	
	with Sreg select
		placar_jog_enable <= '1' when PLACAR_JOG,
									'0' when others;
		
	with Sreg select
		gan_per <= "10" when GANHOU,
					  "01" when PERDEU,
					  "00" when others;
					  
	with Sreg select
		estado <= "0000" when INICIAL,  							-- 0
					 "0001" when RECEBE_JOGADA_TERMINAL, 		-- 1
				    "0010" when RECEBE_RESPOSTA,					-- 2
					 "0011" when RECEBE_JOGADA_ADVERSARIO,  	-- 3
					 "0100" when ESPERA_VEZ,  						-- 4
					 "1110" when MENSAGEM_ERRO,					-- E
					 "0110" when GANHOU,								-- 6
					 "1101" when PERDEU,								-- D
					 "1111" when others;								-- F
	

end batalha_naval_uc_arc;
