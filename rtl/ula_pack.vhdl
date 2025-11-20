--------------------------------------------------
--	Author:		Stella Silva Weege
--	Created:	November 10, 2025
--
--	Project:	Atividade Prática 3
--	Description: Contém records para agrupar os sinais que:
--			- entram na ULA
--			- saem da ULA
--			- entram no BO
--			- saem do BO
--			- entram no BC
--			- saem do BC
--			- saem do BC e entram no BO (comandos)
--			- saem do BO e entram no BC (status)
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package ula_pack is

  -- Tipo que armazena as entradas do Bloco Operacional
  -- entA: primeiro operando de n bits
  -- entB: segundo operando de n bits
  -- entfunct: campo funct da instrução do MIPS
  -- entULAOp: saída do controle do MIPS
  -- A e B são deixados genéricos (sem definição de tamanho) normalmente, mas para a síntese no quartus será preciso definir o tamanho
  -- Original:	entA: std_logic_vector;
  --			entB: std_logic_vector;
  --		        entfunct: std_logic_vector(5 downto 0);
  --		        entULAOp: std_logic_vector(1 downto 0);
  type bo_entradas is record
    entA     : std_logic_vector;
    entB     : std_logic_vector;
    entfunct : std_logic_vector(5 downto 0);
    entULAOp : std_logic_vector(1 downto 0);
  end record bo_entradas;

  -- Tipo que armazena as saídas do Bloco Operacional
  -- S0: registrador de n bits que armazena (as saídas das operações usuais da ULA)/(a parte baixa do resultado da multiplicação)/(o quociente da divisão)
  -- S1: registrador de n bits que armazena (a parte alta do resultado da multiplicação)/(o resto da divisão)
  -- São deixados genéricos (sem definição de tamanho) normalmente, mas para a síntese no quartus será preciso definir o tamanho
  -- Original: 	S0: std_logic_vector;
  --		    	S1: std_logic_vector;
  type bo_saidas is record
    S0 : std_logic_vector;
    S1 : std_logic_vector;
  end record bo_saidas;

  -- Tipo que armazena as entradas do Bloco de Controle
  -- iniciar: comanda início do cálculo
  -- reset: reset assíncrono
  type bc_entradas is record
    iniciar : std_logic;
    reset   : std_logic;
  end record bc_entradas;

  -- Tipo que armazena as saídas do Bloco de Controle
  -- pronto: sinaliza o fim do cálculo com sucesso
  -- erro: sinaliza a ocorrência de erros durante o cálculo
  type bc_saidas is record
    pronto : std_logic;
    erro   : std_logic;
  end record bc_saidas;

  -- Tipo que armazena as entradas do Bloco de Controle e do Bloco Operacional
  -- dados: entradas do Bloco Operacional (bo_entradas)
  -- controles: entradas do Bloco de Controle (bc_entradas)
  type entradas_t is record
    dados     : bo_entradas;
    controles : bc_entradas;
  end record entradas_t;

  -- Tipo que armazena as saídas do Bloco de Controle e do Bloco Operacional
  -- dados: saídas do Bloco Operacional (bo_saidas)
  -- controles: saídas do Bloco de Controle (bc_saidas)
  type saidas_t is record
    dados     : bo_saidas;
    controles : bc_saidas;
  end record saidas_t;

  -- Tipo que armazena os comandos que saem do Bloco de Controle e vão para o Bloco Operacional
  -- cfunct: charge do registrador funct
  -- cULAOp: charge do registrador ULAOp
  -- cA: charge do registrador A
  -- sr_A: sinal de shift right do registrador A
  -- cB: charge do registrador B
  -- mcount_r: seletor do mux M7
  -- ccount: charge do registrador count
  -- mPH_Q: seletor do mux M4
  -- srPH_Q: sinal de shift right do registrador PH_Q
  -- cPH_Q: charge do registrador PH_Q
  -- srPL: sinal de shift right do registrador PL
  -- cPL: charge do registrador PL
  -- mFF: seletor do mux MFF
  -- m10: seletor do mux M10
  type bc_comandos is record
    cfunct : std_logic;
    cULAOp : std_logic;
    cA     : std_logic;
    sr_A   : std_logic;
    cB     : std_logic;
    mcount : std_logic;
    ccount : std_logic;
    mPH_Q  : std_logic;
    srPH_Q : std_logic;
    cPH_Q  : std_logic;
    srPL   : std_logic;
    cPL    : std_logic;
    mFF    : std_logic;
    m10    : std_logic;
    cS0    : std_logic;
    cS1    : std_logic;
  end record bc_comandos;

  -- Tipo que armazena os status que saem do Bloco Operacional e vão para o Bloco de Controle
  -- C: sinal cujos bits e suas combinações (and/or) são usados como seletor para diversos mux
  -- Amz: A menor do que 0
  -- Bmz: B menor do que 0
  -- Az: A igual a 0
  -- Bz: B igual a 0
  -- AmqB: A menor do que B
  -- countz: count igual a 0
  -- Overflow: ocorrência de overflow no somador/subtrator
  -- A_0: bit menos significativo de A (utilizado na multiplicação)
  type status_bo is record
    C      : std_logic_vector(2 downto 0);
    Amz    : std_logic;
    Bmz    : std_logic;
    Az     : std_logic;
    Bz     : std_logic;
    AmqB   : std_logic;
    countz : std_logic;
    OV     : std_logic;
    A_0    : std_logic;
  end record status_bo;

end package ula_pack;
