--------------------------------------------------
--	Author:		Lucas Alves de Souza
--	Created:  November 18, 2025
--
--	Project:     	Atividade Prática 3 - ULA
--	Description: 	Inverte o sinal da entrada, em complemento de dois
--  Tested: 19 Nov, 2025 by Lucas Alves de Souza
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity c2 is
  generic (
    N : positive := 32 -- número de bits das entradas e da saída
  );
  port (
    input  : in std_logic_vector(N - 1 downto 0); -- entrada com N bits com sinal
    output   : out std_logic_vector(N - 1 downto 0) -- saída com sinal
  );
end c2;

architecture behavior of c2 is
    signal negated : std_logic_vector(N - 1 downto 0);
begin

    negated <= not(input);

    add : entity work.adder(behavior)
        port map(
            input_a => negated,
            input_b => std_logic_vector(to_unsigned(1, input'length)),
            result => output,
            carry_out => open
        );

end architecture behavior;
