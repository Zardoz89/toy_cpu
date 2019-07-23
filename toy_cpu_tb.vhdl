-- Created by Luis Panadero Guardeño
-- Testbench for CPU

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.numeric_std_unsigned.all;

entity TOY_CPU_TB is
  -- empty
end entity;

architecture BEV of TOY_CPU_TB is

  -- DUT component

  component TOY_CPU is
    port (
      NRST      : in    std_logic;
      CLK       : in    std_logic;
      I_ADDR    : out   std_logic_vector(31 downto 0);
      I_WRSTB   : out   std_logic;
      I_DATAOUT : out   std_logic_vector(31 downto 0);
      I_DATAIN  : in    std_logic_vector(31 downto 0)
    );
  end component;

  component MEMORIA is
    generic (
      C_FILENAME      : string;
      C_MEM_SIZE      : integer;
      C_LITTLE_ENDIAN : boolean
    );
    port (
      CLK   : in    std_logic;
      NRST  : in    std_logic;
      ADDR  : in    std_logic_vector(31 downto 0);
      WR    : in    std_logic;
      DATAI : in    std_logic_vector(31 downto 0);
      DATAO : out   std_logic_vector(31 downto 0)
    );
  end component;

  -- Entradas al micro
  signal nrst           : std_logic := '0';
  signal clk            : std_logic := '0';

  -- Instruction memory
  signal i_addr         : std_logic_vector(31 downto 0);
  signal i_wrstb        : std_logic;
  signal i_dataout      : std_logic_vector(31 downto 0);
  signal i_datain       : std_logic_vector(31 downto 0);

  --

  constant clk_period : time := 10 ns;
  signal end_simulation : boolean := false;

begin

  -- Connect Unit Under Test
  UUT : TOY_CPU
    port map (
      NRST      => nrst,
      CLK       => clk,
      I_ADDR    => i_addr,
      I_WRSTB   => i_wrstb,
      I_DATAOUT => i_dataout,
      I_DATAIN  => i_datain
    );

  -- Connect Instrucction RAM
  INST_MEM_INSTR : MEMORIA
    generic map (
      C_FILENAME      => "program",
      C_MEM_SIZE      => 1024,
      C_LITTLE_ENDIAN => false
      ) port map (
        CLK   => clk,
        NRST  => nrst,
        ADDR  => i_addr,
        WR    => i_wrstb,
        DATAI => i_dataout,
        DATAO => i_datain
      );

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

    -- "Reset"
    nrst <= '0';
    wait for clk_period;

    -- Clock!
    nrst <= '1';
    wait for clk_period * 7;

    -- Very reset
    nrst <= '0';
    wait for clk_period;
    assert (i_addr = X"0000_0000")
      report "Failed reset! Invalid I. address"
      severity error;

    -- Clock!
    nrst <= '1';
    wait for clk_period * 100;

    end_simulation <= true;
    assert false
      report "Test done. Open EPWave to see signals."
      severity note;
    wait;

  end process STIM_PROC;

end architecture BEV;

