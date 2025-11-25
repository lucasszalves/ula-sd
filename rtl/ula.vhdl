library ieee;
use ieee.std_logic_1164.all;
use work.ula_pack.all;
use ieee.numeric_std.all;

entity ula is
  generic (
    N : positive := 32
  );
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    iniciar : in std_logic;
    ULAOp   : in std_logic_vector(1 downto 0);
    funct   : in std_logic_vector(5 downto 0);
    entA    : in std_logic_vector(N - 1 downto 0);
    entB    : in std_logic_vector(N - 1 downto 0);
    pronto  : out std_logic;
    erro    : out std_logic;
    S0      : out std_logic_vector(N - 1 downto 0);
    S1      : out std_logic_vector(N - 1 downto 0)
  );
end entity ula;

architecture structure of ula is

  signal entradas_main : entradas_t(dados(entA(N - 1 downto 0), entB(N - 1 downto 0)));
  signal saidas_main   : saidas_t(dados(S0(N - 1 downto 0), S1(N - 1 downto 0)));
  signal comandos_main : bc_comandos;
  signal status_main   : status_bo;

begin

  --definindo os valores dos records com as entradas
  entradas_main.dados.entA        <= entA;
  entradas_main.dados.entB        <= entB;
  entradas_main.dados.entfunct    <= funct;
  entradas_main.dados.entULAOp    <= ULAOp;
  entradas_main.controles.iniciar <= iniciar;

  BC : entity work.ula_bc(behavior)
    port map
    (
      clk          => clk,
      rst_a        => reset,
      in_status    => status_main,
      in_controle  => entradas_main.controles,
      out_controle => saidas_main.controles,
      out_comandos => comandos_main
    );
  BO : entity work.ula_bo(structure)
    generic map(
      N => N
    )
    port map
    (
      clk           => clk,
      out_status    => status_main,
      in_operativo  => entradas_main.dados,
      out_operativo => saidas_main.dados,
      in_comandos   => comandos_main
    );

  --definindo os valores de saida usando os records
  pronto <= saidas_main.controles.pronto;
  erro   <= saidas_main.controles.erro;
  S0     <= saidas_main.dados.S0;
  S1     <= saidas_main.dados.S1;

end architecture structure;