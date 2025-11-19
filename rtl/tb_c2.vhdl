--------------------------------------------------
--	Author:      Lucas Alves de Souza
--	Created:     Nov 18, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o módulo que calcula o complemento de dois.
--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_c2 is
end tb_c2;

architecture tb of tb_c2 is
    --inputs e parametros
    constant N : positive := 32; -- número de bits das entradas
    signal input : std_logic_vector(N - 1 downto 0);

    --outputs
    signal output : std_logic_vector(N - 1 downto 0);

    constant passo : TIME := 20 ns;

begin

    DUV : entity work.c2(behavior)
        generic map(N => N)
        port map
        (
        input   => input,
        output => output
        );

    estimulos : process is
    begin
        input <= std_logic_vector(to_signed(0, input'length));
        wait for passo;
        assert(output="00000000000000000000000000000000")
        report "Fail 0" severity error;

        input <= std_logic_vector(to_signed(1, input'length));
        wait for passo;
        assert(output="11111111111111111111111111111111")
        report "Fail 1" severity error;

        input <= std_logic_vector(to_signed(42, input'length));
        wait for passo;
        assert(output="11111111111111111111111111010110")
        report "Fail 2" severity error;

        input <= std_logic_vector(to_signed(-42, input'length));
        wait for passo;
        assert(output="00000000000000000000000000101010")
        report "Fail 3" severity error;

        input <= "01111111111111111111111111111111";
        wait for passo;
        assert(output="10000000000000000000000000000001")
        report "Fail 4" severity error;

        input <= "10000000000000000000000000000000";
        wait for passo;
        assert(output="10000000000000000000000000000000")
        report "Fail 5" severity error;

        wait for passo;
        assert false report "Test done." severity note;
        wait;
    end process;


end architecture tb;