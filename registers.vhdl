-- Created by Luis Panadero Guardeño
-- MIT License

LIBRARY ieee;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.all;
    USE ieee.numeric_std_unsigned.all;


-- Register file entity
ENTITY REG_FILE IS
    PORT(
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
END REG_FILE;


architecture Behavioral of REG_FILE is
    TYPE reg16 IS ARRAY    (15 DOWNTO 0) OF STD_LOGIC_VECTOR (31 downto 0);
    SIGNAL registers : reg16;

    constant SP      : integer := 13;
    constant IA       : integer := 14;
    constant FLAGS  : integer := 15;

begin

    -- Write values to registers
    process( DATAIN1, DATAIN2, R1_SEL , R2_SEL, WE1, WE2,
            FIN, WF, SPIN, WSP, CLK, nRST)
    begin
        if nRST = '0' then
            -- RESET
            for i in 0 to 15 loop
                registers(i) <=  (others => '0');
            end loop;

        elsif WF = '1' AND rising_EDGE (CLK) then
            -- Overwrite Flag register
            registers(FLAGS) <= FIN;

        elsif WSP = '1' AND rising_EDGE (CLK) then
            -- Overwrite Stack register
            registers(SP) <= FIN;

        elsif WE1 = '1' AND rising_EDGE (CLK) then
            registers(to_integer(R1_SEL)) <= DATAIN1;

        elsif WE2 = '1' AND rising_EDGE (CLK) then
            registers(to_integer(R2_SEL)) <= DATAIN2;
        end if;
    end process;

    -- Update outs
    R1OUT <= registers(to_integer(R1_SEL));
    R2OUT <= registers(to_integer(R2_SEL));
    R3OUT <= registers(to_integer(R3_SEL));

    FOUT <= registers(FLAGS);
    IAOUT <= registers(IA);
    SPOUT <= registers(SP);

end Behavioral;


