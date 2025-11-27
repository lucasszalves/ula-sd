--------------------------------------------------
--	Author:      Marco Antonio Colla
--	Created:     Nov 25, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o full adder.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_full_adder is
end entity;

architecture sim of tb_full_adder is

  signal A, B, Cin : std_logic;
  signal S, Cout   : std_logic;

begin

  -- Instancia o DUT
  DUT: entity work.full_adder(circuito_logico)
    port map (
      A    => A,
      B    => B,
      Cin  => Cin,
      S    => S,
      Cout => Cout
    );

  stim_proc: process
  begin
    --------------------------------------------------------------------
    -- Caso 1: 0 + 0 + 0
    --------------------------------------------------------------------
    A <= '0'; B <= '0'; Cin <= '0'; wait for 10 ns;
    assert S = '0' and Cout = '0' report "Falha caso 000" severity error;

    --------------------------------------------------------------------
    -- Caso 2: 0 + 0 + 1
    --------------------------------------------------------------------
    A <= '0'; B <= '0'; Cin <= '1'; wait for 10 ns;
    assert S = '1' and Cout = '0' report "Falha caso 001" severity error;

    --------------------------------------------------------------------
    -- Caso 3: 0 + 1 + 0
    --------------------------------------------------------------------
    A <= '0'; B <= '1'; Cin <= '0'; wait for 10 ns;
    assert S = '1' and Cout = '0' report "Falha caso 010" severity error;

    --------------------------------------------------------------------
    -- Caso 4: 0 + 1 + 1
    --------------------------------------------------------------------
    A <= '0'; B <= '1'; Cin <= '1'; wait for 10 ns;
    assert S = '0' and Cout = '1' report "Falha caso 011" severity error;

    --------------------------------------------------------------------
    -- Caso 5: 1 + 0 + 0
    --------------------------------------------------------------------
    A <= '1'; B <= '0'; Cin <= '0'; wait for 10 ns;
    assert S = '1' and Cout = '0' report "Falha caso 100" severity error;

    --------------------------------------------------------------------
    -- Caso 6: 1 + 0 + 1
    --------------------------------------------------------------------
    A <= '1'; B <= '0'; Cin <= '1'; wait for 10 ns;
    assert S = '0' and Cout = '1' report "Falha caso 101" severity error;

    --------------------------------------------------------------------
    -- Caso 7: 1 + 1 + 0
    --------------------------------------------------------------------
    A <= '1'; B <= '1'; Cin <= '0'; 
    wait for 10 ns;
    assert S = '0' and Cout = '1' report "Falha caso 110" severity error;

    --------------------------------------------------------------------
    -- Caso 8: 1 + 1 + 1
    --------------------------------------------------------------------
    A <= '1'; B <= '1'; Cin <= '1'; wait for 10 ns;
    assert S = '1' and Cout = '1' report "Falha caso 111" severity error;

    wait;
  end process;

end architecture;
