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
end tb_ula;

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

  signal finished : std_logic := '0';

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

  clk <= not clk after 10 ns when finished /= '1' else '0';

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
    -- 3) AND: 10101010 AND 11110000 = 10100000
    --------------------------------------------------------------------
    entA <= "10101010";
    entB <= "11110000";

    ULAOp <= "10";
    funct <= "100100"; -- AND

    wait until pronto='0';
    wait for 10 ns;
    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';

    assert S0 = "10100000"
      report "AND falhou: esperado 10100000"

      severity error;
    --------------------------------------------------------------------
    -- 4) OR: 10101010 OR 11000011 = 11101011
    --------------------------------------------------------------------
    entA <= "10101010";
    entB <= "11000011";

    ULAOp <= "10";
    funct <= "100101"; -- OR

    wait until pronto='0';
    wait for 10 ns;
    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';

    assert S0 = "11101011"
      report "OR falhou: esperado 11101011" 
      severity error;

    --------------------------------------------------------------------
    -- 5) SLT (signed): 5 < 9 → 1
    --------------------------------------------------------------------
    entA <= std_logic_vector(to_signed(5, N));
    entB <= std_logic_vector(to_signed(9, N));

    ULAOp <= "10";
    funct <= "101010"; -- SLT

    wait until pronto='0';
    wait for 10 ns;
    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';

    assert S0 = std_logic_vector(to_unsigned(1, N))
      report "SLT falhou (caso A<B): esperado 1"
      severity error;

    --------------------------------------------------------------------
    -- 5b) SLT (signed): 10 < -3 → falso → 0
    --------------------------------------------------------------------
    entA <= std_logic_vector(to_signed(10, N));
    entB <= std_logic_vector(to_signed(-3, N));

    ULAOp <= "10";
    funct <= "101010"; -- SLT

    wait until pronto='0';
    wait for 10 ns;
    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';

    assert S0 = std_logic_vector(to_unsigned(0, N))
      report "SLT falhou (caso A>B): esperado 0"
      severity error;

    --------------------------------------------------------------------
    -- 6) MULT: 6 × 3 = 18  → S1:S0 = 16-bit result (para N=8)
    --------------------------------------------------------------------

    entA <= std_logic_vector(to_signed(6, entA'length));
    entB <= std_logic_vector(to_signed(3, entB'length));

    ULAOp <= "10";     
    funct <= "101011"; -- MULT

    wait until pronto='0';
    wait for 10 ns;
    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';

    -- resultado 18 decimal
    assert S0 = std_logic_vector(to_unsigned(18 mod 256, N))
      report "MULT S0 errado: esperado " & integer'image(18)
      severity error;

    assert S1 = std_logic_vector(to_unsigned(18 / 256, N))
      report "MULT S1 errado (parte alta)"
      severity error;

    --------------------------------------------------------------------
    -- 7) DIV: 4 / 8 = quociente 0, resto 4
    --------------------------------------------------------------------
    entA <= std_logic_vector(to_signed(4, entA'length));
    entB <= std_logic_vector(to_signed(8, entB'length));
    ULAOp <= "10";
    funct <= "100110";

    wait until pronto='0';
    wait for 10 ns;
    iniciar <= '1'; wait for 10 ns;
    iniciar <= '0';

    wait until pronto='1';

    assert S0 = std_logic_vector(to_unsigned(0, N))
      report "DIV quociente errado"
      severity error;

    assert S1 = std_logic_vector(to_unsigned(4, N))
      report "DIV resto errado"
      severity error;


    

    wait until pronto='0';
    wait for 10 ns;

    assert false report "Test done." severity note;
        finished <= '1';
    wait;
  end process;

end architecture;
