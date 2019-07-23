-- Created by Luis Panadero Guardeño
-- Testbench for umul unsigned naive multiplicator

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  use IEEE.NUMERIC_STD_UNSIGNED.all;

entity UMUL_TB is
  -- empty
end entity;

architecture BEHAVIORAL of UMUL_TB is

  signal clk            : std_logic := '0';
  signal start          : std_logic := '0';
  signal opa            : std_logic_vector(31 downto 0) := X"0000_0000";
  signal opb            : std_logic_vector(31 downto 0) := X"0000_0000";
  signal output_lsb     : std_logic_vector(31 downto 0);
  signal output_msb     : std_logic_vector(31 downto 0);
  signal finish         : std_logic;

  signal end_simulation : boolean := false;

  -- DUT component

  component UMUL is
    port (
      CLK        : in    std_logic;
      START      : in    std_logic;
      OPA        : in    std_logic_vector(31 downto 0);
      OPB        : in    std_logic_vector(31 downto 0);
      OUTPUT_LSB : out   std_logic_vector(31 downto 0);
      OUTPUT_MSB : out   std_logic_vector(31 downto 0);
      FINISH     : out   std_logic
    );
  end component;

  constant clk_period : time := 10 ns;

begin

  -- Connect DUT
  UUT : UMUL
    port map (clk, start, opa, opb, output_lsb, output_msb, finish);

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

  STIM_PROC : process
  begin

    wait for clk_period;

    -- Test 0x0 == 0
    opa   <= X"0000_0000";
    opb   <= X"0000_0000";
    start <= '1';
    wait for clk_period;
    start <= '0';
    assert finish = '0'
      report "finish signal isn't togle to false before finishing calculation"
      severity failure;

    wait until finish'event AND finish ='1'; --for CLK_PERIOD*34;

    assert output_lsb = x"0000_0000" AND output_msb = x"0000_0000"
      report "0x0 must be 0 !"
      severity failure;

    -- Test 1x1 == 1
    wait for clk_period;
    opa   <= X"0000_0001";
    opb   <= X"0000_0001";
    start <= '1';
    wait for clk_period;
    start <= '0';

    assert finish = '0'
      report "finish signal isn't togle to false before finishing calculation"
      severity failure;

    wait until finish'event AND finish ='1';

    assert output_lsb = x"0000_0001" AND output_msb = x"0000_0000"
      report "1x1 must be 1 !"
      severity failure;

    -- Test BEBA_CAFEx1 == BEBA_CAFE
    wait for clk_period;
    opa   <= X"BEBA_CAFE";
    opb   <= X"0000_0001";
    start <= '1';
    wait for clk_period;
    start <= '0';

    assert finish = '0'
      report "finish signal isn't togle to false before finishing calculation"
      severity failure;

    wait until finish'event AND finish ='1';

    assert output_lsb = x"BEBA_CAFE" AND output_msb = x"0000_0000"
      report "BEBACAFEx1 must be BEBACAFE !"
      severity failure;

    -- Test 1xBEBA_CAFE == BEBA_CAFE
    wait for clk_period;
    opa   <= X"0000_0001";
    opb   <= X"BEBA_CAFE";
    start <= '1';
    wait for clk_period;
    start <= '0';

    assert finish = '0'
      report "finish signal isn't togle to false before finishing calculation"
      severity failure;

    wait until finish'event AND finish ='1';

    assert output_lsb = x"BEBA_CAFE" AND output_msb = x"0000_0000"
      report "1xBEBACAFE must be BEBACAFE !"
      severity failure;

    -- Test 27BE_10A5xBEBA_CAFE == 1D9C_0FF5_F598_B5B6
    wait for clk_period;
    opa   <= X"27BE_10A5";
    opb   <= X"BEBA_CAFE";
    start <= '1';
    wait for clk_period;
    start <= '0';

    assert finish = '0'
      report "finish signal isn't togle to false before finishing calculation"
      severity failure;

    wait until finish'event AND finish ='1';

    assert output_lsb = x"F598_B5B6" AND output_msb = x"1D9C_0FF5"
      report "27BE_10A5xBEBA_CAFE must be 1D9C_0FF5_F598_B5B6 !"
      severity failure;

    -- Test BEBA_CAFEx27BE_10A5 == 1D9C_0FF5_F598_B5B6
    wait for clk_period;
    opa   <= X"BEBA_CAFE";
    opb   <= X"27BE_10A5";
    start <= '1';
    wait for clk_period;
    start <= '0';

    assert finish = '0'
      report "finish signal isn't togle to false before finishing calculation"
      severity failure;

    wait until finish'event AND finish ='1';

    assert output_lsb = x"F598_B5B6" AND output_msb = x"1D9C_0FF5"
      report "BEBA_CAGEx27BE_10A5 must be 1D9C_0FF5_F598_B5B6 !"
      severity failure;

    end_simulation <= true;
    assert false
      report "Test done. Open EPWave to see signals."
      severity note;
    wait;

  end process STIM_PROC;

end architecture BEHAVIORAL;
