-- 32 bit toy CPU
-- Created by Luis Panadero Guardeño
-- MIT License

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.numeric_std_unsigned.all;

-- TOY_CPU entity
entity TOY_CPU is
  port(
        nRST : in STD_LOGIC;
        CLK : in STD_LOGIC;
        I_ADDR : out std_logic_vector(31 downto 0);
        I_WRSTB : out std_logic;
        I_DATAOUT : out std_logic_vector(31 downto 0);
        I_DATAIN : in  std_logic_vector(31 downto 0)    -- Instruccion
      );
end TOY_CPU;

-- ALU architecture
architecture Behavioral OF TOY_CPU IS
  component REGISTERS_FILE is
    port(
          CLK : in  STD_LOGIC;
          nRST : in  STD_LOGIC;
          -- Registers selector
          R1_SEL : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          R2_SEL : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          R3_SEL : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          -- Data output
          R1OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          R2OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          R3OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          -- Data input
          DATAIN1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          DATAIN2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          WE1 : in  STD_LOGIC;
          WE2 : in  STD_LOGIC;
          -- Flags in/out
          FIN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          FOUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          WF : IN STD_LOGIC;
          -- IA out
          IAOUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          -- Stack in/out
          SPIN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          SPOUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          WSP : IN STD_LOGIC
        );
  end component;

  signal PC : STD_LOGIC_VECTOR (31 DOWNTO 0);

    -- Registers file
  signal R1_SEL : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal R2_SEL : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal R3_SEL : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal R1OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal R2OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal R3OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal DATAIN1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal DATAIN2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal WE1 : STD_LOGIC;
  signal WE2 : STD_LOGIC;
  signal FIN : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal FOUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal WF : STD_LOGIC;
  signal IAOUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal SPIN : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal SPOUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal WSP : STD_LOGIC;

    -- Segment 1 - FETCH and DECODE
  signal S1_INMEDIATE : STD_LOGIC_VECTOR (31 downto 0);
  signal S1_OPCODE : STD_LOGIC_VECTOR (7 downto 0);
  signal S1_INMEDIATE_BIT : STD_LOGIC;
  signal S1_LONG_INMEDIATE_BIT : STD_LOGIC;
  signal S1_RD : STD_LOGIC_VECTOR (3 downto 0);
  signal S1_RS : STD_LOGIC_VECTOR (3 downto 0);
  signal S1_RN : STD_LOGIC_VECTOR (3 downto 0);
  signal S1_FORMAT : STD_LOGIC_VECTOR (1 downto 0);

    -- Segment 2 - DECODE 2
  signal S2_INMEDIATE : STD_LOGIC_VECTOR (31 downto 0);
  signal S2_OPCODE : STD_LOGIC_VECTOR (7 downto 0);
  signal S2_INMEDIATE_BIT : STD_LOGIC;
  signal S2_RD : STD_LOGIC_VECTOR (3 downto 0);
  signal S2_RS : STD_LOGIC_VECTOR (3 downto 0);
  signal S2_RN : STD_LOGIC_VECTOR (3 downto 0);
  signal S2_FORMAT : STD_LOGIC_VECTOR (1 downto 0);

begin
    -- Connect Registers file
  REG_FILE: REGISTERS_FILE port map(
                                     nRST => nRST,
                                     CLK => CLK,
                                     R1_SEL => R1_SEL,
                                     R2_SEL => R2_SEL,
                                     R3_SEL => R3_SEL,
                                     R1OUT => R1OUT,
                                     R2OUT => R2OUT,
                                     R3OUT => R3OUT,
                                     DATAIN1 => DATAIN1,
                                     DATAIN2 => DATAIN2,
                                     WE1 => WE1,
                                     WE2 => WE2,
                                     FIN => FIN,
                                     FOUT => FOUT,
                                     WF => WF,
                                     IAOUT => IAOUT,
                                     SPIN => SPIN,
                                     SPOUT => SPOUT,
                                     WSP => WSP
                                   );

  process (nRST, CLK)
  begin
    if (nRST = '0') THEN
      PC <= X"0000_0000";

      I_WRSTB <= '0';

      R1_SEL <= B"0000";
      R2_SEL <= B"0000";
      R3_SEL <= B"0000";
      R1OUT <= X"0000_0000";
      R2OUT <= X"0000_0000";
      R3OUT <= X"0000_0000";
      DATAIN1 <= X"0000_0000";
      DATAIN2 <= X"0000_0000";
      WE1 <= '0';
      WE2 <= '0';
      FIN <= X"0000_0000";
      FOUT <= X"0000_0000";
      WF <= '0';
      IAOUT <= X"0000_0000";
      SPIN <= X"0000_0000";
      SPOUT <= X"0000_0000";
      WSP <= '0';

    elsif (rising_edge(CLK) AND nRST = '1') THEN
      PC <= PC + X"0000_0004";
    end if;
  end process;

  FETCH_AND_DECODE: process (CLK)
    variable INMEDIATE_BIT : STD_LOGIC := '0';
    variable LONG_INMEDIATE_BIT : STD_LOGIC := '0';
    variable FORMAT : STD_LOGIC_VECTOR (1 downto 0) := B"00";
  begin
    if (nRST = '0') then
      S1_INMEDIATE <= X"0000_0000";
      S1_OPCODE <= X"00";
      S1_INMEDIATE_BIT <= '0';
      S1_LONG_INMEDIATE_BIT <= '0';
      S1_RD <= (3 downto 0 => '0');
      S1_RS <= (3 downto 0 => '0');
      S1_RN <= (3 downto 0 => '0');
      S1_FORMAT <= B"00";


    elsif (rising_edge(CLK)) then
      IF S1_INMEDIATE_BIT = '1' and S1_LONG_INMEDIATE_BIT = '1' THEN
              -- Inserts a NOP
        S1_INMEDIATE <= X"0000_0000";
        S1_OPCODE <= X"00";
        S1_INMEDIATE_BIT <= '0';
        S1_LONG_INMEDIATE_BIT <= '0';
        S1_RD <= (3 downto 0 => '0');
        S1_RS <= (3 downto 0 => '0');
        S1_RN <= (3 downto 0 => '0');
        S1_FORMAT <= B"00";

      else
        S1_OPCODE <= I_DATAIN(31 downto 24);
        S1_RD <= I_DATAIN(21 downto 18);
        S1_RS <= I_DATAIN(17 downto 14);
        S1_RN <= I_DATAIN(3 downto 0);

        if (I_DATAIN(31) = '1') then
          FORMAT := B"11";
          elsif (I_DATAIN(30) = '1') then
            FORMAT := B"10";
            elsif (I_DATAIN(29) = '1') then
              FORMAT := B"01";
              else
                FORMAT := B"00";
                end if;
                INMEDIATE_BIT := I_DATAIN(23);
                LONG_INMEDIATE_BIT := I_DATAIN(22);

                if INMEDIATE_BIT = '1' and LONG_INMEDIATE_BIT = '0' THEN
                  IF FORMAT = B"11" then
                    S1_INMEDIATE <= (31 downto 14 => I_DATAIN(13)) & I_DATAIN(13 downto 0);
                  elsif FORMAT = B"10" THEN
                    S1_INMEDIATE <= (31 downto 18 => I_DATAIN(17)) & I_DATAIN(17 downto 0);
                  elsif FORMAT = B"01" THEN
                    S1_INMEDIATE <= (31 downto 22 => I_DATAIN(21)) & I_DATAIN(21 downto 0);
                  else
                    S1_INMEDIATE <= X"0000_0000";
                  end if;
                else
                  S1_INMEDIATE <= I_DATAIN;
                end if;

                S1_FORMAT <= FORMAT;
                S1_INMEDIATE_BIT <= INMEDIATE_BIT;
                S1_LONG_INMEDIATE_BIT <= LONG_INMEDIATE_BIT;
              end if;
            end if;
          end process;

          DECODE2 : process (CLK)
          begin
            if (nRST = '0') then
              S2_INMEDIATE <= X"0000_0000";
              S2_OPCODE <= X"00";
              S2_INMEDIATE_BIT <= '0';
              S2_RD <= (3 downto 0 => '0');
              S2_RS <= (3 downto 0 => '0');
              S2_RN <= (3 downto 0 => '0');
              S2_FORMAT <= B"00";

            elsif (rising_edge(CLK)) then
              if S1_INMEDIATE_BIT = '1' and S1_LONG_INMEDIATE_BIT = '1' then
                S2_INMEDIATE <= I_DATAIN;
              else
                S2_INMEDIATE <= S1_INMEDIATE;
              end if;
              S2_OPCODE <= S1_OPCODE;
              S2_INMEDIATE_BIT <= S1_INMEDIATE_BIT;
              S2_RD <= S1_RD;
              S2_RS <= S1_RS;
              S2_RN <= S1_RN;
              S2_FORMAT <= S1_FORMAT;
            end if;

          end process;

          EXECUTE : process (CLK)
            constant MOV : STD_LOGIC_VECTOR (7 downto 0) := X"40";
          begin

            case S2_OPCODE is
              when MOV =>
                R1_SEL <= S2_RD;
                if S2_INMEDIATE_BIT = '1' then
                  DATAIN1 <= S2_INMEDIATE;
                else
                  R3_SEL <= S2_RS;
                  DATAIN1 <= R3OUT;
                end if;
                WE1 <= '1';
                WE2 <= '0';
                WF <= '0';
                WSP <= '0';

              when others =>
            -- NOP
                R1_SEL <= B"0000";
                R2_SEL <= B"0000";
                R3_SEL <= B"0000";
                R1OUT <= X"0000_0000";
                R2OUT <= X"0000_0000";
                R3OUT <= X"0000_0000";
                DATAIN1 <= X"0000_0000";
                DATAIN2 <= X"0000_0000";
                WE1 <= '0';
                WE2 <= '0';
                FIN <= X"0000_0000";
                FOUT <= X"0000_0000";
                WF <= '0';
                IAOUT <= X"0000_0000";
                SPIN <= X"0000_0000";
                SPOUT <= X"0000_0000";
                WSP <= '0';
            end case;

          end process;

    -- Assign PC address
          I_ADDR <= PC;

        end Behavioral;
