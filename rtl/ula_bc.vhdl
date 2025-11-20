--------------------------------------------------
--	Author:		Stella Silva Weege
--	Created:     	November 16, 2025
--
--	Project:     	Atividade Prática 3
--	Description: 	ADD DESCRIPTION
--------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.ula_pack.all;

-- Bloco de Controle (BC) da ULA.
-- Responsável por gerar os sinais de controle para o bloco operativo (BO),
-- por meio de uma FSM.
entity ula_bc is
  port (
    clk          : in std_logic; -- clock (sinal de relógio)
    rst_a        : in std_logic; -- reset assíncrono ativo em nível alto
    in_controle  : in bc_entradas;
    in_status    : in status_bo;
    out_controle : out bc_saidas;
    out_comandos : out bc_comandos);
end entity ula_bc;

architecture behavior of ula_bc is
  type state is (INIT, LOAD, SLT, S_OR, S_AND, SUB, AD, MULT1, MULT2, MULT3, MULT4, MULT5, MULT6, DIV1, DIV2, DIV3, DIV4, ERRO, PRONTO); -- definição dos estados
  signal current_state, next_state : state; -- sinais para armazenar o estado atual e o próximo estado
begin
  -- Process para avaliar se o próximo estado receberá INIT (sempre que o reset assíncrono estiver ativado) ou o próximo estado (somente na subida do relógio e se o reset estiver desativado)
  reg_state : process (clk, rst_a)
  begin
    if rst_a = '1' then
      current_state <= INIT;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process reg_state;

  -- Process para avaliar qual será o próximo estado, de acordo com os sinais de controle e status (em alguns estados)
  lpe : process (current_state, in_controle, in_status)
  begin
    case current_state is
      when INIT =>
        if in_controle.iniciar = '1' then
          next_state <= LOAD;
        elsif in_controle.iniciar = '0' then
          next_state <= INIT;
        end if;
      when LOAD =>
        if in_status.C = "000" then
          next_state <= S_AND;
        elsif in_status.C = "001" then
          next_state <= S_OR;
        elsif in_status.C = "010" then
          next_state <= AD;
        elsif in_status.C = "011" then
          next_state <= MULT1;
        elsif in_status.C = "100" then
          next_state <= DIV1;
        elsif in_status.C = "110" then
          next_state <= SUB;
        elsif in_status.C = "111" then
          next_state <= SLT;
        elsif ((in_status.C = "100" and (in_status.Amz = '1' or in_status.Bmz = '1' or in_status.Bz = '1')) or (in_status.C = "011" and (in_status.Amz = '1' or in_status.Bmz = '1'))) then
          next_state <= ERRO;
        end if;
      when SLT =>
        next_state <= PRONTO;
      when S_OR =>
        next_state <= PRONTO;
      when S_AND =>
        next_state <= PRONTO;
      when AD =>
        if in_status.OV = '0' then
          next_state <= PRONTO;
        elsif in_status.OV = '1' then
          next_state <= ERRO;
        end if;
      when SUB =>
        if in_status.OV = '0' then
          next_state <= PRONTO;
        elsif in_status.OV = '1' then
          next_state <= ERRO;
        end if;
      when MULT1 =>
        next_state <= MULT2;
      when MULT2 =>
        if (in_status.Az = '1') or (in_status.Bz = '1') then
          next_state <= MULT6;
        elsif (in_status.Az = '0') and (in_status.Bz = '0') then
          next_state <= MULT3;
        end if;
      when MULT3 =>
        if (in_status.countz = '1') then
          next_state <= MULT6;
        elsif (in_status.countz = '0') and (in_status.A_0 = '1') then
          next_state <= MULT4;
        elsif (in_status.countz = '0') and (in_status.A_0 = '0') then
          next_state <= MULT5;
        end if;
      when MULT4 =>
        next_state <= MULT5;
      when MULT5 =>
        next_state <= MULT3;
      when MULT6 =>
        next_state <= PRONTO;
      when DIV1 =>
        if (in_status.Az = '1') then
          next_state <= DIV4;
        elsif (in_status.Az = '0') then
          next_state <= DIV2;
        end if;
      when DIV2 =>
        if (in_status.AmqB = '1') then
          next_state <= DIV4;
        elsif (in_status.AmqB = '0') then
          next_state <= DIV3;
        end if;
      when DIV3 =>
        next_state <= DIV2;
      when DIV4 =>
        next_state <= PRONTO;
      when ERRO =>
        next_state <= INIT;
      when PRONTO =>
        next_state <= INIT;
    end case;
  end process lpe;

  -- Process para gerar as saídas (como é máquina de Moore, as saídas só dependem do estado atual)
  ls : process (current_state)
  begin
    case current_state is
      when INIT =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when LOAD =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '1';
        out_comandos.cA     <= '1';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '1';
        out_comandos.cfunct <= '1';
      when SLT =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '1';
        out_comandos.cS0    <= '1';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when S_OR =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '1';
        out_comandos.cS0    <= '1';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when S_AND =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '1';
        out_comandos.cS0    <= '1';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when AD =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '1';
        out_comandos.cS0    <= '1';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when SUB =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '1';
        out_comandos.cS0    <= '1';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when MULT1 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '1';
        out_comandos.ccount <= '1';
        out_comandos.mPH_Q  <= '1';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '1';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '1';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when MULT2 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when MULT3 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when MULT4 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '0';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '1';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '0';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when MULT5 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '1';
        out_comandos.mcount <= '0';
        out_comandos.ccount <= '1';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '1';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '1';
        out_comandos.cPL    <= '1';
        out_comandos.mFF    <= '0';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when MULT6 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '0';
        out_comandos.cS0    <= '1';
        out_comandos.cS1    <= '1';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when DIV1 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '1';
        out_comandos.ccount <= '1';
        out_comandos.mPH_Q  <= '1';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '1';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when DIV2 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when DIV3 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '1';
        out_comandos.ccount <= '1';
        out_comandos.mPH_Q  <= '0';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '1';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when DIV4 =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '0';
        out_comandos.cS0    <= '1';
        out_comandos.cS1    <= '1';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when PRONTO =>
        out_controle.pronto <= '1';
        out_controle.erro   <= '0';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
      when ERRO =>
        out_controle.pronto <= '0';
        out_controle.erro   <= '1';
        out_comandos.cB     <= '0';
        out_comandos.cA     <= '0';
        out_comandos.sr_A   <= '0';
        out_comandos.mcount <= '-';
        out_comandos.ccount <= '0';
        out_comandos.mPH_Q  <= '-';
        out_comandos.srPH_Q <= '0';
        out_comandos.cPH_Q  <= '0';
        out_comandos.srPL   <= '0';
        out_comandos.cPL    <= '0';
        out_comandos.mFF    <= '-';
        out_comandos.m10    <= '-';
        out_comandos.cS0    <= '0';
        out_comandos.cS1    <= '0';
        out_comandos.cULAop <= '0';
        out_comandos.cfunct <= '0';
    end case;
  end process ls;
end architecture behavior;
