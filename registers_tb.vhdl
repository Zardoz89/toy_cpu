-- Code your testbench here
LIBRARY ieee;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.all;
    USE ieee.numeric_std_unsigned.all;

ENTITY REG_FILE_TB IS
-- empty
END ENTITY;

architecture Behavioral of REG_FILE_TB is
signal CLK : STD_LOGIC;
signal nRST : STD_LOGIC;
-- Registers selector
signal R1_SEL : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal R2_SEL : STD_LOGIC_VECTOR(3 DOWNTO 0);
signal R3_SEL : STD_LOGIC_VECTOR(3 DOWNTO 0);
-- Data output
signal R1OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal R2OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal R3OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
-- Data input
signal DATAIN1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal DATAIN2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal WE1 : STD_LOGIC;
signal WE2 : STD_LOGIC;
-- Flags in/out
signal FIN : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal FOUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal WF : STD_LOGIC;
-- IA out
signal IAOUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
-- Stack in/out
signal SPIN : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal SPOUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal WSP : STD_LOGIC;
signal OPA : STD_LOGIC_VECTOR(31 downto 0);

-- DUT component
component REG_FILE is
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

constant CLK_PERIOD : TIME := 10 ns;
signal END_SIMULATION : boolean := false;

begin

  -- Connect DUT
  UUT: REG_FILE port map(CLK, nRST, R1_SEL, R2_SEL, R3_SEL, R1OUT,R2OUT, R3OUT, DATAIN1, DATAIN2, WE1, WE2, FIN, FOUT, WF, IAOUT, SPIN, SPOUT, WSP);


  CLK_PROCESS: process
  begin
    while (not END_SIMULATION) loop
      CLK <= '0';
      wait for CLK_PERIOD/2;
      CLK <= '1';
      wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  stim: process
  begin
    -- "Reset"
    nRST <= '0';
    R1_SEL <= B"0000";
    R2_SEL <= B"0000";
    R3_SEL <= B"0000";
    DATAIN1 <= X"0000_0000";
    DATAIN2 <= X"0000_0000";
    WE1 <= '0';
    WE2 <= '0';
    FIN <= X"0000_0000";
    WF <= '0';
    SPIN <= X"0000_0000";
    WSP <= '0';
    wait for CLK_PERIOD;
    nRST <= '1';
    wait for CLK_PERIOD;

    assert R1OUT=x"0000_0000" and R2OUT=x"0000_0000" and R3OUT=x"0000_0000" and
      FOUT=x"0000_0000" and SPOUT=x"0000_0000"
        report "Reset failed"
        severity failure;

    -- R1 in/out
    for i in 0 to 15 loop
      DATAIN1 <= std_logic_vector(to_unsigned(i, DATAIN1'length));
      R1_SEL <= std_logic_vector(to_unsigned(i, R1_SEL'length));
      WE1 <= '1';
      wait for CLK_PERIOD;
    end loop;
    WE1 <= '0';

    for i in 0 to 15 loop
      R1_SEL <= std_logic_vector(to_unsigned(i, R1_SEL'length));
      wait for CLK_PERIOD;
      assert R1OUT=std_logic_vector(to_unsigned(i, R1OUT'length))
        report "Write/Read via DATAIN1/R1OUT failed"
        severity failure;
    end loop;

    -- R2 in/out
    for i in 0 to 15 loop
      DATAIN2 <= std_logic_vector(to_unsigned(i*16, DATAIN2'length));
      R2_SEL <= std_logic_vector(to_unsigned(i, R2_SEL'length));
      WE2 <= '1';
      wait for CLK_PERIOD;
    end loop;
    WE2 <= '0';

    for i in 0 to 15 loop
      R2_SEL <= std_logic_vector(to_unsigned(i, R2_SEL'length));
      wait for CLK_PERIOD;
      assert R2OUT=std_logic_vector(to_unsigned(i*16, R2OUT'length))
        report "Write/Read via DATAIN2/R2OUT failed"
        severity failure;
    end loop;

    -- R3 out
    for i in 0 to 15 loop
      R3_SEL <= std_logic_vector(to_unsigned(i, R3_SEL'length));
      wait for CLK_PERIOD;
      assert R3OUT=std_logic_vector(to_unsigned(i*16, R3OUT'length))
        report "Read via R3OUT failed"
        severity failure;
    end loop;


    wait for CLK_PERIOD;
    END_SIMULATION <= true;
    assert false
        report "Test done. Open EPWave to see signals."
        severity note;
    wait;
  end process;


end Behavioral;


