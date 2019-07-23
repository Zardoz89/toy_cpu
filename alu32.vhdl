-- 32 bit ALU
-- Created by Luis Panadero Guardeño
-- MIT License

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.numeric_std_unsigned.all;

-- ALU entity

entity ALU is
  port (
    OPA       : in    std_logic_vector(31 DOWNTO 0);
    OPB       : in    std_logic_vector(31 DOWNTO 0);
    OPERATION : in    std_logic_vector(3 DOWNTO 0);
    CARRYIN   : in    STD_LOGIC;        -- Old carry
    OUTPUT    : out   std_logic_vector(31 DOWNTO 0);
    CARRYOUT  : out   STD_LOGIC;        -- Carry
    OV        : out   STD_LOGIC;        -- Overflow 32 bit
    OVW       : out   STD_LOGIC;        -- Overflow 16 bit
    OVB       : out   STD_LOGIC;        -- Overflow 8 bit
    Z         : out   STD_LOGIC;        -- Zero
    N         : out   std_logic         -- Negative
  );
end entity ALU;

-- ALU architecture

architecture BEHAVIORAL of ALU is

  -- We use one extra bit to get free the carry bit
  signal result : std_logic_vector(32 DOWNTO 0);

begin

  process (OPA, OPB, OPERATION) is

    variable shift : integer;

  begin

    case OPERATION is

      when x"0" =>          -- AND
        result <= ('0' & OPA) and ('0' & OPB);
      when x"1" =>          -- OR
        result <= ('0' & OPA) or ('0' & OPB);
      when x"2" =>          -- XOR
        result <= ('0' & OPA) xor ('0' & OPB);
      when x"3" =>          -- BITC (and NOT OPB if OPA is full of 1's)
        result <= ('0' & OPA) and ('0' & not OPB);
      when x"4" =>          -- ADD
        result <= ('0' & OPA) + ('0' & OPB);
      when x"5" =>          -- ADDC
        result <= ('0' & OPA) + ('0' & OPB) + CARRYIN;
      when x"6" =>          -- SUB
        result <= ('0' & OPA) + ('1' & not OPB) + '1';
      when x"7" =>          -- SUBB
        result <= ('0' & OPA) + not (('0' & OPB) + CARRYIN) + '1';
      when x"8" =>          -- RSB
        result <= ('0' & OPB) + ('1' & not OPA) + '1';
      when x"9" =>          -- RSBB
        result <= ('0' & OPB) + not (('0' & OPA) + CARRYIN) + '1';

      when x"A" =>          -- LLS
        shift := to_integer(OPB(4 downto 0));
        result(31 downto 0) <= OPA(31 - shift downto 0) & (shift - 1 downto 0 => '0');

        if (shift > 0) then -- Sets carry bit
          result(32) <= OPA(31 - shift + 1);
        else
          result(32) <= '0';
        end if;

      when x"B" =>          -- LRS
        shift := to_integer(OPB(4 downto 0));
        result(31 downto 0) <= (31 downto (32 - shift) => '0') & OPA(31 downto shift);

        if (shift > 0) then -- Sets carry bit
          result(32) <= OPA(shift - 1);
        else
          result(32) <= '0';
        end if;

      when x"C" =>          -- ARS
        shift := to_integer(OPB(4 downto 0));
        result(31 downto 0) <= (31 downto (32 - shift) => OPA(31)) & OPA(31 downto shift);

        if (shift > 0) then -- Sets carry bit
          result(32) <= OPA(shift - 1);
        else
          result(32) <= '0';
        end if;

      when x"D" =>          -- ROTL
        result(32) <= '0';
        shift := to_integer(OPB(4 downto 0));

        if (shift > 0) then
          result(31 downto 0) <= OPA(31 - shift downto 0) & OPA(31 downto 32 - shift);
        else
          result(31 downto 0) <= OPA;
        end if;

      when x"E" =>          -- ROTR
        result(32) <= '0';
        shift := to_integer(OPB(4 downto 0));

        if (shift > 0) then
          result(31 downto 0) <= OPA(shift - 1 downto 0) & OPA(31 downto shift);
        else
          result(31 downto 0) <= OPA;
        end if;

      when others =>
        result <= (32 downto 0 => '0');

    end case;

  end process;

  OUTPUT   <= result(31 downto 0);
  CARRYOUT <= result(32);

  Z <= '1' when result(31 downto 0) = (31 downto 0 => '0') else
       '0';
  N <= result(31);
  -- OV = Sign A ^ Sign B ^ Carry ^ Sign Result
  OV  <= OPA(31) xor OPB(31) xor result(32) xor result(31);
  OVW <= OPA(15) xor OPB(15) xor result(16) xor result(15);
  OVB <= OPA(7) xor OPB(7) xor result(8) xor result(7);

end architecture BEHAVIORAL;
