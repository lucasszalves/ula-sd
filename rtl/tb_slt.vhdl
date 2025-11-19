--------------------------------------------------
--	Author:      Lucas Alves de Souza
--	Created:     Nov 18, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o comparador A<B.
--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- saida = 1, se A for menor do que B,
-- caso o contrário, saida = 0

entity tb_slt is
end tb_slt;

architecture tb of tb_slt is
    constant N : positive := 32; -- número de bits das entradas
    signal input_a, input_b : std_logic_vector(N - 1 downto 0);
    signal result_subtraction : std_logic_vector(N - 1 downto 0);
    signal overflow           : std_logic;

begin
    dut : entity work.subtractor(behavior)
        generic map(N => N)
        port map
        (
        input_a   => input_a,
        input_b   => input_b,
        result    => result_subtraction,
        carry_out => open,
        overflow  => overflow
        );

    result <= overflow xor result_subtraction(N - 1);
end architecture tb;