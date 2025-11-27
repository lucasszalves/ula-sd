--------------------------------------------------
--  Author:      Marco Antonio Colla
--  Created:     Nov 25, 2025
--  Project:     Atividade Prática 3 - ULA
--  Description: Testbench corrigido para o registrador de lógica padrão.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_std_lr is
end entity;

architecture sim of tb_std_lr is

  constant N : integer := 4;  -- largura do registrador

  signal clk    : std_logic := '0';
  signal enable : std_logic := '0';
  signal d      : std_logic_vector(N-1 downto 0) := (others => '0');
  signal q      : std_logic_vector(N-1 downto 0);

begin

  -- Instancia o DUT
  DUT: entity work.std_logic_register(behavior)
    generic map (N => N)
    port map (
      clk    => clk,
      enable => enable,
      d      => d,
      q      => q
    );

  -- Clock: período 10 ns
  clk <= not clk after 5 ns;

  stim_proc: process
  begin
    --------------------------------------------------------------------
    -- Caso 1: enable=0, q não deve mudar
    --------------------------------------------------------------------
    d <= "1010";
    enable <= '0';
    wait until rising_edge(clk);  -- esperar borda
    wait for 1 ns;               -- garantir atualização de sinais
    assert q = "0000"
      report "Falha: q mudou com enable=0" severity error;

    --------------------------------------------------------------------
    -- Caso 2: enable=1, q deve atualizar
    --------------------------------------------------------------------
    d <= "1100";
    enable <= '1';
    wait until rising_edge(clk);
    wait for 1 ns;
    assert q = "1100"
      report "Falha: q não atualizou com enable=1" severity error;

    --------------------------------------------------------------------
    -- Caso 3: mudar d novamente com enable=1
    --------------------------------------------------------------------
    d <= "0110";
    wait until rising_edge(clk);
    wait for 1 ns;
    assert q = "0110"
      report "Falha: q não atualizou na próxima borda com enable=1" severity error;

    --------------------------------------------------------------------
    -- Caso 4: disable novamente
    --------------------------------------------------------------------
    enable <= '0';
    d <= "1111";
    wait until rising_edge(clk);
    wait for 1 ns;
    assert q = "0110"
      report "Falha: q mudou mesmo com enable=0" severity error;

    -- Finaliza simulação
    wait;
  end process;

end architecture;
