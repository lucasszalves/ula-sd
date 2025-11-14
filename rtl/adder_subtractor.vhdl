--------------------------------------------------
--	Author:		Stella Silva Weege, Renato Noskoski Kissel
--	Created:  October 28, 2025
--  Edited: Nov 14, 2025 by Renato Noskoski Kissel
--
--	Project:     	Atividade Prática 3 - ULA
--	Description: 	Contém a descrição de um somador/subtrator de dois valores com sinal de N bits.
--			          Realiza a soma quando o controle `CS = '0'` e a subtração quando `CS = '1'`.
--               	Todas as portas de dados utilizam o tipo `signed`. O controle é std_logic.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Somador/subtrator com sinal (signed) parametrizável para N bits.
-- Calcula input_a + input_b se `CS = '0'` e 
-- input_a - input_b quando `CS = '1'`.
entity adder_subtractor is
  generic (
    N : positive := 32 -- número de bits das entradas e da saída
  );
  port (
    input_a  : in std_logic_vector(N - 1 downto 0); -- entrada A com N bits com sinal
    input_b  : in std_logic_vector(N - 1 downto 0); -- entrada B com N bits com sinal
    CS       : in std_logic; -- controle do somador/subtrator
    overflow : out std_logic; -- sinal de overflow
    result   : out std_logic_vector(N - 1 downto 0) -- saída da soma com sinal
  );
end adder_subtractor;

architecture behavior of adder_subtractor is
  signal intermediary_carry : std_logic_vector(N downto 0);
  signal chosed_B           : std_logic_vector(N - 1 downto 0);
begin

  chosed_B <= input_b when CS = '0' else
    (not(input_b) + 1);

  interator : for i in 0 to N - 1 generate

    adder : entity work.full_adder(circuito_logico)
      port map
      (
        A    => input_a(i),
        B    => chosed_B(i),
        Cin  => intermediary_carry(i),
        S    => result(i),
        Cout => intermediary_carry(i + 1)
      );
  end generate;
  -- lógica do overflow: (C_out do MSB) XOR (C_in do MSB)
  overflow <= intermediary_carry(N) xor intermediary_carry(N - 1);
end architecture behavior;
