-- Created by Luis Panadero Guardeño
-- Testbench for ALU

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  use IEEE.NUMERIC_STD_UNSIGNED.all;

entity ALU_TB is
  -- empty
end entity;

architecture BEHAVIORAL of ALU_TB is

  signal dataa   : std_logic_vector(31 downto 0) := X"00000000";
  signal datab   : std_logic_vector(31 downto 0) := X"00000000";
  signal op      : std_logic_vector(3 downto 0) := X"0";
  signal dataout : std_logic_vector(31 downto 0);
  signal cin     : std_logic := '0';
  signal cout    : std_logic;
  signal ov      : std_logic;
  signal ovw     : std_logic;
  signal ovb     : std_logic;
  signal z       : std_logic;
  signal n       : std_logic;

  -- DUT component

  component ALU is
    port (
      OPA       : in    std_logic_vector(31 downto 0);
      OPB       : in    std_logic_vector(31 downto 0);
      OPERATION : in    std_logic_vector(3 downto 0);
      CARRYIN   : in    std_logic;
      OUTPUT    : out   std_logic_vector(31 downto 0);
      CARRYOUT  : out   std_logic;
      OV        : out   std_logic;
      OVW       : out   std_logic;
      OVB       : out   std_logic;
      Z         : out   std_logic;
      N         : out   std_logic
    );
  end component;

  -- Contants
  constant delayt  : time := 100 ns; -- 10Mhz

  constant op_and  : std_logic_vector(3 downto 0) := x"0";
  constant op_or   : std_logic_vector(3 downto 0) := x"1";
  constant op_xor  : std_logic_vector(3 downto 0) := x"2";
  constant op_bitc : std_logic_vector(3 downto 0) := x"3";
  constant op_add  : std_logic_vector(3 downto 0) := x"4";
  constant op_addc : std_logic_vector(3 downto 0) := x"5";
  constant op_sub  : std_logic_vector(3 downto 0) := x"6";
  constant op_subb : std_logic_vector(3 downto 0) := x"7";
  constant op_rsb  : std_logic_vector(3 downto 0) := x"8";
  constant op_rsbb : std_logic_vector(3 downto 0) := x"9";
  constant op_lls  : std_logic_vector(3 downto 0) := x"A";
  constant op_lrs  : std_logic_vector(3 downto 0) := x"B";
  constant op_ars  : std_logic_vector(3 downto 0) := x"C";
  constant op_rotl : std_logic_vector(3 downto 0) := x"D";
  constant op_rotr : std_logic_vector(3 downto 0) := x"E";

begin

  -- Connect DUT
  UUT : ALU
    port map (DATAA, DATAB, OP, CIN, DATAOUT, COUT, OV, OVW, OVB, Z, N);

  process
  begin

    -- "Reset"
    dataa <= x"0000_0000";
    datab <= x"0000_0000";
    cin   <= '0';
    op    <= x"F";
    wait for delayt;
    assert dataout=x"0000_0000"
      report "Set to zero failed - Value"
      severity failure;
    assert z='1' and ov='0' and n='0' and cout='0'
      report "Set to zero failed - Flags"
      severity failure;

    -- Addition 32 bit
    dataa <= x"5555_5555";
    datab <= x"AAAA_AAAA";
    cin   <= '0';
    op    <= op_add;
    wait for delayt;
    assert dataout=x"FFFF_FFFF"
      report "Addition failed 0x5555_5555 + 0xAAAA_AAAA - Value"
      severity failure;
    assert z='0' and ov='0' and n='1' and cout='0'
      report "Addition failed 0x5555_5555 + 0xAAAA_AAAA - Flags"
      severity failure;

    -- Addition 8bit
    dataa <= x"0000_007F";
    datab <= x"0000_007F";
    cin   <= '0';
    op    <= op_add;
    wait for delayt;
    assert dataout=x"0000_00FE"
      report "8bit Addition failed - Value"
      severity failure;
    assert z='0' and ov='0' and n='0' and cout='0' and ovb='1'
      report "8bit Addition failed - Flags"
      severity failure;

    -- Addition 16bit
    dataa <= x"0000_7FFF";
    datab <= x"0000_7FFF";
    cin   <= '0';
    op    <= op_add;
    wait for delayt;
    assert dataout=x"0000_FFFE"
      report "16bit Addition failed - Value"
      severity failure;
    assert z='0' and ov='0' and n='0' and cout='0' and ovw='1'
      report "16bit Addition failed - Flags"
      severity failure;

    -- Addition 32 bit
    dataa <= x"FFFF_FFFF";
    datab <= x"FFFF_FFFF";
    cin   <= '0';
    op    <= op_add;
    wait for delayt;
    assert dataout=x"FFFF_FFFE"
      report "Addition failed FFFF_FFFF + FFFF_FFFF - Value"
      severity failure;
    assert z='0' and ov='0' and n='1' and cout='1'
      report "Addition failed FFFF_FFFF + FFFF_FFFF - Flags"
      severity failure;

    dataa <= x"5555_5556";
    datab <= x"AAAA_AAAA";
    cin   <= '0';
    op    <= op_add;
    wait for delayt;
    assert dataout=x"0000_0000"
      report "Addition failed 0x5555_5556 + 0xAAAA_AAAA - Value"
      severity failure;
    assert z='1' and ov='0' and n='0' and cout='1'
      report "Addition failed 0x5555_5556 + 0xAAAA_AAAA - Flags"
      severity failure;

    -- Addition with carry
    dataa <= x"5555_5555";
    datab <= x"AAAA_AAAA";
    cin   <= '1';
    op    <= op_addc;
    wait for delayt;
    assert dataout=x"0000_0000"
      report "Addition with c failed 0x5555_5555 + 0xAAAA_AAAA + 1 - Value"
      severity failure;
    assert z='1' and ov='0' and n='0' and cout='1'
      report "Addition with c failed 0x5555_5555 + 0xAAAA_AAAA + 1 - Flags"
      severity failure;

    -- Addition
    dataa <= x"BFFF_FFFF";
    datab <= x"BFFF_FFFF";
    cin   <= '0';
    op    <= op_add;
    wait for delayt;
    assert dataout=x"7FFF_FFFE"
      report "Addition failed BFFF_FFFF + BFFF_FFFF - Value"
      severity failure;
    assert z='0' and ov='1' and n='0' and cout='1'
      report "Addition failed BFFF_FFFF + BFFF_FFFF - Flags"
      severity failure;

    -- Substraction
    dataa <= x"0AAA_AAAA";
    datab <= x"0555_5555";
    cin   <= '0';
    op    <= op_sub;
    wait for delayt;
    assert dataout=x"0555_5555"
      report "sub failed 0AAA_AAAA - 0555_5555 - Value"
      severity failure;
    assert z='0' and ov='0' and n='0' and cout='0'
      report "sub failed 0AAA_AAAA - 0555_5555 - Flags"
      severity failure;

    dataa <= x"0555_5555";
    datab <= x"0AAA_AAAA";
    cin   <= '0';
    op    <= op_sub;
    wait for delayt;
    assert dataout=x"FAAA_AAAB"
      report "sub failed 0555_5555 - 0AAA_AAAA - Value"
      severity failure;
    assert z='0' and ov='0' and n='1' and cout='1'
      report "sub failed 0555_5555 - 0AAA_AAAA - Flags"
      severity failure;

    dataa <= x"0000_0001";
    datab <= x"8000_0000";
    cin   <= '0';
    op    <= op_sub;
    wait for delayt;
    assert dataout=x"8000_0001"
      report "sub failed 0000_0001 - 8000_0000 - Value"
      severity failure;
    assert z='0' and ov='1' and n='1' and cout='1'
      report "sub failed 0000_0001 - 8000_0000 - Flags"
      severity failure;

    -- Substraction with carry
    dataa <= x"0000_0000";
    datab <= x"8000_0000";
    cin   <= '1';
    op    <= op_subb;
    wait for delayt;
    assert dataout=x"7FFF_FFFF"
      report "Subb failed 0000_0000 - 8000_0000 - 1 - Value"
      severity failure;
    assert z='0' and ov='0' and n='0' and cout='1'
      report "Subb failed 0000_0000 - 8000_0000 - 1 - Flags"
      severity failure;

    -- Reverse substraction
    dataa <= x"8000_0000";
    datab <= x"0000_0001";
    cin   <= '0';
    op    <= op_rsb;
    wait for delayt;
    assert dataout=x"8000_0001"
      report "rsb failed 0000_0001 - 8000_0000 - Value"
      severity failure;
    assert z='0' and ov='1' and n='1' and cout='1'
      report "rsb failed 0000_0001 - 8000_0000 - Flags"
      severity failure;

    -- Reverse substraction with carry
    dataa <= x"8000_0000";
    datab <= x"0000_0000";
    cin   <= '1';
    op    <= op_rsbb;
    wait for delayt;
    assert dataout=x"7FFF_FFFF"
      report "RSBb failed 0000_0000 - 8000_0000 - 1 - Value"
      severity failure;
    assert z='0' and ov='0' and n='0' and cout='1'
      report "RSBb failed 0000_0000 - 8000_0000 - 1 - Flags"
      severity failure;

    -- AND
    dataa <= x"555F_AFAA";
    datab <= x"AAAA_F555";
    cin   <= '0';
    op    <= op_and;
    wait for delayt;
    assert dataout=x"000A_A500"
      report "AND failed - Value"
      severity failure;
    assert z='0' and n='0' and cout='0'
      report "AND failed - Flags"
      severity failure;

    -- OR
    dataa <= x"5555_AAAA";
    datab <= x"AAAA_5555";
    cin   <= '0';
    op    <= op_or;
    wait for delayt;
    assert dataout=x"FFFF_FFFF"
      report "OR failed - Value"
      severity failure;
    assert z='0' and n='1' and cout='0'
      report "OR failed - Flags"
      severity failure;

    -- XOR
    dataa <= x"FF55_AAAA";
    datab <= x"FFAA_FF55";
    cin   <= '0';
    op    <= op_xor;
    wait for delayt;
    assert dataout=x"00FF_55FF"
      report "XOR failed - Value"
      severity failure;
    assert z='0' and n='0' and cout='0'
      report "XOR failed - Flags"
      severity failure;

    -- BITC
    dataa <= x"FFAF_00FF";
    datab <= x"55F0_F0AA";
    cin   <= '0';
    op    <= op_bitc;
    wait for delayt;
    assert dataout=x"AA0F_0055"
      report "BITC failed - Value"
      severity failure;
    assert z='0' and n='1' and cout='0'
      report "BITC failed - Flags"
      severity failure;

    -- LLS
    dataa <= x"F000_0001";
    datab <= x"0000_0001";
    cin   <= '0';
    op    <= op_lls;
    wait for delayt;
    assert dataout=x"E000_0002"
      report "LLS failed - Value"
      severity failure;
    assert z='0' and n='1' and cout='1'
      report "LLS failed - Flags"
      severity failure;

    -- LLS
    dataa <= x"5000_000A";
    datab <= x"0000_0002";
    cin   <= '0';
    op    <= op_lls;
    wait for delayt;
    assert dataout=x"4000_0028"
      report "LLS failed - Value"
      severity failure;
    assert z='0' and n='0' and cout='1'
      report "LLS failed - Flags"
      severity failure;

    -- LLS only uses LSB 4 bits of opb -> max 31 bits of shift
    dataa <= x"5000_000F";
    datab <= x"0000_00FF";
    cin   <= '0';
    op    <= op_lls;
    wait for delayt;
    assert dataout=x"8000_0000"
      report "LLS failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='1' and cout='1'
      report "LLS failed - Flags"
      severity failure;

    -- LRS
    dataa <= x"5000_000A";
    datab <= x"0000_0001";
    cin   <= '0';
    op    <= op_lrs;
    wait for delayt;
    assert dataout=x"2800_0005"
      report "LRS failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='0' and cout='0'
      report "LRS failed - Flags"
      severity failure;

    -- LRS
    dataa <= x"5000_000A";
    datab <= x"0000_0002";
    cin   <= '0';
    op    <= op_lrs;
    wait for delayt;
    assert dataout=x"1400_0002"
      report "LRS failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='0' and cout='1'
      report "LRS failed - Flags"
      severity failure;

    -- LRS only uses LSB 4 bits of opb -> max 31 bits of shift
    dataa <= x"D000_000A";
    datab <= x"0000_00FF";
    cin   <= '0';
    op    <= op_lrs;
    wait for delayt;
    assert dataout=x"0000_0001"
      report "LRS failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='0' and cout='1'
      report "LRS failed - Flags"
      severity failure;

    -- ARS
    dataa <= x"A000_0005";
    datab <= x"0000_000F";
    cin   <= '0';
    op    <= op_ars;
    wait for delayt;
    assert dataout=x"FFFF_4000"
      report "ARS failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='1' and cout='0'
      report "ARS failed - Flags"
      severity failure;

    -- ARS
    dataa <= x"2000_0005";
    datab <= x"0000_000F";
    cin   <= '0';
    op    <= op_ars;
    wait for delayt;
    assert dataout=x"0000_4000"
      report "ARS failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='0' and cout='0'
      report "ARS failed - Flags"
      severity failure;

    -- ARS only uses LSB 4 bits of opb -> max 31 bits of shift
    dataa <= x"F000_0005";
    datab <= x"0000_00FF";
    cin   <= '0';
    op    <= op_ars;
    wait for delayt;
    assert dataout=x"FFFF_FFFF"
      report "ARS failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='1' and cout='1'
      report "ARS failed - Flags"
      severity failure;

    -- ROTL
    dataa <= x"F000_005A";
    datab <= x"0000_0004";
    cin   <= '0';
    op    <= op_rotl;
    wait for delayt;
    assert dataout=x"0000_05AF"
      report "ROTL failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='0' and cout='0'
      report "ROTL failed - Flags"
      severity failure;

    -- ROTL only uses LSB 4 bits of opb -> max 31 bits of shift
    dataa <= x"F000_005A";
    datab <= x"0000_00FF";
    cin   <= '0';
    op    <= op_rotl;
    wait for delayt;
    assert dataout=x"7800_002D"
      report "ROTL failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='0' and cout='0'
      report "ROTL failed - Flags"
      severity failure;

    -- ROTR
    dataa <= x"F000_005A";
    datab <= x"0000_0004";
    cin   <= '0';
    op    <= op_rotr;
    wait for delayt;
    assert dataout=x"AF00_0005"
      report "ROTR failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='1' and cout='0'
      report "ROTR failed - Flags"
      severity failure;

    -- ROTR only uses LSB 4 bits of opb -> max 31 bits of shift
    dataa <= x"F000_005A";
    datab <= x"0000_00FF";
    cin   <= '0';
    op    <= op_rotr;
    wait for delayt;
    assert dataout=x"E000_00B5"
      report "ROTR failed - Value 0x" & to_hstring(dataout)
      severity failure;
    assert z='0' and n='1' and cout='0'
      report "ROTR failed - Flags"
      severity failure;


    assert false
      report "Test done. Open EPWave to see signals."
      severity note;
    wait;

  end process;

end architecture BEHAVIORAL;

