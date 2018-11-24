-- hex7seg
--         7 segment hexadecimal display with enable pin
--         bits de saida na ordem 6...0
library ieee;
use ieee.std_logic_1164.all;

entity hex7seg is
	port (
		x : in std_logic_vector(3 downto 0);
		enable : in std_logic;
		hex_output : out std_logic_vector(6 downto 0)
	);
end hex7seg;

architecture hex7seg of hex7seg is
begin
	process (enable, x)
	begin
		if enable = '0' then
	        hex_output <= "1111111";
	    else
			case x is
				when "0000" => hex_output <= "1000000"; -- 0
				when "0001" => hex_output <= "1111001"; -- 1			
				when "0010" => hex_output <= "0100100"; -- 2
				when "0011" => hex_output <= "0110000"; -- 3
				when "0100" => hex_output <= "0011001"; -- 4
				when "0101" => hex_output <= "0010010"; -- 5
				when "0110" => hex_output <= "0000010"; -- 6
				when "0111" => hex_output <= "1111000"; -- 7
				when "1000" => hex_output <= "0000000"; -- 8
				when "1001" => hex_output <= "0010000"; -- 9
				when "1010" => hex_output <= "0001000"; -- A
				when "1011" => hex_output <= "0000011"; -- B
				when "1100" => hex_output <= "1000110"; -- C
				when "1101" => hex_output <= "0100001"; -- D
				when "1110" => hex_output <= "0000110"; -- E
				when others => hex_output <= "0001110"; -- F
			end case;
		end if;
	end process;
end hex7seg;
