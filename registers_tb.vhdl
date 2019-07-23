-- Code your testbench here

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.numeric_std_unsigned.all;

entity REG_FILE_TB is
  -- empty
end entity;

architecture BEHAVIORAL of REG_FILE_TB is

  signal clk            : std_logic;
  signal nrst           : std_logic;
  -- Registers selector
  signal r1_sel         : std_logic_vector(3 DOWNTO 0);
  signal r2_sel         : std_logic_vector(3 DOWNTO 0);
  signal r3_sel         : std_logic_vector(3 DOWNTO 0);
  -- Data output
  signal r1out          : std_logic_vector(31 DOWNTO 0);
  signal r2out          : std_logic_vector(31 DOWNTO 0);
  signal r3out          : std_logic_vector(31 DOWNTO 0);
  -- Data input
  signal datain1        : std_logic_vector(31 DOWNTO 0);
  signal datain2        : std_logic_vector(31 DOWNTO 0);
  signal we1            : std_logic;
  signal we2            : std_logic;
  -- Flags in/out
  signal fin            : std_logic_vector(31 DOWNTO 0);
  signal fout           : std_logic_vector(31 DOWNTO 0);
  signal wf             : std_logic;
  -- IA out
  signal iaout          : std_logic_vector(31 DOWNTO 0);
  -- Stack in/out
  signal spin           : std_logic_vector(31 DOWNTO 0);
  signal spout          : std_logic_vector(31 DOWNTO 0);
  signal wsp            : std_logic;
  signal opa            : std_logic_vector(31 downto 0);

  -- DUT component

  component REG_FILE is
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

  constant clk_period : time := 10 ns;
  signal end_simulation : boolean := false;

begin

  -- Connect DUT
  UUT : REG_FILE
    port map (CLK, nRST, R1_SEL, R2_SEL, R3_SEL, R1OUT, R2OUT, R3OUT, DATAIN1, DATAIN2, WE1, WE2, FIN, FOUT, WF, IAOUT, SPIN, SPOUT, WSP);

  CLK_PROCESS : process
  begin

    while (not end_simulation) loop
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
    end loop;
    wait;

  end process CLK_PROCESS;

  STIM : process
  begin

    -- "Reset"
    nrst    <= '0';
    r1_sel  <= B"0000";
    r2_sel  <= B"0000";
    r3_sel  <= B"0000";
    datain1 <= X"0000_0000";
    datain2 <= X"0000_0000";
    we1     <= '0';
    we2     <= '0';
    fin     <= X"0000_0000";
    wf      <= '0';
    spin    <= X"0000_0000";
    wsp     <= '0';
    wait for clk_period;
    nrst <= '1';
    wait for clk_period;

    assert r1out=x"0000_0000" and r2out=x"0000_0000" and r3out=x"0000_0000" and
      fout=x"0000_0000" and spout=x"0000_0000"
      report "Reset failed"
      severity failure;

    -- R1 in/out
    for i in 0 to 15 loop
      datain1 <= std_logic_vector(to_unsigned(i, datain1'length));
      r1_sel  <= std_logic_vector(to_unsigned(i, r1_sel'length));
      we1     <= '1';
      wait for clk_period;
    end loop;
    we1 <= '0';

    for i in 0 to 15 loop
      r1_sel <= std_logic_vector(to_unsigned(i, r1_sel'length));
      wait for clk_period;
      assert r1out=std_logic_vector(to_unsigned(i, r1out'length))
        report "Write/Read via datain1/r1out failed"
        severity failure;
    end loop;

    -- R2 in/out
    for i in 0 to 15 loop
      datain2 <= std_logic_vector(to_unsigned(i * 16, datain2'length));
      r2_sel  <= std_logic_vector(to_unsigned(i, r2_sel'length));
      we2     <= '1';
      wait for clk_period;
    end loop;
    we2 <= '0';

    for i in 0 to 15 loop
      r2_sel <= std_logic_vector(to_unsigned(i, r2_sel'length));
      wait for clk_period;
      assert r2out=std_logic_vector(to_unsigned(i * 16, r2out'length))
        report "Write/Read via datain2/r2out failed"
        severity failure;
    end loop;

    -- R3 out
    for i in 0 to 15 loop
      r3_sel <= std_logic_vector(to_unsigned(i, r3_sel'length));
      wait for clk_period;
      assert r3out=std_logic_vector(to_unsigned(i * 16, r3out'length))
        report "Read via r3out failed"
        severity failure;
    end loop;

    wait for clk_period;
    end_simulation <= true;
    assert false
      report "Test done. Open EPWave to see signals."
      severity note;
    wait;

  end process STIM;

end architecture BEHAVIORAL;

