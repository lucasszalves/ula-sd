library ieee;
use ieee.std_logic_1164.all;

entity mux_1bit is
    port (
        sel   : in  std_logic;
        in_0  : in  std_logic;
        in_1  : in  std_logic;
        s_mux : out std_logic
    );
end entity;

architecture rtl of mux_1bit is
begin
    s_mux <= in_0 when sel = '0' else in_1;
end architecture;
