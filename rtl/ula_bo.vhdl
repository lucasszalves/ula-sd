--------------------------------------------------
--	Author:		Stella Silva Weege, Renato Noskoski Kissel, Maria Eduarda de Oliveira Zuquetto
--	Created:     	November 16, 2025
--
--	Project:     	Atividade Prática 3
--	Description: 	Bloco Operativo (BO) da ULA.
--                  Responsável por fazer o processamento dos dados, cálculos e
--                  gerar os sinais de status para o Bloco de Controle (BC)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.ula_pack.all;
use ieee.numeric_std.all;

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
  signal c0, c1, c2 : std_logic;
  signal c_internal : std_logic_vector(2 downto 0);
  signal result_and_or, result_mux1, ent1_mux2, result_mux2 : std_logic_vector(N - 1 downto 0);
  --renato signal´s
  signal result_mux6, result_mux7, count_r, result_mux8, result_count_r_less : std_logic_vector(N - 1 downto 0);
  signal ULAop : std_logic_vector (1 downto 0);
  signal funct : std_logic_vector (5 downto 0);
  signal result_mux3, result_mux4, result_mux5, result_mux9, result_mux10, result_soma_P : std_logic_vector(N - 1 downto 0);

  signal PH_Q : std_logic_vector(N-1 downto 0) := (others => '0');
  signal PL   : std_logic_vector(N-1 downto 0) := (others => '0');
  
  signal result_muxFF, cout_soma_P, out_FF : std_logic;

  signal result_add_sub : std_logic_vector(N - 1 downto 0) := (others => '0');
  signal OV_xor_N : std_logic := '0';


  constant one : std_logic_vector(N - 1 downto 0) := std_logic_vector(to_unsigned(1, N));
  constant zero : std_logic_vector(N - 1 downto 0) := (others => '0');
  signal bit_in_PL : std_logic := '0';
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
    -- TODO !!!!!!!! 

  proc_c : process(ULAOp, funct)
  begin
    case ULAOp is
        when "00" =>
            c_internal <= "010";
        when "01" =>
            c_internal <= "110";
        when "10" =>
            case funct is
                when "100000" => 
                    c_internal <= "010";
                when "100010" => 
                    c_internal <= "110";
                when "100100" => 
                    c_internal <= "000";
                when "100101" => 
                    c_internal <= "001";
                when "101010" => 
                    c_internal <= "111";
                when "101011" => 
                    c_internal <= "011";
                when "100110" => 
                    c_internal <= "100";


                when others =>
                    c_internal <= "010";
            end case;
          when others =>
            c_internal <= "010";
    end case;
  end process proc_c;
            
  c0 <= c_internal(0);
  c1 <= c_internal(1);
  c2 <= c_internal(2);
  out_status.c <= c_internal;

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

  -- mux1 (seleciona o resultado do and/or ou da soma/subtração)
  mux_1 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c1,
      in_0  => result_and_or,
      in_1  => result_add_sub,
      s_mux => result_mux1);

  -- entrada 1 de mux2
  OV_xor_N <= out_status.OV xor result_add_sub(result_add_sub'high);

  ent1_mux2 <= (0 => OV_xor_N, others => '0');

  -- mux2 (seleciona o resultado do SLT ou da soma/subtração/and/or)
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
  out_status.Az <= '1' when A = zero else '0';

  -- mux6 (seleciona o contador da multiplicação ou o A, que deverá subtrair na divisão)
  mux_6 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c0,
      in_0  => A,
      in_1  => std_logic_vector(to_unsigned(N, N)),
      s_mux => result_mux6);

  -- mux7 (seleciona o resultado da última subtração da divisão ou a saída de mux6)
  mux_7 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => in_comandos.mcount,
      in_0  => result_count_r_less,
      in_1  => result_mux6,
      s_mux => result_mux7);

  -- registrador que guarda a saída do mux7
  reg_count_r : entity work.std_logic_register(behavior)
    generic map(
      N => N)
    port map
    (
      clk    => clk,
      enable => in_comandos.ccount,
      d      => result_mux7,
      q      => count_r);

  --signal count_r == 0?
  out_status.countz <= '1' when unsigned(count_r) = 0 else '0';

  -- mux8 (seleciona entre B (para a divisão) e 1 (para o contador da multiplicação))
  mux_8 : entity work.mux_2to1(behavior)
    generic map(
      N => N)
    port map
    (
      sel   => c0,
      in_0  => B,
      in_1 => one,
      s_mux => result_mux8);

  -- bloco subtrator exclusivo
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

  -- bloco que verifica se A < B (na prática, utiliza um subtrator e verifica se a subtração foi menor que zero ou deu overflow)
  count_lessth_B: entity work.count_less_than_B(behavior)
  generic map(
      N => N)
    port map
    (
    input_a => count_r,
    input_b  => B,
    result    => out_status.AmqB);


    -------------------------PARTE DO MEIO FINALIZADA---------------------------

    out_status.Bz <= '1' when B = zero else '0';

    -- mux3 (seleciona entre 1 (contador do quociente da divisão) e o B (somado na multiplicação))
    mux_3 : entity work.mux_2to1(behavior)
        generic map(
        N => N)
        port map
        (
        sel   => c0,
        in_0  => one,
        in_1 => B,
        s_mux => result_mux3);

    --mux4 (seleciona entre o resultado do somador e zero)
    mux_4 : entity work.mux_2to1(behavior)
        generic map(
        N => N)
        port map
        (
        sel   => in_comandos.mPH_Q,
        in_0  => result_soma_P,
        in_1 => zero,
        s_mux => result_mux4);

    -- mux5 (seleciona a parte baixa da multiplicação ou o quociente da divisão)
    mux_5 : entity work.mux_2to1(behavior)
        generic map(
        N => N)
        port map
        (
        sel   => c2,
        in_0  => PL,
        in_1 => PH_Q,
        s_mux => result_mux5);

    -- mux9 (seleciona a parte alta da multiplicação ou o resto da divisão)
    mux_9 : entity work.mux_2to1(behavior)
        generic map(
        N => N)
        port map
        (
        sel   => c0,
        in_0  => count_r,
        in_1 => PH_Q,
        s_mux => result_mux9);

    -- mux10 (seleciona a saída do mux5 (para operações de mult ou div) ou a saída do mux2 (add/sub/and/or/stl))
    mux_10 : entity work.mux_2to1(behavior)
        generic map(
        N => N)
        port map
        (
        sel   => in_comandos.m10,
        in_0  => result_mux5,
        in_1 => result_mux2,
        s_mux => result_mux10);
    
    -- muxFF (seleciona o carry out da soma, no caso da multiplicação, se ocorrer, e apenas no estado necessário (MULT4))
    mux_FF : entity work.mux_1bit(rtl)
    port map(
        sel   => in_comandos.mFF,
        in_0  => cout_soma_P,
        in_1  => '0',
        s_mux => result_muxFF
    );

    -- bloco somador exclusivo (soma a parte alta da multiplicação com B ou incrementa o contador do quociente)
    somador_P : entity work.adder(behavior)
        generic map (
                N => N)
        port map (
            input_a => result_mux3,
            input_b => PH_Q,
            result => result_soma_P,
            carry_out => cout_soma_P,
            overflow  => open);

    -- flip flop que guarda a saída do muxFF
    flip_flop_FF : entity work.flip_flop(behavior)
        port map(
                clk => clk,
                d => result_muxFF,
                q => out_FF);

    -- registrador que guarda a saída do mux4, que pode ser a parte alta da multiplicação (PH) ou o quociente da divisão (Q)
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

    -- registrador que guarda a parte baixa da multiplicação
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

    -- registrador que guarda o a saída do mux10
    reg_S0 : entity work.std_logic_register(behavior)
        generic map(
        N => N)
        port map
        (
        clk    => clk,
        enable => in_comandos.cS0,
        d      => result_mux10,
        q      => out_operativo.S0);

    -- registrador que guarda o a saída do mux9
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
