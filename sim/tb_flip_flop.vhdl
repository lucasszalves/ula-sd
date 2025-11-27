--------------------------------------------------
--	Author:      Marco Antonio Colla
--	Created:     Nov 25, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o flip flop.
--------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

entity tb_flip_flop is
end entity;

architecture sim of tb_flip_flop is

    signal clk : std_logic := '0';
    signal d   : std_logic := '0';
    signal q   : std_logic;

begin

    -- Instancia o DUT
    DUT: entity work.flip_flop(behavior)
        port map (
            clk => clk,
            d   => d,
            q   => q
        );

    -- Clock de 10 ns de período
    clk <= not clk after 5 ns;

    -- Processo de estímulos
    stim_proc: process
    begin
        -- Caso 1: d = 0
        d <= '0';
        wait for 10 ns;
        assert q = '0' report "Falha: q deve ser 0" severity error;

        -- Caso 2: d = 1
        d <= '1';
        wait for 10 ns;
        assert q = '1' report "Falha: q deve ser 1" severity error;

        -- Caso 3: d volta para 0
        d <= '0';
        wait for 10 ns;
        assert q = '0' report "Falha: q deve ser 0" severity error;

        wait; -- termina simulação
    end process;

end architecture sim;
