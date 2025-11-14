--------------------------------------------------
--	Author:      Renato Noskoski Kissel
--	Created:     Nov 14, 2025
--
--	Project:     Atividade Prática 3 - ULA
--	Description: Contém a descrição de uma entidade para um full adder, expressando
--               seu circuito lógico.
--------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;
entity full_adder is
  port (
    A    : in std_logic;
    B    : in std_logic;
    Cin  : in std_logic;
    S    : out std_logic;
    Cout : out std_logic
  );

end full_adder;
architecture circuito_logico of full_adder is
begin
  S    <= (A xor B) xor Cin;
  Cout <= ((A xor B) and Cin) or (A and B);
end circuito_logico;