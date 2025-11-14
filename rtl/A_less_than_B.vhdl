--------------------------------------------------
--	Author:      Renato Noskoski Kissel
--	Created:     Nov 14, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: A<B, saida = 1 se A<B, caso contrário, saida = 0.
--               Este arquivo irá ser usado apenas na divisão, apesar da ULA implementar
--               esta operação, ficaria inviável usar a outra lógica já escrita.
--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- saida = 1, se A for menor do que B,
-- caso o contrário, saida = 0

entity A_less_than_B is
  generic (
    N : positive := 32 -- número de bits das entradas
  );
  port (
    input_a : in signed(N - 1 downto 0); -- entrada A com N bits com sinal
    input_b : in signed(N - 1 downto 0); -- entrada B com N bits com sinal
    result  : out std_logic -- saída
  );
end A_less_than_B;

architecture behavior of A_less_than_B is
  signal result_subtraction : std_logic_vector(N - 1 downto 0);
  signal overflow           : std_logic;

begin
  subtractor : entity work.subtractor(behavior)
    generic map(N => N)
    port map
    (
      input_a   => to_Std_Logic_Vector(input_a),
      input_b   => to_Std_Logic_Vector(input_b),
      result    => result_subtraction,
      carry_out => open,
      overflow  => overflow
    );

  result <= overflow xor result_subtraction(N - 1);
end architecture behavior;