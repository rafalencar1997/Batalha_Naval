library IEEE;
use IEEE.std_logic_1164.all;

entity batalha_naval_uc is 
	port(	
		clock, reset: 			in STD_LOGIC;
		vez: 						in STD_LOGIC;	
		resposta_jogada:     in STD_LOGIC_VECTOR(1 downto 0);
		estado: 					out STD_LOGIC_VECTOR(3 downto 0);
		-- Controle Recebe
		recebe_erro:         in STD_LOGIC;
		recebe_pronto: 		in STD_LOGIC;
		recebe_enable:       out STD_LOGIC;
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
		INICIAL, ESPERA_VEZ, IMPRIME_1, RECEBE_JOGADA_TERMINAL, 
		ENVIA_JOGADA, RECEBE_RESPOSTA,  MARCA_JOGADA_TERMINAL, IMPRIME_2,PASSA_VEZ, 
		RECEBE_JOGADA_ADVERSARIO, VERIFICA_JOGADA_ADVERSARIO, 
		MARCA_JOGADA_ADVERSARIO, ENVIA_RESPOSTA, MENSAGEM_ERRO
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
	process (vez, recebe_pronto, resposta_jogada, envia_pronto, opera_pronto, Sreg) 
	begin
		case Sreg is
	 
			when INICIAL                     => if vez ='1' then Snext <= RECEBE_JOGADA_TERMINAL;
															else             Snext <= RECEBE_JOGADA_ADVERSARIO;
															end if;
		 
			when ESPERA_VEZ 				 		=> if vez ='1' then Snext <= IMPRIME_1;
															else             Snext <= ESPERA_VEZ;
															end if;
															
			when IMPRIME_1							=>	if opera_pronto = '1' then Snext <= RECEBE_JOGADA_TERMINAL;
															else             		 		Snext <= IMPRIME_1;
															end if; 									
															
			when RECEBE_JOGADA_TERMINAL 		=> if recebe_pronto ='1' then Snext <= ENVIA_JOGADA;
															else                       Snext <= RECEBE_JOGADA_TERMINAL;
															end if;
														
											 
			when ENVIA_JOGADA 					=> if envia_pronto ='1' then Snext <= RECEBE_RESPOSTA;
															else            			  Snext <= ENVIA_JOGADA;
															end if;
											 
			when RECEBE_RESPOSTA 				=> if recebe_pronto ='1' then Snext <= MARCA_JOGADA_TERMINAL;
															else            				Snext <= RECEBE_RESPOSTA;
															end if; 
															
			--when VERIFICA_RESPOSTA 				=> if erro ='1' then Snext <= MENSAGEM_ERRO;
			--												else            	Snext <= MARCA_JOGADA_TERMINAL;
			--												end if; 
											 
			when MARCA_JOGADA_TERMINAL 		=> if opera_pronto='1' then Snext <= IMPRIME_2;
															else 						    Snext <= MARCA_JOGADA_TERMINAL;
															end if;
															
			when IMPRIME_2							=>	if opera_pronto = '1' then Snext <= PASSA_VEZ;
															else             		 		Snext <= IMPRIME_2;
															end if; 
			
			when PASSA_VEZ 						=> if envia_pronto ='1' then Snext <= RECEBE_JOGADA_ADVERSARIO;
															else            			  Snext <= PASSA_VEZ;
															end if; 
											 
			when RECEBE_JOGADA_ADVERSARIO 	=> if recebe_pronto ='1' then Snext <= VERIFICA_JOGADA_ADVERSARIO;
															else            			  Snext <= RECEBE_JOGADA_ADVERSARIO;
															end if;
			
			when VERIFICA_JOGADA_ADVERSARIO 	=> if resposta_jogada ="11" then Snext <= MENSAGEM_ERRO;
															elsif	opera_pronto='1'   then Snext <= ENVIA_RESPOSTA;
															else 							      Snext <= MARCA_JOGADA_ADVERSARIO;
															end if;
															
			when MARCA_JOGADA_ADVERSARIO     => if opera_pronto='1' then Snext <= ENVIA_RESPOSTA;
															else 						    Snext <= MARCA_JOGADA_ADVERSARIO;
															end if;
											 
			when ENVIA_RESPOSTA 					=> if envia_pronto ='1' then Snext <= ESPERA_VEZ;
															else            			  Snext <= ENVIA_RESPOSTA;
															end if;
			
			when MENSAGEM_ERRO 					=> Snext <= MENSAGEM_ERRO;
			
			
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
		recebe_enable <= '1' when RECEBE_JOGADA_TERMINAL | RECEBE_JOGADA_ADVERSARIO | RECEBE_RESPOSTA,
				           '0' when others;	
	with Sreg select
		mensagem  <= "000" 					  when ENVIA_JOGADA,
				       "010" 					  when PASSA_VEZ,
						 '1' & resposta_jogada when ENVIA_RESPOSTA,
						 "110" when others;
	with Sreg select
		enviar_enable  <= '1' when ENVIA_JOGADA | ENVIA_RESPOSTA | PASSA_VEZ,
				            '0' when others;	
	with Sreg select
		opera_enable  <= '1' when VERIFICA_JOGADA_ADVERSARIO | MARCA_JOGADA_ADVERSARIO | MARCA_JOGADA_TERMINAL | IMPRIME_1 | IMPRIME_2,
				           '0' when others;		
	with Sreg select
		operacao  <= IMPRIME  when IMPRIME_1 | IMPRIME_2,
				       ESCREVE  when MARCA_JOGADA_TERMINAL | MARCA_JOGADA_ADVERSARIO,
						 VERIFICA when VERIFICA_JOGADA_ADVERSARIO,
						 "11" when others;
	with Sreg select
		estado <= "0000" when INICIAL,  							-- 0
					 "0001" when ESPERA_VEZ, 						-- 1
					 "0010" when IMPRIME_1, 						-- 2
					 "0011" when RECEBE_JOGADA_TERMINAL,   	-- 3
					 "0100" when ENVIA_JOGADA, 					-- 4
					 "0101" when RECEBE_RESPOSTA,  				-- 5
					 "0110" when MARCA_JOGADA_TERMINAL, 		-- 6
				    "0111" when IMPRIME_2,							-- 7
					 "1000" when PASSA_VEZ, 						-- 8
					 "1001" when RECEBE_JOGADA_ADVERSARIO, 	-- 9
					 "1010" when VERIFICA_JOGADA_ADVERSARIO,  -- A
					 "1011" when MARCA_JOGADA_ADVERSARIO, 		-- B
					 "1100" when ENVIA_RESPOSTA, 					-- C
					 "1101" when MENSAGEM_ERRO,					-- D
					 "1111" when others;								-- F
	

end batalha_naval_uc_arc;
