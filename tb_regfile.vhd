
-- Testbench for regfile
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_regfile IS
END tb_regfile;

ARCHITECTURE sim OF tb_regfile IS
    SIGNAL read_sel1, read_sel2, write_sel : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
    SIGNAL write_data, data1, data2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL write_ena : STD_LOGIC := '0';
    SIGNAL clk : STD_LOGIC := '0';
BEGIN
    uut: ENTITY work.regfile PORT MAP (read_sel1, read_sel2, write_sel, write_data, write_ena, clk,
                                       data1, data2);

    clk <= NOT clk AFTER 5 ns;

    stim: PROCESS
        PROCEDURE do_write(r : STD_LOGIC_VECTOR(4 DOWNTO 0); d : STD_LOGIC_VECTOR(31 DOWNTO 0)) IS
        BEGIN
            write_sel <= r; write_data <= d;
            write_ena <= '1'; WAIT UNTIL rising_edge(clk);
            WAIT FOR 1 ns;
            write_ena <= '0'; WAIT FOR 9 ns;
        END PROCEDURE;
    BEGIN
        do_write("01000", X"0000000A");   -- $t0 = 10
        do_write("01001", X"00000014");   -- $t1 = 20
        do_write("00000", X"FFFFFFFF");   -- $zero stays 0

        read_sel1 <= "01000"; read_sel2 <= "01001"; WAIT FOR 1 ns;
        ASSERT data1 = X"0000000A" AND data2 = X"00000014"
            REPORT "reading $t0/$t1 failed" SEVERITY ERROR;

        read_sel1 <= "00000"; WAIT FOR 1 ns;
        ASSERT data1 = X"00000000" REPORT "$zero must stay 0" SEVERITY ERROR;

        REPORT "All Register File tests passed!" SEVERITY NOTE;
        WAIT;
    END PROCESS;
END sim;
