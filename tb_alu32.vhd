-- Testbench for alu32
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_alu32 IS
END tb_alu32;

ARCHITECTURE sim OF tb_alu32 IS
    SIGNAL data1, data2, dataout : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL aluop : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL zflag : STD_LOGIC;
BEGIN
    uut: ENTITY work.alu32 PORT MAP (data1, data2, aluop, zflag, dataout);

    stim: PROCESS
    BEGIN
        data1 <= X"0000000C"; data2 <= X"0000000A";

        aluop <= "0000"; WAIT FOR 100 ns;
        ASSERT dataout = X"00000008" REPORT "AND failed" SEVERITY ERROR;

        aluop <= "0001"; WAIT FOR 100 ns;
        ASSERT dataout = X"0000000E" REPORT "OR failed" SEVERITY ERROR;

        aluop <= "0010"; WAIT FOR 100 ns;
        ASSERT dataout = X"00000016" REPORT "ADD failed" SEVERITY ERROR;

        aluop <= "0110"; WAIT FOR 100 ns;
        ASSERT dataout = X"00000002" REPORT "SUB failed" SEVERITY ERROR;

        aluop <= "0111"; WAIT FOR 100 ns;
        ASSERT dataout = X"00000000" REPORT "SLT (12<10) failed" SEVERITY ERROR;

        data1 <= X"00000003";
        aluop <= "0111"; WAIT FOR 100 ns;
        ASSERT dataout = X"00000001" REPORT "SLT (3<10) failed" SEVERITY ERROR;

        data1 <= X"0000000C"; data2 <= X"0000000A";
        aluop <= "1100"; WAIT FOR 100 ns;
        ASSERT dataout = X"FFFFFFF1" REPORT "NOR failed" SEVERITY ERROR;

        WAIT;
    END PROCESS;
END sim;