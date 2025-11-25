--------------------------------------------------
--	Author:      Marco Antonio Colla
--	Created:     Nov 25, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o and_or.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_and_or is
end entity;

architecture sim of tb_and_or is

  constant N : integer := 8; -- número de bits para testar

  -- sinais do DUT
  signal input_a : std_logic_vector(N-1 downto 0);
  signal input_b : std_logic_vector(N-1 downto 0);
  signal CAO     : std_logic := '0';
  signal result  : std_logic_vector(N-1 downto 0);

  signal all_ones : std_logic_vector(N-1 downto 0) := (others => '1');

begin

  -- Instancia o DUT
  DUT: entity work.and_or(behavior)
    generic map (N => N)
    port map (
      input_a => input_a,
      input_b => input_b,
      CAO     => CAO,
      result  => result
    );

  -- Processo de estímulos e verificações
  stim_proc: process
  begin
    --------------------------------------------------------------------
    -- Caso 1: AND de 11001100 e 10101010 = 10001000
    --------------------------------------------------------------------
    input_a <= "11001100";
    input_b <= "10101010";
    CAO     <= '0'; -- AND
    wait for 10 ns;

    assert result = "10001000"
      report "AND falhou" severity error;

    --------------------------------------------------------------------
    -- Caso 2: OR de 11001100 e 10101010 = 11101110
    --------------------------------------------------------------------
    CAO <= '1'; -- OR
    wait for 10 ns;

    assert result = "11101110"
      report "OR falhou" severity error;

    --------------------------------------------------------------------
    -- Caso 3: AND de todos 1 e 0 = 00000000
    --------------------------------------------------------------------
    input_a <= (others => '1');
    input_b <= (others => '0');
    CAO     <= '0';
    wait for 10 ns;

    assert result = std_logic_vector(to_unsigned(0, result'length))
      report "AND com zeros falhou" severity error;

    --------------------------------------------------------------------
    -- Caso 4: OR de todos 0 e 1 = 11111111
    --------------------------------------------------------------------
    input_a <= std_logic_vector(to_unsigned(0, result'length));
    input_b <= all_ones;
    CAO     <= '1';
    wait for 10 ns;

    assert result = all_ones
      report "OR com uns falhou" severity error;

    -- Finaliza simulação
    wait;
  end process;

end architecture;
