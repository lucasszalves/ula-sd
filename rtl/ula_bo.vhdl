library ieee;
use ieee.std_logic_1164.all;
use work.ula_pack.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

-- Bloco de Controle (BC) da ULA.
-- Responsável por gerar os sinais de controle para o bloco operativo (BO),
-- por meio de uma FSM.
entity ula_bo is
  generic (
    N : positive := 8
  );
  port (
    clk           : in std_logic; -- clock (sinal de relógio)
    in_operativo  : in bo_entradas;
    in_comandos   : in bc_comandos;
    out_status    : out status_bo;
    out_operativo : out bo_saidas);
end entity ula_bo;

architecture structure of ula_bo is
  signal A, B : std_logic_vector(N - 1 downto 0);
  --madu signal's
  signal c0, c1, c2, OV_xor_N : std_logic;
  signal result_add_sub, result_and_or, result_mux1, ent1_mux2, result_mux2 : std_logic_vector(N - 1 downto 0);
  --renato signal´s
  signal result_mux6, result_mux7, count_r, result_mux8, result_count_r_less : std_logic_vector(N - 1 downto 0);
begin

-------------------------PARTE DA MADU FINALIZADA---------------------------

  -- lógica para gerar C
  c0 <= in_operativo.entULAOp(0) or (in_operativo.entULAOp(1) and in_operativo.entfunct(1));
  c1 <= not(in_operativo.entULAOp(1)) or not(in_operativo.entfunct(2));
  c2 <= in_operativo.entULAOp(1) and (in_operativo.entfunct(3) or in_operativo.entfunct(0));
  out_status.c <= c2 & (c1 & c0);

  -- registrador para passar A
  reg_A : entity work.shift_reg(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      sr => in_comandos.sr_A,
      bit_in => '0', 
      enable => in_comandos.cA, 
      d      => in_operativo.entA,
      q      => A,
      bit_out => open);

  -- registrador para passar B
  reg_B : entity work.std_logic_register(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      enable => in_comandos.cB,
      d      => in_operativo.entB,
      q      => B);

  -- sinais de status Amz e Bmz
  out_status.Amz <= A(high(A));
  out_status.Bmz <= B(high(B));
  
  -- bloco somador/subtrator
  add_sub : entity work.adder_subtractor(behavior)
    generic map(
      N => N)
    port map
    (
      input_a  => A,
      input_b  => B,
      CS       => c2,
      overflow => out_status.OV,
      result   => result_add_sub);

  -- bloco and/or
  and_or : entity work.and_or(behavior)
    generic map(
      N => N)
    port map
    (
      input_a  => A,
      input_b  => B,
      CAO      => c0,
      result   => result_and_or);

  -- mux1
  mux_1 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c1,
      in_0  => result_and_or,
      in_1  => result_add_sub,
      s_mux => result_mux1);

  -- mux2 (e entrada 1 de mux2)
  OV_xor_N <= out_status.OV xor result_add_sub(high(result_add_sub));
  ent1_mux2 <= std_logic_vector(resize(unsigned(OV_xor_N), N));

  mux_2 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => (c1 and c0),
      in_0  => result_mux1,
      in_1  => ent1_mux2,
      s_mux => result_mux2);



  -------------------------PARTE DO RENATO FINALIZADA---------------------------

  --signals A(0) e A==0?
  out_status.A_0 <= A(0);
  out_status.Az <= '1' when unsigned(count_r) = 0 else '0';

  mux_6 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c0,
      in_0  => A,
      in_1  => std_logic_vector(to_unsigned(N, N)),
      s_mux => result_mux6);

  mux_7 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => in_comandos.mcount,
      in_0  => result_count_r_less,
      in_1  => std_logic_vector(to_unsigned(N, N)),
      s_mux => result_mux7);

  reg_count_r : entity work.std_logic_register(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      enable => in_comandos.ccount,
      d      => result_mux7,
      q      => count_r);

  --signal count == 0?
  out_status.countz <= '1' when unsigned(count_r) = 0 else '0';

  mux_8 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c0,
      in_0  => B,
      in_1 => (0 => '1', others => '0'),
      s_mux => result_mux8);

  sub: entity work.subtractor(behavior)
  generic map(
      N => N)
    port map
    (
    input_a => count_r,
    input_b  => result_mux8,
    result    => result_count_r_less,
    carry_out => open,
    overflow => open);

  count_less_than_B: entity work.count_less_than_B(behavior)
  generic map(
      N => N)
    port map
    (
    input_a => count_r,
    input_b  => B,
    result    => out_status.AmqB);


  -- Lucas

  --Lucas, o sinal que entra em M9 entrada 0 se chama "count_r". ass: Renato
end architecture structure;