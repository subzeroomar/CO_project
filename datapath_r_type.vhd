LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY datapath_r_type IS
    PORT (
        clk          : IN STD_LOGIC;
        reset        : IN STD_LOGIC;
        instr        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        zero         : OUT STD_LOGIC;
        aluoperation : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        regwrite     : IN STD_LOGIC;
        aluout       : BUFFER STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END datapath_r_type;

ARCHITECTURE structural OF datapath_r_type IS
    SIGNAL reg_read1, reg_read2 : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL write_en_gated : STD_LOGIC;
    SIGNAL alu_result : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL alu_zero : STD_LOGIC;
Begin
    write_en_gated <= regwrite and (not reset);
    RF_INST : ENTITY work.regfile
        PORT MAP (
            read_sel1 => instr(25 DOWNTO 21),
            read_sel2 => instr(20 DOWNTO 16),
            write_sel => instr(15 DOWNTO 11),
            write_data => aluout,
            write_ena => write_en_gated,
            clk => clk,
            data1 => reg_read1,
            data2 => reg_read2
        );

    ALU_INST : ENTITY work.alu32
        PORT MAP (
            data1 => reg_read1,
            data2 => reg_read2,
            aluop => aluoperation,
            zflag => alu_zero,
            dataout => alu_result
        );
    aluout <= alu_result;
    zero   <= alu_zero;
END structural;