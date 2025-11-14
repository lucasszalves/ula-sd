--------------------------------------------------
--	Author:      Renato Noskoski Kissel
--	Created:     Nov 14, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Contém a descrição de uma entidade para um registrador com controle
--               de carga (sinal enable). O registrador armazena valores sem sinal
--               de N bits na borda de subida do clock, desde que `enable` esteja
--               em nível lógico alto. 
--               As entradas e saídas utilizam o tipo `signed`.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Registrador parametrizável para N bits com controle de enable.
-- O registrador atualiza sua saída `q` com o valor da entrada `d` na borda de
-- subida do sinal `clk`, apenas quando `enable = '1'`.
entity signed_register is
  generic (
    N : positive := 4 -- número de bits armazenados
  );
  port (
    clk, enable : in std_logic; -- clock (clk) e carga (enable)
    d           : in signed(N - 1 downto 0); -- dado de entrada
    q           : out signed(N - 1 downto 0) -- dado armazenado
  );
end signed_register;

architecture behavior of signed_register is

begin
  process (clk)
  begin
    if (rising_edge(clk)) then
      if enable = '1' then
        q <= d;
      end if;
    end if;
  end process;

  -- Se enable = '1', o valor de d deve ser atribuído a q.
end architecture behavior;