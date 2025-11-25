library ieee;
use ieee.std_logic_1164.all;
use work.ula_pack.all;
use ieee.numeric_std.all;

-- Bloco Operacional (BO) da ULA.
-- Responsável por *COMPLETAR*,
-- por meio de *COMPLETAR*.
entity ula_bo is
  generic (
    N : positive := 32
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
  signal ULAop : std_logic_vector (1 downto 0);
  signal funct : std_logic_vector (5 downto 0);
  signal result_mux3, result_mux4, result_mux5, result_mux9, result_mux10, result_soma_P, PH_Q, PL, um, zero : std_logic_vector(N - 1 downto 0);
  signal result_muxFF, carry_out_soma_P, out_FF : std_logic;
begin

-------------------------PARTE DA MADU FINALIZADA---------------------------
  
  -- registrador para passar funct
  reg_funct : entity work.std_logic_register(behavior)
    generic map(
      N => 6)
    port map
    (
      clk    => clk,
      enable => in_comandos.cfunct,
      d      => in_operativo.entfunct,
      q      => funct);
      
  -- registrador para passar ULAOp
  reg_ULAOp : entity work.std_logic_register(behavior)
    generic map(
      N => 2)
    port map
    (
      clk    => clk,
      enable => in_comandos.cULAOp,
      d      => in_operativo.entULAOp,
      q      => ULAOp);

  -- lógica para gerar C
  c0 <= ULAOp(0) or (ULAOp(1) and funct(1));
  c1 <= not(ULAOp(1)) or not(funct(2));
  c2 <= ULAOp(1) and (funct(3) or funct(0));
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
  out_status.Amz <= A(A'high);
  out_status.Bmz <= B(B'high);
  
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
  OV_xor_N <= out_status.OV xor result_add_sub(result_add_sub'high);
  ent1_mux2 <= (others => OV_xor_N);

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
  out_status.Az <= '1' when unsigned(A) = 0 else '0';

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


    -------------------------PARTE DO MEIO FINALIZADA---------------------------

one <= std_logic_vector(resize(unsigned("1"), N);
zero <= std_logic_vector(resize(unsigned("0"), N);

out_status.Bz <= '1' when unsigned(B) = 0 else '0';

mux_3 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c0,
      in_0  => (0 => '1', others => '0'),
      in_1 => B,
      s_mux => result_mux3);

mux_4 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => in_comandos.mPH_Q,
      in_0  => result_soma_P,
      in_1 => (others => '0'),
      s_mux => result_mux4);

mux_5 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c2,
      in_0  => PL,
      in_1 => PH_Q,
      s_mux => result_mux5);

mux_9 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c0,
      in_0  => count_r,
      in_1 => PH_Q,
      s_mux => result_mux9);

mux_10 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => in_comandos.m10,
      in_0  => result_mux5,
      in_1 => result_mux2,
      s_mux => result_mux10);

mux_FF : entity work.mux_2to1(behavior)
    generic map(
      N => 1)
    port map
    (
      sel   => in_comandos.mFF,
      in_0  => cout_soma_P,
      in_1 => "0",
      s_mux => result_muxFF);
      
somador_P : entity work.adder(behavior)
	generic map (
    		N => N)
	port map (
	    input_a => result_mux3,
	    input_b => PH_Q,
	    result => result_soma_P,
	    carry_out => cout_soma_P,
	    overflow  => open);

flip_flop_FF : entity work.flip_flop(behavior)
	port map(
            clk => clk,
            d => result_muxFF,
            q => out_FF);

reg_PH_Q : entity work.shift_reg(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      sr => in_comandos.srPH_Q,
      bit_in => out_FF, 
      enable => in_comandos.cPH_Q, 
      d      => result_mux4,
      q      => PH_Q,
      bit_out => bit_in_PL);

reg_PL : entity work.shift_reg(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      sr => in_comandos.srPL,
      bit_in => bit_in_PL, 
      enable => in_comandos.cPL, 
      d      => zero,
      q      => PL,
      bit_out => open);

reg_S0 : entity work.std_logic_register(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      enable => in_comandos.cS0,
      d      => result_mux10,
      q      => out_operativo.S0);

reg_S1 : entity work.std_logic_register(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      enable => in_comandos.cS1,
      d      => result_mux9,
      q      => out_operativo.S1);

end architecture structure;
