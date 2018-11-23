-- contador_timer.vhd
--     baseado no componente contador74x163.vhd
--     adaptado para sinais de controle ativos em alto
--     usa limite com generic
-- LabDig - 2018
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity contador_timer is
    generic(
        M: integer := 10     -- modulo do contador
    );
    port (
        CLOCK, CLEAR, ENABLE: in STD_LOGIC;
        RCO: out STD_LOGIC
    );
end contador_timer;

architecture arch of contador_timer is
  signal IQ: INTEGER RANGE 0 TO M-1;
begin
process (CLOCK, ENABLE, IQ)
  begin
    if CLOCK'event and CLOCK='1' then
      if CLEAR='1' then IQ <= 0;
      elsif ENABLE='1' then IQ <= IQ + 1;
      end if;
    end if;
    if IQ=M-1 and ENABLE='1' then RCO <= '1';
    else RCO <= '0';
    end if;
  end process;
end arch;