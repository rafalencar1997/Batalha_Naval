-- gerador_paridade_n
--     com numero de bits de dados como generic
--     saidas par e impar calculados para uso em comunicacao serial RS232C
--
library IEEE;
use IEEE.std_logic_1164.all;

entity gerador_paridade_n is
    generic (
        constant N: integer := 7
    );
    port (
        dado:       in STD_LOGIC_VECTOR (N-1 downto 0);
        par, impar: out STD_LOGIC
    );
end gerador_paridade_n;

architecture gerador_paridade_n_arch of gerador_paridade_n is
begin
process (dado)
  variable p : STD_LOGIC;
  begin
    p := dado(0);
    for j in 1 to N-1 loop
      p := p xor dado(j);
    end loop;
    par <= not p;
    impar <= p;  
  end process;
end gerador_paridade_n_arch;
