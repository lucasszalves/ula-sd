--------------------------------------------------
--	Author:      Lucas Alves de Souza
--	Created:     Nov 18, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o somador-subtrator.
--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_add_subtr is
end tb_add_subtr;

architecture tb of tb_add_subtr is
    --inputs e parametros
    constant N : positive := 32; -- número de bits das entradas
    signal input_a, input_b : std_logic_vector(N - 1 downto 0);
    signal CS : std_logic := '0';

    --outputs
    signal result : std_logic_vector(N - 1 downto 0);
    signal overflow : std_logic;

    constant passo : TIME := 20 ns;

begin

    DUV : entity work.adder_subtractor(behavior)
        generic map(N => N)
        port map
        (
        input_a   => input_a,
        input_b   => input_b,
        CS    => CS,
        overflow  => overflow,
        result => result
        );

    estimulos : process is
    begin
        input_a <= std_logic_vector(to_unsigned(0, input_a'length));
        input_b <= std_logic_vector(to_unsigned(10, input_a'length));
        wait for passo;
        assert(result="00000000000000000000000000001010")
        report "Fail 0" severity error;

        input_a <= std_logic_vector(to_unsigned(10, input_a'length));
        input_b <= std_logic_vector(to_unsigned(10, input_a'length));
        wait for passo;
        assert(result=std_logic_vector(to_unsigned(20, input_a'length)))
        report "Fail 1" severity error;

        input_a <= "01111111111111111111111111111111";
        input_b <= "00000000000000000000000000000001";
        wait for passo;
        assert(overflow='1') -- overflow para positivos
        report "Fail 2" severity error;

        input_a <= "01111111111111111111111111111111";
        input_b <= "00000000000000000000000000000001";
        CS <= '1';
        wait for passo;
        assert(result="01111111111111111111111111111110")
        report "Fail 3" severity error;

        input_a <= "00000000000000000000000000000001";
        input_b <= "00000000000000000000000000000101";
        CS <= '1';
        wait for passo;
        assert(result=std_logic_vector(to_signed(-4, input_a'length)))
        report "Fail 4" severity error;

        input_a <= "10000000000000000000000000000000";
        input_b <= "00000000000000000000000000000001";
        CS <= '1';
        wait for passo;
        assert(overflow='1') -- overflow para negativos
        report "Fail 5" severity error;


        wait for passo;
        assert false report "Test done." severity note;
        wait;
    end process;


end architecture tb;