library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flip_flop is
    port (
        clk   : in  std_logic;
        d     : in  std_logic; -- Entrada de dados
        q     : out std_logic  -- Saída
    );
end entity flip_flop;

architecture behavior of flip_flop is
begin

    process(clk, rst)
    begin
        if rising_edge(clk) then
            q <= d; -- A saída copia a entrada
        end if;
    end process;

end architecture behavior;
