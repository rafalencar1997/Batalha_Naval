-- tx_serial_uc.vhd
--
-- based on smexamp.vhd
-- from: Wakerly, Digital design: principles and practices 4e - page 631

library IEEE;
use IEEE.std_logic_1164.all;

entity tx_serial_uc is 
  port ( clock, reset, partida, tick, fim: in STD_LOGIC;
         zera, conta, carrega, desloca, pronto, transm_and: out STD_LOGIC; 
			estado: out STD_LOGIC_VECTOR(3 downto 0)
			);
end;

architecture tx_serial_uc of tx_serial_uc is
    type State_type is (inicial, preparacao, espera, transmissao, final);
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
  process (partida, tick, fim, Sreg) 
  begin
    case Sreg is
      when inicial =>          if partida='1' then Snext <= preparacao;
                               else                Snext <= inicial;
                               end if;
      when preparacao =>       Snext <= espera;
      when espera =>           if tick='1' then   Snext <= transmissao;
                               elsif fim='0' then Snext <= espera;
                               else               Snext <= final;
                               end if;
      when transmissao =>      if fim='0' then Snext <= espera;
                               else            Snext <= final;
                               end if;
      when final =>            Snext <= inicial;
      when others =>           Snext <= inicial;
    end case;
  end process;

  -- output logic (based on state only)
  with Sreg select  -- output logic (based on state only)
      transm_and <= '1' when preparacao|espera|transmissao, '0' when others;
  with Sreg select  -- output logic (based on state only)
      carrega <= '1' when preparacao, '0' when others;
  with Sreg select
      zera <= '1' when preparacao, '0' when others;
  with Sreg select
      desloca <= '1' when transmissao, '0' when others;
  with Sreg select
      conta <= '1' when transmissao, '0' when others;
  with Sreg select
      pronto <= '1' when final, '0' when others;
  with Sreg select
		estado <= "0000" when inicial,
					 "0001" when preparacao,
					 "0010" when espera,			 
					 "0011" when transmissao,
					 "0100" when final,
					 "1111" when others;

end tx_serial_uc;
