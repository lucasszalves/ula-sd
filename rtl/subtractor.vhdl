--------------------------------------------------
--	Author:      Renato Noskoski Kissel
--	Created:     Nov 14, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: subtrator (A-B) com entradas e sainda em std_logic_vector e std_logic
--               carry_out e overflow são usados no circuito. O somador é de tamanho
--               genérico e usar generate para fazer isso. A diferença entre este arquivo
--               e adder é que input_b e negativado no processo.
--------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;
use ieee.numeric_std.all;

entity subtractor is
  generic (
    N : positive := 32 -- número de bits das entradas e da saída
  );
  port (
    input_a   : in std_logic_vector(N - 1 downto 0); -- entrada A com N bits com sinal
    input_b   : in std_logic_vector(N - 1 downto 0); -- entrada B com N bits com sinal
    result    : out std_logic_vector(N - 1 downto 0); -- saída da subtração com sinal
    carry_out : out std_logic; -- carry de saida
    overflow  : out std_logic); -- overflow para checar erros
end subtractor;

architecture behavior of subtractor is
  signal intermediary_carry  : std_logic_vector(N downto 0);
  signal input_b_negativated : std_logic_vector(N - 1 downto 0);

begin
  input_b_negativated   <= not(input_b) + 1;
  intermediary_carry(0) <= '0';

  -- generate para instanciar full_adder apenas uma vez e conseguir subtrair genericamente
  interator : for i in 0 to N - 1 generate

    subtractor : entity work.full_adder(circuito_logico)
      port map
      (
        A    => input_a(i),
        B    => input_b_negativated(i),
        Cin  => intermediary_carry(i),
        S    => result(i),
        Cout => intermediary_carry(i + 1)
      );
  end generate;

  -- lógica do overflow: (C_out do MSB) XOR (C_in do MSB)
  overflow  <= intermediary_carry(N) xor intermediary_carry(N - 1);
  carry_out <= intermediary_carry(N);

end behavior;