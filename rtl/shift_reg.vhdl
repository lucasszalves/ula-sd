library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_reg is
    generic (
        N : positive := 4 
    );
    port (
        clk     : in std_logic;
        enable  : in std_logic; -- Carga paralela
        sr      : in std_logic; -- Shift Right
        bit_in  : in std_logic; -- Bit que entra no shift
        d       : in std_logic_vector(N - 1 downto 0);
        q       : out std_logic_vector(N - 1 downto 0);
        bit_out : out std_logic
    );
end shift_reg;

architecture behavior of shift_reg is
    -- Sinal interno para ler e escrever (o "espelho" da saída)
    signal r_reg : std_logic_vector(N - 1 downto 0) := (others => '0');
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                -- Carga Paralela (Load)
                r_reg <= d; 
            
            elsif sr = '1' then
                -- SHIFT RIGHT ARITMÉTICO (Preserva o sinal/MSB)
                -- O bit N-1 fica igual.
                -- O bit N-2 recebe o bit_in.
                -- O resto desloca para a direita.
                
                -- Exemplo N=4: r_reg(3) & bit_in & r_reg(2) & r_reg(1) -> r_reg(0) cai fora
                r_reg <= bit_in & r_reg(N - 1 downto 1);
            end if;
        end if;
    end process;

    -- Atribuição contínua para as saídas
    q       <= r_reg;
    bit_out <= r_reg(0); -- O bit que "cai" para fora

end architecture behavior;