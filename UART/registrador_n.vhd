-- registrador_n.vhd
--                    registrador com numero de bits como generic
-- modified code (based on vreg16.vhd)
-- original code from: Wakerly, Digital design: principles and practices 4e - page 700
--
library IEEE;
use IEEE.std_logic_1164.all;

entity registrador_n is
  generic (
       constant N: integer := 8 );
  port (clock, clear, enable: in STD_LOGIC;
        D: in STD_LOGIC_VECTOR(N-1 downto 0);
        Q: out STD_LOGIC_VECTOR (N-1 downto 0) );
end registrador_n;

architecture registrador_n of registrador_n is
  signal IQ: STD_LOGIC_VECTOR(N-1 downto 0); -- sinal Q interno
begin

process(clock, clear, enable, IQ)
  begin
    if (clear = '1') then IQ <= (others => '0');
    elsif (clock'event and clock='1') then
      if (enable='1') then IQ <= D; end if;
    end if;
    Q <= IQ;
  end process;
  
end registrador_n;


