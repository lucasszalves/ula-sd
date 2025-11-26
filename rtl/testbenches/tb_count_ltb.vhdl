--------------------------------------------------
--	Author:      Marco Antonio Colla
--	Created:     Nov 25, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o count less than B.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_count_ltb is
end tb_count_ltb;

architecture sim of tb_count_ltb is

  constant N : integer := 8;

  -- sinais do DUT
  signal input_a : std_logic_vector(N-1 downto 0);
  signal input_b : std_logic_vector(N-1 downto 0);
  signal result  : std_logic;

begin

  -- Instancia o DUT
  DUT: entity work.count_less_than_B(behavior)
    generic map(N => N)
    port map(
      input_a => input_a,
      input_b => input_b,
      result  => result
    );

  -- processo de estímulos
  stim_proc: process
  begin
    --------------------------------------------------------------------
    -- Caso 1: 3 < 5 → result = 1
    --------------------------------------------------------------------
    input_a <= std_logic_vector(to_signed(3, N));
    input_b <= std_logic_vector(to_signed(5, N));
    wait for 10 ns;
    assert result = '1'
      report "Falha: 3 < 5, esperado 1"
      severity error;

    --------------------------------------------------------------------
    -- Caso 2: 7 < 2 → result = 0
    --------------------------------------------------------------------
    input_a <= std_logic_vector(to_signed(7, N));
    input_b <= std_logic_vector(to_signed(2, N));
    wait for 10 ns;
    assert result = '0'
      report "Falha: 7 < 2, esperado 0"
      severity error;

    --------------------------------------------------------------------
    -- Caso 3: -3 < 0 → result = 1
    --------------------------------------------------------------------
    input_a <= std_logic_vector(to_signed(-3, N));
    input_b <= std_logic_vector(to_signed(0, N));
    wait for 10 ns;
    assert result = '1'
      report "Falha: -3 < 0, esperado 1"
      severity error;

    --------------------------------------------------------------------
    -- Caso 4: 5 < 5 → result = 0
    --------------------------------------------------------------------
    input_a <= std_logic_vector(to_signed(5, N));
    input_b <= std_logic_vector(to_signed(5, N));
    wait for 10 ns;
    assert result = '0'
      report "Falha: 5 < 5, esperado 0"
      severity error;

    --------------------------------------------------------------------
    -- Caso 5: negativo mínimo < 1 → result = 1 (por conta do overflow!)
    --------------------------------------------------------------------
    input_a <= "10000000"; -- valor negativo mínimo
    input_b <= "00000001";
    wait for 10 ns;
    assert result = '1'
      report "Falha: negativo mínimo < 1, esperado 1"
      severity error;

    --------------------------------------------------------------------
    -- Caso 6: negativo qualquer < 1 → result = 1
    --------------------------------------------------------------------
    input_a <= "11000000"; -- valor negativo
    input_b <= "00000001";
    wait for 10 ns;
    assert result = '1'
      report "Falha: negativo < 1, esperado 1"
      severity error;

    --------------------------------------------------------------------
    -- Caso 7: negativo qualquer < 1 → result = 1
    --------------------------------------------------------------------
    input_a <= "11111000"; -- valor negativo
    input_b <= "00000001";
    wait for 10 ns;
    assert result = '1'
      report "Falha: negativo < 1, esperado 1"
      severity error;


    --------------------------------------------------------------------
    -- Finaliza simulação
    --------------------------------------------------------------------
    wait;
  end process;

end architecture;
