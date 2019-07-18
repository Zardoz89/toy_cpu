-- Created by Luis Panadero Guardeño
-- Testbench for umul unsigned naive multiplicator

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  use IEEE.NUMERIC_STD_UNSIGNED.all;

entity umul_tb is
-- empty
end entity;

architecture Behavioral of umul_tb is
  signal clk : std_logic := '0';
  signal start : std_logic := '0';
  signal opa : std_logic_vector(31 downto 0) := X"0000_0000";
  signal opb : std_logic_vector(31 downto 0) := X"0000_0000";
  signal output_lsb : std_logic_vector(31 downto 0);
  signal output_msb : std_logic_vector(31 downto 0);
  signal finish : std_logic;

  signal end_simulation : boolean := false;

-- DUT component
  component umul is
    port(
      clk : in std_logic;
      start : in std_logic;
      opa : in std_logic_vector(31 downto 0);
      opb : in std_logic_vector(31 downto 0);
      output_lsb : out std_logic_vector(31 downto 0);
      output_msb : out std_logic_vector(31 downto 0);
      finish : out std_logic);
  end component;

  constant CLK_PERIOD : TIME := 10 ns;
begin
  -- Connect DUT
  UUT: umul port map(clk, start, opa, opb, output_lsb, output_msb, finish);

  Clk_process: process
  begin
    while (not end_simulation) loop
      clk <= '0';
      wait for CLK_PERIOD/2;
      clk <= '1';
      wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  Stim_proc: process
  begin
    wait for CLK_PERIOD;

    -- Test 0x0 == 0
    opa <= X"0000_0000";
    opb <= X"0000_0000";
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';

    wait for CLK_PERIOD*34;

    assert output_lsb = x"0000_0000" AND output_msb = x"0000_0000"
        report "0x0 must be 0 !"
        severity failure;

    -- Test 1x1 == 1
    opa <= X"0000_0001";
    opb <= X"0000_0001";
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';

    wait for CLK_PERIOD*34;

    assert output_lsb = x"0000_0001" AND output_msb = x"0000_0000"
        report "1x1 must be 1 !"
        severity failure;

    -- Test BEBA_CAFEx1 == BEBA_CAFE
    opa <= X"BEBA_CAFE";
    opb <= X"0000_0001";
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';

    wait for CLK_PERIOD*34;

    assert output_lsb = x"BEBA_CAFE" AND output_msb = x"0000_0000"
        report "BEBACAFEx1 must be BEBACAFE !"
        severity failure;

    -- Test 1xBEBA_CAFE == BEBA_CAFE
    opa <= X"0000_0001";
    opb <= X"BEBA_CAFE";
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';

    wait for CLK_PERIOD*34;

    assert output_lsb = x"BEBA_CAFE" AND output_msb = x"0000_0000"
        report "1xBEBACAFE must be BEBACAFE !"
        severity failure;

    end_simulation <= true;
    assert false
    report "Test done. Open EPWave to see signals."
    severity note;
    wait;
  end process;
end Behavioral;
