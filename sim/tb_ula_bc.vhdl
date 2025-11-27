--------------------------------------------------
--	Author:      Lucas Alves de Souza
--	Created:     Nov 26, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Testbench para o Bloco de Controle da ULA.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ula_pack.all;

entity tb_ula_bc is
end tb_ula_bc;

architecture sim of tb_ula_bc is

    -- inputs
    signal clk : std_logic := '1';
    signal rst_a : std_logic := '0';
    signal in_controle : bc_entradas;
    signal in_status : status_bo;

    -- outputs
    signal out_controle : bc_saidas;
    signal out_comandos : bc_comandos;

    signal finished : std_logic := '0';


begin

    DUT: entity work.ula_bc(behavior)
            port map (
                clk => clk,
                rst_a => rst_a,
                in_controle => in_controle,
                in_status => in_status,
                out_controle => out_controle,
                out_comandos => out_comandos
            );

    clk <= not clk after 10 ns when finished /= '1' else '0';

    estimulos: process
    begin
        --------------------------------------------------------------------
        -- RESET
        --------------------------------------------------------------------
        wait for 20 ns;
        rst_a <= '1';
        wait for 20 ns;
        rst_a <= '0';

        in_controle.iniciar <= '1';
        in_status.C <= "000";
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;
        wait for 20 ns;

        assert false report "Test done." severity note;
            finished <= '1';
        wait;
    end process;

    end architecture;
