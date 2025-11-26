--------------------------------------------------
--	Author:      Marco Antonio Colla
--	Created:     Nov 25, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Testbench principal para a ULA.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ula is
end entity;

architecture sim of tb_ula is

  constant N : integer := 8;

  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal iniciar : std_logic := '0';
  signal ULAOp   : std_logic_vector(1 downto 0) := (others => '0');
  signal funct   : std_logic_vector(5 downto 0) := (others => '0');
  signal entA    : std_logic_vector(N-1 downto 0) := (others => '0');
  signal entB    : std_logic_vector(N-1 downto 0) := (others => '0');

  signal pronto  : std_logic;
  signal erro    : std_logic;
  signal S0      : std_logic_vector(N-1 downto 0);
  signal S1      : std_logic_vector(N-1 downto 0);

begin

  

  DUT: entity work.ula(structure)
    generic map (N => N)
    port map (
      clk => clk,
      reset => reset,
      iniciar => iniciar,
      ULAOp => ULAOp,
      funct => funct,
      entA => entA,
      entB => entB,
      pronto => pronto,
      erro => erro,
      S0 => S0,
      S1 => S1
    );

    clk <= not clk after 10 ns;

  estimulos: process
  begin
    --------------------------------------------------------------------
    -- RESET
    --------------------------------------------------------------------
    reset <= '1';
    wait for 20 ns;
    reset <= '0';

    --------------------------------------------------------------------
    -- 1) ADD: 5 + 3 = 8
    --------------------------------------------------------------------
    entA <= std_logic_vector(to_signed(5, entA'length));
    entB <= std_logic_vector(to_signed(3, entB'length));
    ULAOp <= "10";
    funct <= "100000"; -- ADD

    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';
    

    assert S0 = std_logic_vector(to_unsigned(8, N))
      report "ADD falhou: esperado 8, obtido " & integer'image(to_integer(unsigned(S0)))
      severity error;

    --------------------------------------------------------------------
    -- 2) SUB: 9 - 2 = 7
    --------------------------------------------------------------------


    ULAOp <= "10";
    funct <= "100010"; -- SUB
    entA <= std_logic_vector(to_signed(9, entA'length));
    entB <= std_logic_vector(to_signed(2, entB'length));
    
    wait until pronto='0';
    wait for 10 ns;
    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';

    assert S0 = std_logic_vector(to_unsigned(7, N))
      report "SUB falhou: esperado 7, obtido " & integer'image(to_integer(unsigned(S0)))
      severity error;

    --------------------------------------------------------------------
    -- 3) MULT: 6 × 3 = 18  → S1:S0 = 16-bit result (para N=8)
    --------------------------------------------------------------------

    entA <= std_logic_vector(to_signed(6, entA'length));
    entB <= std_logic_vector(to_signed(3, entB'length));

    ULAOp <= "10";     -- ativa FSM
    funct <= "101001"; -- ignorado

    wait until pronto='0';
    wait for 10 ns;
    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';


    --------------------------------------------------------------------
    -- 4) DIV: 4 / 8 = quociente 0, resto 4
    --------------------------------------------------------------------
    entA <= std_logic_vector(to_signed(4, entA'length));
    entB <= std_logic_vector(to_signed(8, entB'length));
    ULAOp <= "10";
    funct <= "001100";

    wait until pronto='0';
    wait for 10 ns;
    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';



    wait;
  end process;

end architecture;
