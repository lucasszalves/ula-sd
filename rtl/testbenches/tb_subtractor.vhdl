--------------------------------------------------
--	Author:      Lucas Alves de Souza
--	Created:     Nov 19, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o subtrator.
--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_subtractor is
end tb_subtractor;

architecture tb of tb_subtractor is
    --inputs e parametros
    constant N : positive := 32; -- número de bits das entradas
    signal input_a, input_b : std_logic_vector(N - 1 downto 0);

    --outputs
    signal result : std_logic_vector(N - 1 downto 0);
    signal overflow, cout : std_logic;

    constant passo : TIME := 20 ns;

begin

    DUV : entity work.subtractor(behavior)
        generic map(N => N)
        port map
        (
        input_a   => input_a,
        input_b   => input_b,
        result => result,
        overflow => overflow,
        carry_out => cout
        );

    estimulos : process is
    begin
        input_a <= std_logic_vector(to_signed(0, input_a'length));
        input_b <= std_logic_vector(to_signed(10, input_a'length));
        wait for passo;
        assert(result=std_logic_vector(to_signed(-10, input_a'length)))
        report "Fail 0" severity error;

        input_a <= std_logic_vector(to_signed(10, input_a'length));
        input_b <= std_logic_vector(to_signed(10, input_a'length));
        wait for passo;
        assert(result=std_logic_vector(to_signed(0, input_a'length)))
        report "Fail 1" severity error;

        input_a <= std_logic_vector(to_signed(164, input_a'length));
        input_b <= std_logic_vector(to_signed(25, input_a'length));
        wait for passo;
        assert(result=std_logic_vector(to_signed(139, input_a'length)))
        report "Fail 2" severity error;

        input_a <= "10000000000000000000000000000000";
        input_b <= "00000000000000000000000000000111";
        wait for passo;
        assert(overflow='1') -- overflow funciona
        report "Fail 3" severity error;

        wait for passo;
        assert false report "Test done." severity note;
        wait;
    end process;


end architecture tb;