--------------------------------------------------
--	Author:      Marco Antonio Colla
--	Created:     Nov 25, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Pequeno testbench para o mux 2 to 1.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_mux_2to1 is
end entity;

architecture sim of tb_mux_2to1 is

  constant N : integer := 8; -- largura para teste

  signal sel       : std_logic := '0';
  signal in_0      : std_logic_vector(N-1 downto 0) := (others => '0');
  signal in_1      : std_logic_vector(N-1 downto 0) := (others => '0');
  signal s_mux     : std_logic_vector(N-1 downto 0);

begin

  -- Instancia o DUT
  DUT: entity work.mux_2to1(behavior)
    generic map (N => N)
    port map (
      sel   => sel,
      in_0  => in_0,
      in_1  => in_1,
      s_mux => s_mux
    );

  stim_proc: process
  begin
    --------------------------------------------------------------------
    -- Caso 1: sel = '0', saída deve ser in_0
    --------------------------------------------------------------------
    in_0 <= "10101010";
    in_1 <= "11110000";
    sel  <= '0';
    wait for 10 ns;
    assert s_mux = "10101010" report "Falha caso sel=0" severity error;

    --------------------------------------------------------------------
    -- Caso 2: sel = '1', saída deve ser in_1
    --------------------------------------------------------------------
    sel <= '1';
    wait for 10 ns;
    assert s_mux = "11110000" report "Falha caso sel=1" severity error;

    --------------------------------------------------------------------
    -- Caso 3: trocar entradas e verificar novamente
    --------------------------------------------------------------------
    in_0 <= "00001111";
    in_1 <= "11000011";
    sel  <= '0';
    wait for 10 ns;
    assert s_mux = "00001111" report "Falha caso sel=0 troca entradas" severity error;

    sel <= '1';
    wait for 10 ns;
    assert s_mux = "11000011" report "Falha caso sel=1 troca entradas" severity error;

    wait;
  end process;

end architecture;
