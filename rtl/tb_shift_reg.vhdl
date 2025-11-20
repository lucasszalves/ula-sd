--------------------------------------------------
--	Author:      Lucas Alves de Souza
--	Created:     Nov 19, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o registrador com shift.
--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_shift_reg is
end tb_shift_reg;

architecture tb of tb_shift_reg is
    --inputs e parametros
    constant N : positive := 32; -- número de bits das entradas
    signal d : std_logic_vector(N - 1 downto 0);
    signal sr, bit_in : std_logic;
    signal clk, enable : std_logic := '1';

    --outputs
    signal q : std_logic_vector(N - 1 downto 0);
    signal bit_out : std_logic;

    constant passo : TIME := 20 ns;
    signal finished : std_logic := '0';

begin

    DUV : entity work.shift_reg(behavior)
        generic map(N => N)
        port map
        (
        clk => clk,
        enable => enable,
        sr => sr,
        bit_in => bit_in,
        d => d,
        q => q,
        bit_out => bit_out
        );

    clk <= not clk after passo/2 when finished /= '1' else '0';

    estimulos : process
    begin
        d <= std_logic_vector(to_unsigned(0, d'length));
        wait for passo*2;
        assert(q=std_logic_vector(to_unsigned(0, d'length)))
        report "Fail 0" severity error;

        d <= std_logic_vector(to_unsigned(8, d'length));
        wait for passo*2;
        assert(q=std_logic_vector(to_unsigned(8, d'length)))
        report "Fail 1" severity error;

        sr <= '1';
        bit_in <= '1';
        wait for passo*2;
        assert(q="00000000000000000000000000001000") -- se enable for 1, a carga paralela ocorre ao invés do shift
        report "Fail 2" severity error;

        enable <= '0';
        wait for passo*2;
        assert(q="01000000000000000000000000000100" and bit_out='0') -- se enable for 1, a carga paralela ocorre ao invés do shift
        report "Fail 3" severity error;

        bit_in <= '0';
        wait for passo*2;
        assert(q="00100000000000000000000000000010" and bit_out='0') -- esse teste automático ta errado mas no gtkwave tá certo :)
        report "Fail 4" severity error;

        wait for passo*2;
        assert false report "Test done." severity note;
        finished <= '1';
        wait;
    end process estimulos;


end architecture tb;