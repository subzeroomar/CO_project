-- 32-bit ALU
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY alu32 IS
    PORT ( data1, data2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
           aluop : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
           zflag : OUT STD_LOGIC;
           dataout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
END alu32;

ARCHITECTURE synth OF alu32 IS
    SIGNAL S, BB : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    BB <= (NOT data2) WHEN (aluop(3 DOWNTO 2) = "11" OR aluop = "0110");
    S <= data1 + BB + '1' WHEN (aluop = "0110" OR aluop = "0111")
         ELSE data1 + data2;

    dataout <= data1 AND data2 WHEN aluop = "0000" ELSE
               data1 OR data2 WHEN aluop = "0001" ELSE
               S WHEN aluop = "0010" OR aluop = "0110" ELSE
               data1 NOR data2 WHEN aluop = "1100" ELSE
               ("0000000000000000000000000000000" & S(31)) WHEN aluop = "0111" ELSE
               X"00000000";

    zflag <= '1' WHEN S = X"00000000" ELSE '0';

END synth;
