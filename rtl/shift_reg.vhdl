--------------------------------------------------
--	Author:      Lucas Alves de Souza
--	Created:     Nov 19, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Contém a descrição de uma entidade para um registrador com controle
--               de carga (sinal enable). O registrador armazena valores com sinal
--               de N bits na borda de subida do clock, desde que `enable` esteja
--               em nível lógico alto. Também há entradas para fazer um shift right 
--               do registrador, tendo o bit de entrada à esquerda e o de saída à direita.
--               As entradas e saídas utilizam o tipo `std_logic_vector`, para que seja 
--               mais fácil o fatiamento de bits.
--  Tested:      Nov 20, 2025 by Lucas Alves de Souza
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Registrador parametrizável para N bits com controle de enable.
-- O registrador atualiza sua saída `q` com o valor da entrada `d` na borda de
-- subida do sinal `clk`, apenas quando `enable = '1'`.
entity shift_reg is
  generic (
    N : positive := 4 -- número de bits armazenados
  );
  port (
    clk, enable, sr, bit_in : in std_logic; -- clock (clk), carga (enable), shift right, bit de entrada quando o shift right estiver ativo
    d           : in std_logic_vector(N - 1 downto 0); -- dado de entrada
    q           : out std_logic_vector(N - 1 downto 0); -- dado armazenado
    bit_out : out std_logic -- bit de saída quando shift right estiver ativo
  );
end shift_reg;

architecture behavior of shift_reg is

begin
    process (clk)
        variable b_out_var, b_in_var : std_logic;
        variable to_shift : std_logic_vector(N - 3 downto 0);
    begin
        if (rising_edge(clk)) then
            if enable = '1' then  -- Se enable = '1', o valor de d deve ser atribuído a q.
                q <= d;
            elsif sr = '1' then   -- o shift right ocorre APENAS quando o enable for 0
                b_out_var := q(0);
                b_in_var := bit_in;
                to_shift := q(N - 2 downto 1); -- mantém o bit do sinal
                q(N - 3 downto 0) <= to_shift;
                q(N - 2) <= b_in_var;
                bit_out <= b_out_var;
            end if;
        end if;
    end process;

end architecture behavior;