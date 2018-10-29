-- 32 bit ALU
-- Created by Luis Panadero Guardeño
-- MIT License

LIBRARY ieee;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.all;
    USE ieee.numeric_std_unsigned.all;

-- ALU entity
ENTITY ALU IS
  PORT(
       OPA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       OPB : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       OPERATION: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       CARRYIN: IN STD_LOGIC;    -- Old carry
       OUTPUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       CARRYOUT : OUT STD_LOGIC; -- Carry
       OV : OUt STD_LOGIC;       -- Overflow 32 bit
       OVW : OUT STD_LOGIC;      -- Overflow 16 bit
       OVB : OUT STD_LOGIC;      -- Overflow 8 bit
       Z : OUT STD_LOGIC;        -- Zero
       N : OUT STD_LOGIC);       -- Negative
END ALU;

-- ALU architecture
ARCHITECTURE Behavioral OF ALU IS

-- We use one extra bit to get free the carry bit
signal RESULT: STD_LOGIC_VECTOR(32 DOWNTO 0);


BEGIN

  PROCESS(OPA, OPB, OPERATION)
    variable shift : INTEGER;
  BEGIN


    case OPERATION is
      when x"0" => -- AND
          RESULT <= ('0' & OPA) and ('0' & OPB);
      when x"1" => -- OR
        RESULT <= ('0' & OPA) or ('0' & OPB);
      when x"2" => -- XOR
        RESULT <= ('0' & OPA) xor ('0' & OPB);
      when x"3" => -- BITC (and NOT OPB if OPA is full of 1's)
        RESULT <= ('0' & OPA) and ('0' & not OPB);
      when x"4" => -- ADD
        RESULT <= ('0' & OPA) + ('0' & OPB);
      when x"5" => -- ADDC
        RESULT <= ('0' & OPA) + ('0' & OPB) + CARRYIN;
      when x"6" => -- SUB
        RESULT <= ('0' & OPA) + ('1' & not OPB) + '1';
      when x"7" => -- SUBB
        RESULT <= ('0' & OPA) + not (('0' & OPB) + CARRYIN) + '1';
      when x"8" => -- RSB
        RESULT <= ('0' & OPB) + ('1' & not OPA) + '1';
      when x"9" => -- RSBB
        RESULT <= ('0' & OPB) + not (('0' & OPA) + CARRYIN) + '1';

      when x"A" => -- LLS
        shift := to_integer(OPB(4 downto 0));
        RESULT(31 downto 0) <=  OPA(31-shift downto 0) & (shift-1 downto 0 => '0');
        if (shift > 0) then -- Sets carry bit
          RESULT(32) <= OPA(31-shift+1);
        else
          RESULT(32) <= '0';
        end if;

      when x"B" => -- LRS
        shift := to_integer(OPB(4 downto 0));
        RESULT(31 downto 0) <= (31 downto (32-shift) => '0') & OPA(31 downto shift);
        if (shift > 0) then -- Sets carry bit
          RESULT(32) <= OPA(shift-1);
        else
          RESULT(32) <= '0';
        end if;

      when x"C" => -- ARS
        shift := to_integer(OPB(4 downto 0));
        RESULT(31 downto 0) <= (31 downto (32-shift) => OPA(31)) & OPA(31 downto shift);
        if (shift > 0) then -- Sets carry bit
          RESULT(32) <= OPA(shift-1);
        else
          RESULT(32) <= '0';
        end if;

      when x"D" => -- ROTL
        RESULT(32) <= '0';
        shift := to_integer(OPB(4 downto 0));
        if (shift > 0) then
          RESULT(31 downto 0) <= OPA(31-shift downto 0) & OPA(31 downto 32-shift);
        else
          RESULT(31 downto 0) <= OPA;
        end if;

      when x"E" => -- ROTR
        RESULT(32) <= '0';
        shift := to_integer(OPB(4 downto 0));
        if (shift > 0) then
          RESULT(31 downto 0) <= OPA(shift-1 downto 0) & OPA(31 downto shift);
        else
          RESULT(31 downto 0) <= OPA;
        end if;

      when others =>
        RESULT <= (32 downto 0 => '0');
    end case;
  END PROCESS;

  OUTPUT <= RESULT(31 downto 0);
  CARRYOUT <= RESULT(32);

  Z <= '1' when RESULT(31 downto 0) = (31 downto 0 => '0') else '0';
  N <= RESULT(31);
  -- OV = Sign A ^ Sign B ^ Carry ^ Sign Result
  OV  <= OPA(31) xor OPB(31) xor RESULT(32) xor RESULT(31);
  OVW <= OPA(15) xor OPB(15) xor RESULT(16) xor RESULT(15);
  OVB <= OPA(7) xor OPB(7) xor RESULT(8) xor RESULT(7);


END Behavioral;
