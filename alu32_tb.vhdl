-- Created by Luis Panadero Guardeño
-- Testbench for ALU

LIBRARY ieee;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.all;
    USE ieee.numeric_std_unsigned.all;

entity ALU_TB is
-- empty
end entity;

architecture Behavioral of ALU_TB is

signal DATAA : STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal DATAB : STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal OP : STD_LOGIC_VECTOR(3 downto 0):=x"0";
signal DATAOUT : STD_LOGIC_VECTOR(31 downto 0);
signal CIN : STD_LOGIC:='0';
signal COUT : STD_LOGIC;
signal OV : STD_LOGIC;
signal OVW : STD_LOGIC;
signal OVB : STD_LOGIC;
signal Z : STD_LOGIC;
signal N : STD_LOGIC;

-- DUT component
component alu is
    port(OPA : in STD_LOGIC_VECTOR(31 downto 0);
         OPB : in STD_LOGIC_VECTOR(31 downto 0);
         OPERATION : STD_LOGIC_VECTOR(3 downto 0);
         CARRYIN: in STD_LOGIC;
         OUTPUT : out STD_LOGIC_VECTOR(31 downto 0);
         CARRYOUT : out STD_LOGIC;
         OV : out STD_LOGIC;
         OVW : out STD_LOGIC;
         OVB : out STD_LOGIC;
         Z : out STD_LOGIC;
         N : out STD_LOGIC
         );
end component;

constant DELAYT : TIME := 10 ns;

begin

  -- Connect DUT
  UUT: ALU port map(DATAA, DATAB, OP, CIN, DATAOUT, COUT, OV, OVW, OVB, Z, N);

  process
  begin
    -- "Reset"
    DATAA<=x"0000_0000";
    DATAB<=x"0000_0000";
    CIN<='0';
    OP<=x"F";
    wait for DELAYT;
    assert DATAOUT=x"0000_0000"
        report "Set to zero failed - Value"
        severity failure;
    assert Z='1' and OV='0' and N='0' and COUT='0'
        report "Set to zero failed - Flags"
        severity failure;

    DATAA<=x"5555_5555";
    DATAB<=x"AAAA_AAAA";
    CIN<='0';
    OP<=x"4";
    wait for DELAYT;
    assert DATAOUT=x"FFFF_FFFF"
        report "Addition failed 0x5555_5555 + 0xAAAA_AAAA - Value"
        severity failure;
    assert Z='0' and OV='0' and N='1' and COUT='0'
        report "Addition failed 0x5555_5555 + 0xAAAA_AAAA - Flags"
        severity failure;

    DATAA<=x"0000_007F";
    DATAB<=x"0000_007F";
    CIN<='0';
    OP<=x"4";
    wait for DELAYT;
    assert DATAOUT=x"0000_00FE"
        report "8bit Addition failed - Value"
        severity failure;
    assert Z='0' and OV='0' and N='0' and COUT='0' and OVB='1'
        report "8bit Addition failed - Flags"
        severity failure;

    DATAA<=x"0000_7FFF";
    DATAB<=x"0000_7FFF";
    CIN<='0';
    OP<=x"4";
    wait for DELAYT;
    assert DATAOUT=x"0000_FFFE"
        report "16bit Addition failed - Value"
        severity failure;
    assert Z='0' and OV='0' and N='0' and COUT='0' and OVW='1'
        report "16bit Addition failed - Flags"
        severity failure;


    DATAA<=x"FFFF_FFFF";
    DATAB<=x"FFFF_FFFF";
    CIN<='0';
    OP<=x"4";
    wait for DELAYT;
    assert DATAOUT=x"FFFF_FFFE"
        report "Addition failed FFFF_FFFF + FFFF_FFFF - Value"
        severity failure;
    assert Z='0' and OV='0' and N='1' and COUT='1'
        report "Addition failed FFFF_FFFF + FFFF_FFFF - Flags"
        severity failure;

    DATAA<=x"5555_5556";
    DATAB<=x"AAAA_AAAA";
    CIN<='0';
    OP<=x"4";
    wait for DELAYT;
    assert DATAOUT=x"0000_0000"
        report "Addition failed 0x5555_5556 + 0xAAAA_AAAA - Value"
        severity failure;
    assert Z='1' and OV='0' and N='0' and COUT='1'
        report "Addition failed 0x5555_5556 + 0xAAAA_AAAA - Flags"
        severity failure;

    DATAA<=x"5555_5555";
    DATAB<=x"AAAA_AAAA";
    CIN<='1';
    OP<=x"5";
    wait for DELAYT;
    assert DATAOUT=x"0000_0000"
        report "Addition with c failed 0x5555_5555 + 0xAAAA_AAAA +1- Value"
        severity failure;
    assert Z='1' and OV='0' and N='0' and COUT='1'
        report "Addition with c failed 0x5555_5555 + 0xAAAA_AAAA +1 - Flags"
        severity failure;

    DATAA<=x"BFFF_FFFF";
    DATAB<=x"BFFF_FFFF";
    CIN<='0';
    OP<=x"4";
    wait for DELAYT;
    assert DATAOUT=x"7FFF_FFFE"
        report "Addition failed BFFF_FFFF + BFFF_FFFF - Value"
        severity failure;
    assert Z='0' and OV='1' and N='0' and COUT='1'
        report "Addition failed BFFF_FFFF + BFFF_FFFF - Flags"
        severity failure;

    DATAA<=x"0AAA_AAAA";
    DATAB<=x"0555_5555";
    CIN<='0';
    OP<=x"6";
    wait for DELAYT;
    assert DATAOUT=x"0555_5555"
        report "sub failed 0AAA_AAAA - 0555_5555 - Value"
        severity failure;
    assert Z='0' and OV='0' and N='0' and COUT='0'
        report "sub failed 0AAA_AAAA - 0555_5555 - Flags"
        severity failure;

    DATAA<=x"0555_5555";
    DATAB<=x"0AAA_AAAA";
    CIN<='0';
    OP<=x"6";
    wait for DELAYT;
    assert DATAOUT=x"FAAA_AAAB"
        report "sub failed 0555_5555 - 0AAA_AAAA - Value"
        severity failure;
    assert Z='0' and OV='0' and N='1' and COUT='1'
        report "sub failed 0555_5555 - 0AAA_AAAA - Flags"
        severity failure;

    DATAA<=x"0000_0001";
    DATAB<=x"8000_0000";
    CIN<='0';
    OP<=x"6";
    wait for DELAYT;
    assert DATAOUT=x"8000_0001"
        report "sub failed 0000_0001 - 8000_0000 - Value"
        severity failure;
    assert Z='0' and OV='1' and N='1' and COUT='1'
        report "sub failed 0000_0001 - 8000_0000 - Flags"
        severity failure;

    DATAA<=x"0000_0000";
    DATAB<=x"8000_0000";
    CIN<='1';
    OP<=x"7";
    wait for DELAYT;
    assert DATAOUT=x"7FFF_FFFF"
        report "Subb failed 0000_0000 - 8000_0000 -1 - Value"
        severity failure;
    assert Z='0' and OV='0' and N='0' and COUT='1'
        report "Subb failed 0000_0000 - 8000_0000 -1 - Flags"
        severity failure;

    DATAA<=x"8000_0000";
    DATAB<=x"0000_0001";
    CIN<='0';
    OP<=x"8";
    wait for DELAYT;
    assert DATAOUT=x"8000_0001"
        report "rsb failed 0000_0001 - 8000_0000 - Value"
        severity failure;
    assert Z='0' and OV='1' and N='1' and COUT='1'
        report "rsb failed 0000_0001 - 8000_0000 - Flags"
        severity failure;

    DATAA<=x"8000_0000";
    DATAB<=x"0000_0000";
    CIN<='1';
    OP<=x"9";
    wait for DELAYT;
    assert DATAOUT=x"7FFF_FFFF"
        report "RSBb failed 0000_0000 - 8000_0000 -1 - Value"
        severity failure;
    assert Z='0' and OV='0' and N='0' and COUT='1'
        report "RSBb failed 0000_0000 - 8000_0000 -1 - Flags"
        severity failure;

    DATAA<=x"5555_AAAA";
    DATAB<=x"AAAA_5555";
    CIN<='0';
    OP<=x"0";
    wait for DELAYT;
    assert DATAOUT=x"0000_0000"
        report "AND failed - Value"
        severity failure;
    assert Z='1' and N='0' and COUT='0'
        report "AND failed - Flags"
        severity failure;

    DATAA<=x"5555_AAAA";
    DATAB<=x"AAAA_5555";
    CIN<='0';
    OP<=x"1";
    wait for DELAYT;
    assert DATAOUT=x"FFFF_FFFF"
        report "OR failed - Value"
        severity failure;
    assert Z='0' and N='1' and COUT='0'
        report "OR failed - Flags"
        severity failure;

    DATAA<=x"FF55_AAAA";
    DATAB<=x"FFAA_FF55";
    CIN<='0';
    OP<=x"2";
    wait for DELAYT;
    assert DATAOUT=x"00FF_55FF"
        report "XOR failed - Value"
        severity failure;
    assert Z='0' and N='0' and COUT='0'
        report "XOR failed - Flags"
        severity failure;

    DATAA<=x"FFAF_00FF";
    DATAB<=x"55F0_F0AA";
    CIN<='0';
    OP<=x"3";
    wait for DELAYT;
    assert DATAOUT=x"AA0F_0055"
        report "BITC failed - Value"
        severity failure;
    assert Z='0' and N='1' and COUT='0'
        report "BITC failed - Flags"
        severity failure;


    DATAA<=x"5000_000A";
    DATAB<=x"0000_0002";
    CIN<='0';
    OP<=x"A";
    wait for DELAYT;
    assert DATAOUT=x"4000_0028"
        report "LLS failed - Value"
        severity failure;
    assert Z='0' and N='0' and COUT='1'
        report "LLS failed - Flags"
        severity failure;

    DATAA<=x"F000_0001";
    DATAB<=x"0000_0001";
    CIN<='0';
    OP<=x"A";
    wait for DELAYT;
    assert DATAOUT=x"E000_0002"
        report "LLS failed - Value"
        severity failure;
    assert Z='0' and N='1' and COUT='1'
        report "LLS failed - Flags"
        severity failure;

    DATAA<=x"5000000A";
    DATAB<=x"00000002";
    CIN<='0';
    OP<=x"B";
    wait for DELAYT;

    DATAA<=x"A0000005";
    DATAB<=x"00000002";
    CIN<='0';
    OP<=x"C";
    wait for DELAYT;

    DATAA<=x"5000000A";
    DATAB<=x"0FFFFFFF";
    CIN<='0';
    OP<=x"A";
    wait for DELAYT;

    DATAA<=x"F000005A";
    DATAB<=x"00000001";
    CIN<='0';
    OP<=x"D";
    wait for DELAYT;

    DATAA<=x"F000005A";
    DATAB<=x"00000004";
    CIN<='0';
    OP<=x"D";
    wait for DELAYT;

    DATAA<=x"F000005A";
    DATAB<=x"0000009C";
    CIN<='0';
    OP<=x"D";
    wait for DELAYT;

    DATAA<=x"F000005A";
    DATAB<=x"00000020";
    CIN<='0';
    OP<=x"D";
    wait for DELAYT;

    DATAA<=x"F000005A";
    DATAB<=x"00000001";
    CIN<='0';
    OP<=x"E";
    wait for DELAYT;

    DATAA<=x"F000005A";
    DATAB<=x"00000004";
    CIN<='0';
    OP<=x"E";
    wait for DELAYT;

    DATAA<=x"F000005A";
    DATAB<=x"0000009C";
    CIN<='0';
    OP<=x"E";
    wait for DELAYT;

    DATAA<=x"F000005A";
    DATAB<=x"00000020";
    CIN<='0';
    OP<=x"E";
    wait for DELAYT;

    assert false
        report "Test done. Open EPWave to see signals."
        severity note;
    wait;
  end process;

end Behavioral;

