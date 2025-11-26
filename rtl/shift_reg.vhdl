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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_reg is
  generic (
    N : positive := 4 -- número de bits armazenados
  );
  port (
    clk, enable, sr, bit_in : in std_logic; -- clock (clk), carga (enable), shift right, bit de entrada quando o shift right estiver ativo
    d           : in std_logic_vector(N - 1 downto 0); -- dado de entrada
    q           : out std_logic_vector(N - 1 downto 0) := (others => '0'); -- dado armazenado
    bit_out     : out std_logic -- bit de saída quando shift right estiver ativo
  );
end shift_reg;

architecture behavior of shift_reg is
    signal q_int : std_logic_vector(N-1 downto 0) := (others => '0');
begin
    q <= q_int;

    process (clk)
    begin
        if rising_edge(clk) then
            -- default para bit_out quando não há shift
            bit_out <= '0';

            if enable = '1' then
                -- carga paralela
                q_int <= d;
            elsif sr = '1' then
                -- shift right: novo MSB recebe bit_in, LSB sai em bit_out
                bit_out <= q_int(0);
                -- concatena bit_in com os bits superiores para deslocar à direita
                q_int <= bit_in & q_int(N-1 downto 1);
            end if;
        end if;
    end process;
end architecture behavior;