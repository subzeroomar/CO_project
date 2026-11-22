LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY regfile IS
    PORT (
        read_sel1, read_sel2, write_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_ena : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        data1, data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END regfile;

ARCHITECTURE Behavioral OF regfile IS

    TYPE reg_array IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL regs : reg_array := (OTHERS => (OTHERS => '0'));

BEGIN

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF write_ena = '1' THEN
                IF write_sel /= "00000" THEN
                    regs(TO_INTEGER(UNSIGNED(write_sel))) <= write_data;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    data1 <= regs(TO_INTEGER(UNSIGNED(read_sel1)));
    data2 <= regs(TO_INTEGER(UNSIGNED(read_sel2)));

END Behavioral;