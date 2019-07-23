-- 32 bit toy CPU
-- Created by Luis Panadero Guardeño
-- MIT License

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.numeric_std_unsigned.all;

-- TOY_CPU entity

entity TOY_CPU is
  port (
    NRST      : in    std_logic;
    CLK       : in    std_logic;
    I_ADDR    : out   std_logic_vector(31 downto 0);
    I_WRSTB   : out   std_logic;
    I_DATAOUT : out   std_logic_vector(31 downto 0);
    I_DATAIN  : in    std_logic_vector(31 downto 0)    -- Instruccion
  );
end entity TOY_CPU;

-- ALU architecture

architecture BEHAVIORAL of TOY_CPU is

  component REGISTERS_FILE is
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
  end component;

  signal pc                    : std_logic_vector(31 DOWNTO 0);

  -- Registers file
  signal r1_sel                : std_logic_vector(3 DOWNTO 0);
  signal r2_sel                : std_logic_vector(3 DOWNTO 0);
  signal r3_sel                : std_logic_vector(3 DOWNTO 0);
  signal r1out                 : std_logic_vector(31 DOWNTO 0);
  signal r2out                 : std_logic_vector(31 DOWNTO 0);
  signal r3out                 : std_logic_vector(31 DOWNTO 0);
  signal datain1               : std_logic_vector(31 DOWNTO 0);
  signal datain2               : std_logic_vector(31 DOWNTO 0);
  signal we1                   : std_logic;
  signal we2                   : std_logic;
  signal fin                   : std_logic_vector(31 DOWNTO 0);
  signal fout                  : std_logic_vector(31 DOWNTO 0);
  signal wf                    : std_logic;
  signal iaout                 : std_logic_vector(31 DOWNTO 0);
  signal spin                  : std_logic_vector(31 DOWNTO 0);
  signal spout                 : std_logic_vector(31 DOWNTO 0);
  signal wsp                   : std_logic;

  -- Segment 1 - FETCH and DECODE
  signal s1_inmediate          : std_logic_vector(31 downto 0);
  signal s1_opcode             : std_logic_vector(7 downto 0);
  signal s1_inmediate_bit      : std_logic;
  signal s1_long_inmediate_bit : std_logic;
  signal s1_rd                 : std_logic_vector(3 downto 0);
  signal s1_rs                 : std_logic_vector(3 downto 0);
  signal s1_rn                 : std_logic_vector(3 downto 0);
  signal s1_format             : std_logic_vector(1 downto 0);

  -- Segment 2 - DECODE 2
  signal s2_inmediate          : std_logic_vector(31 downto 0);
  signal s2_opcode             : std_logic_vector(7 downto 0);
  signal s2_inmediate_bit      : std_logic;
  signal s2_rd                 : std_logic_vector(3 downto 0);
  signal s2_rs                 : std_logic_vector(3 downto 0);
  signal s2_rn                 : std_logic_vector(3 downto 0);
  signal s2_format             : std_logic_vector(1 downto 0);

begin

  -- Connect Registers file
  REG_FILE : REGISTERS_FILE
    port map (
      NRST    => nRST,
      CLK     => CLK,
      R1_SEL  => r1_sel,
      R2_SEL  => r2_sel,
      R3_SEL  => r3_sel,
      R1OUT   => r1out,
      R2OUT   => r2out,
      R3OUT   => r3out,
      DATAIN1 => datain1,
      DATAIN2 => datain2,
      WE1     => we1,
      WE2     => we2,
      FIN     => fin,
      FOUT    => fout,
      WF      => wf,
      IAOUT   => iaout,
      SPIN    => spin,
      SPOUT   => spout,
      WSP     => wsp
    );

  process (nRST, CLK) is
  begin

    if (nRST = '0') then
      pc <= X"0000_0000";

      I_WRSTB <= '0';

      r1_sel  <= B"0000";
      r2_sel  <= B"0000";
      r3_sel  <= B"0000";
      r1out   <= X"0000_0000";
      r2out   <= X"0000_0000";
      r3out   <= X"0000_0000";
      datain1 <= X"0000_0000";
      datain2 <= X"0000_0000";
      we1     <= '0';
      we2     <= '0';
      fin     <= X"0000_0000";
      fout    <= X"0000_0000";
      wf      <= '0';
      iaout   <= X"0000_0000";
      spin    <= X"0000_0000";
      spout   <= X"0000_0000";
      wsp     <= '0';
    elsif (CLK'event and CLK = '1' AND nRST = '1') then
      pc <= pc + X"0000_0004";
    end if;

  end process;

  FETCH_AND_DECODE : process (CLK) is

    variable inmediate_bit      : std_logic := '0';
    variable long_inmediate_bit : std_logic := '0';
    variable format             : std_logic_vector(1 downto 0) := B"00";

  begin

    if (nRST = '0') then
      s1_inmediate          <= X"0000_0000";
      s1_opcode             <= X"00";
      s1_inmediate_bit      <= '0';
      s1_long_inmediate_bit <= '0';
      s1_rd                 <= (3 downto 0 => '0');
      s1_rs                 <= (3 downto 0 => '0');
      s1_rn                 <= (3 downto 0 => '0');
      s1_format             <= B"00";
    elsif (CLK'event and CLK = '1') then
      if (s1_inmediate_bit = '1' and s1_long_inmediate_bit = '1') then
        -- Inserts a NOP
        s1_inmediate          <= X"0000_0000";
        s1_opcode             <= X"00";
        s1_inmediate_bit      <= '0';
        s1_long_inmediate_bit <= '0';
        s1_rd                 <= (3 downto 0 => '0');
        s1_rs                 <= (3 downto 0 => '0');
        s1_rn                 <= (3 downto 0 => '0');
        s1_format             <= B"00";
      else
        s1_opcode <= I_DATAIN(31 downto 24);
        s1_rd     <= I_DATAIN(21 downto 18);
        s1_rs     <= I_DATAIN(17 downto 14);
        s1_rn     <= I_DATAIN(3 downto 0);

        if (I_DATAIN(31) = '1') then
          format := B"11";
        elsif (I_DATAIN(30) = '1') then
          format := B"10";
        elsif (I_DATAIN(29) = '1') then
          format := B"01";
        else
          format := B"00";
        end if;
        inmediate_bit      := I_DATAIN(23);
        long_inmediate_bit := I_DATAIN(22);

        if (inmediate_bit = '1' and long_inmediate_bit = '0') then
          if (format = B"11") then
            s1_inmediate <= (31 downto 14 => I_DATAIN(13)) & I_DATAIN(13 downto 0);
          elsif (format = B"10") then
            s1_inmediate <= (31 downto 18 => I_DATAIN(17)) & I_DATAIN(17 downto 0);
          elsif (format = B"01") then
            s1_inmediate <= (31 downto 22 => I_DATAIN(21)) & I_DATAIN(21 downto 0);
          else
            s1_inmediate <= X"0000_0000";
          end if;
        else
          s1_inmediate <= I_DATAIN;
        end if;

        s1_format             <= format;
        s1_inmediate_bit      <= inmediate_bit;
        s1_long_inmediate_bit <= long_inmediate_bit;
      end if;
    end if;

  end process FETCH_AND_DECODE;

  DECODE2 : process (CLK) is
  begin

    if (nRST = '0') then
      s2_inmediate     <= X"0000_0000";
      s2_opcode        <= X"00";
      s2_inmediate_bit <= '0';
      s2_rd            <= (3 downto 0 => '0');
      s2_rs            <= (3 downto 0 => '0');
      s2_rn            <= (3 downto 0 => '0');
      s2_format        <= B"00";
    elsif (CLK'event and CLK = '1') then
      if (s1_inmediate_bit = '1' and s1_long_inmediate_bit = '1') then
        s2_inmediate <= I_DATAIN;
      else
        s2_inmediate <= s1_inmediate;
      end if;
      s2_opcode        <= s1_opcode;
      s2_inmediate_bit <= s1_inmediate_bit;
      s2_rd            <= s1_rd;
      s2_rs            <= s1_rs;
      s2_rn            <= s1_rn;
      s2_format        <= s1_format;
    end if;

  end process DECODE2;

  EXECUTE : process (CLK) is

    constant mov : std_logic_vector(7 downto 0) := X"40";

  begin

    case s2_opcode is

      when mov =>
        r1_sel <= s2_rd;

        if (s2_inmediate_bit = '1') then
          datain1 <= s2_inmediate;
        else
          r3_sel  <= s2_rs;
          datain1 <= r3out;
        end if;

        we1 <= '1';
        we2 <= '0';
        wf  <= '0';
        wsp <= '0';

      when others =>
        -- NOP
        r1_sel  <= B"0000";
        r2_sel  <= B"0000";
        r3_sel  <= B"0000";
        r1out   <= X"0000_0000";
        r2out   <= X"0000_0000";
        r3out   <= X"0000_0000";
        datain1 <= X"0000_0000";
        datain2 <= X"0000_0000";
        we1     <= '0';
        we2     <= '0';
        fin     <= X"0000_0000";
        fout    <= X"0000_0000";
        wf      <= '0';
        iaout   <= X"0000_0000";
        spin    <= X"0000_0000";
        spout   <= X"0000_0000";
        wsp     <= '0';

    end case;

  end process EXECUTE;

  -- Assign PC address
  I_ADDR <= pc;

end architecture BEHAVIORAL;
