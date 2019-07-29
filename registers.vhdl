-- Created by Luis Panadero Guardeño
-- MIT License

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.numeric_std_unsigned.all;

-- Register file entity

entity REG_FILE is
  port (
    CLK     : in    std_logic;
    NRST    : in    std_logic;
    -- Registers selector
    R1_SEL  : in    std_logic_vector(3 DOWNTO 0);
    R2_SEL  : in    std_logic_vector(3 DOWNTO 0);
    R3_SEL  : in    std_logic_vector(3 DOWNTO 0);
    -- Data output
    R1OUT   : out   std_logic_vector(31 DOWNTO 0);
    R2OUT   : out   std_logic_vector(31 DOWNTO 0);
    R3OUT   : out   std_logic_vector(31 DOWNTO 0);
    -- Data input
    DATAIN1 : in    std_logic_vector(31 DOWNTO 0);
    DATAIN2 : in    std_logic_vector(31 DOWNTO 0);
    WE1     : in    std_logic;
    WE2     : in    std_logic;
    -- Flags in/out
    FIN     : in    std_logic_vector(31 DOWNTO 0);
    FOUT    : out   std_logic_vector(31 DOWNTO 0);
    WF      : in    std_logic;
    -- IA out
    IAOUT   : out   std_logic_vector(31 DOWNTO 0);
    -- Stack in/out
    SPIN    : in    std_logic_vector(31 DOWNTO 0);
    SPOUT   : out   std_logic_vector(31 DOWNTO 0);
    WSP     : in    std_logic
  );
end entity REG_FILE;

architecture BEHAVIORAL of REG_FILE is

  type reg16 is ARRAY    (15 DOWNTO 0) OF STD_LOGIC_VECTOR(31 downto 0);

  signal registers : reg16;

  constant sp       : integer := 13;
  constant ia       : integer := 14;
  constant flags    : integer := 15;

begin

  -- Write values to registers
  process (DATAIN1, DATAIN2, R1_SEL, R2_SEL, WE1, WE2,
           FIN, WF, SPIN, WSP, CLK, nRST) is
  begin

    if (nRST = '0') then
      -- RESET
      for i in 0 to 15 loop
        registers(i) <= (others => '0');
      end loop;
    elsif (rising_EDGE (CLK)) then
      if (WE1 = '1' OR WE2 = '1') then
        if (WE1 = '1') then
          registers(to_integer(R1_SEL)) <= DATAIN1;
        end if;
        if (WE2 = '1') then
          registers(to_integer(R2_SEL)) <= DATAIN2;
        end if;
      else
        if (WF = '1') then
          -- Overwrite Flag register
          registers(flags) <= FIN;
        end if;
        if (WSP = '1') then
          -- Overwrite Stack register
          registers(sp) <= SPIN;
        end if;
      end if;
    end if;

  end process;

  -- Update outs
  R1OUT <= registers(to_integer(R1_SEL));
  R2OUT <= registers(to_integer(R2_SEL));
  R3OUT <= registers(to_integer(R3_SEL));

  FOUT  <= registers(flags);
  IAOUT <= registers(ia);
  SPOUT <= registers(sp);

end architecture BEHAVIORAL;

