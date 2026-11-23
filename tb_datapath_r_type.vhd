LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_datapath_r_type IS
END tb_datapath_r_type;

ARCHITECTURE sim OF tb_datapath_r_type IS
    SIGNAL clk          : STD_LOGIC := '0';
    SIGNAL reset        : STD_LOGIC := '0';
    SIGNAL instr        : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL zero         : STD_LOGIC;
    SIGNAL aluoperation : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL regwrite     : STD_LOGIC := '0';
    SIGNAL aluout       : STD_LOGIC_VECTOR(31 DOWNTO 0);

    CONSTANT CLK_PERIOD : TIME := 10 ns;

    -- Helper to assemble an R-type instruction word:
    -- opcode(31:26)="000000" | rs(25:21) | rt(20:16) | rd(15:11) | shamt(10:6)="00000" | funct(5:0)
    FUNCTION make_rtype(
        rs    : STD_LOGIC_VECTOR(4 DOWNTO 0);
        rt    : STD_LOGIC_VECTOR(4 DOWNTO 0);
        rd    : STD_LOGIC_VECTOR(4 DOWNTO 0);
        funct : STD_LOGIC_VECTOR(5 DOWNTO 0)
    ) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN "000000" & rs & rt & rd & "00000" & funct;
    END FUNCTION;
BEGIN
    uut : ENTITY work.datapath_r_type
        PORT MAP (
            clk          => clk,
            reset        => reset,
            instr        => instr,
            zero         => zero,
            aluoperation => aluoperation,
            regwrite     => regwrite,
            aluout       => aluout
        );

    -- 100 MHz clock (10 ns period)
    clk <= NOT clk AFTER CLK_PERIOD / 2;

    stim : PROCESS
        PROCEDURE run_cycle(
            CONSTANT i_word  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            CONSTANT op      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            CONSTANT rw      : IN STD_LOGIC
        ) IS
        BEGIN
            instr        <= i_word;
            aluoperation <= op;
            regwrite     <= rw;
            WAIT FOR CLK_PERIOD / 2; -- Settle combinational outputs before clock edge
        END PROCEDURE;
    BEGIN
        -- Start with reset asserted for one cycle
        reset <= '1';
        run_cycle(X"00000000", "0010", '0');
        WAIT UNTIL rising_edge(clk);
        reset <= '0';

        -- 1. NOR ("1100"): $1 = $0 NOR $0 = 0xFFFFFFFF (-1)
        run_cycle(make_rtype("00000", "00000", "00001", "100111"), "1100", '1');
        ASSERT aluout = X"FFFFFFFF" AND zero = '0'
            REPORT "NOR test failed" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk);

        -- 2. ADD ("0010"): $2 = $1 + $1 = -1 + (-1) = -2 (0xFFFFFFFE)
        run_cycle(make_rtype("00001", "00001", "00010", "100000"), "0010", '1');
        ASSERT aluout = X"FFFFFFFE" AND zero = '0'
            REPORT "ADD (-1 + -1) test failed" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk);

        -- 3. SLT ("0111"): $3 = ($2 < $1) ? 1 : 0  --> (-2 < -1) is TRUE -> 1
        run_cycle(make_rtype("00010", "00001", "00011", "101010"), "0111", '1');
        ASSERT aluout = X"00000001" AND zero = '0'
            REPORT "SLT (-2 < -1) test failed" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk);

        -- 4. ADD ("0010"): $4 = $3 + $3 = 1 + 1 = 2 (0x00000002)
        run_cycle(make_rtype("00011", "00011", "00100", "100000"), "0010", '1');
        ASSERT aluout = X"00000002" AND zero = '0'
            REPORT "ADD (1 + 1) test failed" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk);

        -- 5. SUB ("0110"): $5 = $4 - $3 = 2 - 1 = 1 (0x00000001)
        run_cycle(make_rtype("00100", "00011", "00101", "100010"), "0110", '1');
        ASSERT aluout = X"00000001" AND zero = '0'
            REPORT "SUB (2 - 1) test failed" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk);

        -- 6. SUB producing zero: $6 = $5 - $5 = 1 - 1 = 0 (zero flag should be '1')
        run_cycle(make_rtype("00101", "00101", "00110", "100010"), "0110", '1');
        ASSERT aluout = X"00000000" AND zero = '1'
            REPORT "SUB (1 - 1) zero flag test failed" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk);

        -- 7. AND ("0000"): $7 = $4 AND $4 = 2 AND 2 = 2
        run_cycle(make_rtype("00100", "00100", "00111", "100100"), "0000", '1');
        ASSERT aluout = X"00000002" AND zero = '0'
            REPORT "AND test failed" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk);

        -- 8. OR ("0001"): $8 = $4 OR $5 = 2 OR 1 = 3
        run_cycle(make_rtype("00100", "00101", "01000", "100101"), "0001", '1');
        ASSERT aluout = X"00000003" AND zero = '0'
            REPORT "OR test failed" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk);

        -- 9. Read back written registers ($8 in rs, $5 in rt) with regwrite = '0'
        run_cycle(make_rtype("01000", "00101", "01001", "100000"), "0010", '0');
        ASSERT aluout = X"00000004" AND zero = '0'
            REPORT "Read-back ADD ($8 + $5 = 3 + 1 = 4) failed" SEVERITY ERROR;
        WAIT UNTIL rising_edge(clk);

        regwrite <= '0';
        REPORT "All R-type datapath test cases passed!" SEVERITY NOTE;
        WAIT;
    END PROCESS;
END sim;