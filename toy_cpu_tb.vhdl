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
    port(
          nRST : in std_logic;
          CLK : in std_logic;
          I_ADDR : out std_logic_vector(31 downto 0);
          I_WRSTB : out std_logic;
          I_DATAOUT : out std_logic_vector(31 downto 0);
          I_DATAIN : in  std_logic_vector(31 downto 0)
        );
  end component;

  component Memoria
    generic (
              C_FILENAME : string;
              C_MEM_SIZE : integer;
              C_LITTLE_ENDIAN : boolean
            );
    port (
           CLK : in std_logic;
           nRST : in std_logic;
           ADDR : in std_logic_vector(31 downto 0);
           WR : in std_logic;
           DATAI : in std_logic_vector(31 downto 0);
           DATAO : out std_logic_vector(31 downto 0)
         );
  end component;

-- Entradas al micro
  signal nRST : std_logic := '0';
  signal CLK : std_logic := '0';

-- Instruction memory
  SIGNAL I_ADDR      : std_logic_vector(31 downto 0);
  SIGNAL I_WRSTB     : std_logic;
  SIGNAL I_DATAOUT   : std_logic_vector(31 downto 0);
  SIGNAL I_DATAIN    : std_logic_vector(31 downto 0);

--

  constant CLK_PERIOD : TIME := 10 ns;
  signal END_SIMULATION : boolean := false;


begin

  -- Connect Unit Under Test
  UUT: TOY_CPU port map(
                         nRST => nRST,
                         CLK => CLK,
                         I_ADDR => I_ADDR,
                         I_WRSTB => I_WRSTB,
                         I_DATAOUT => I_DATAOUT,
                         I_DATAIN => I_DATAIN
                       );

  -- Connect Instrucction RAM
  Inst_Mem_Instr : memoria
  generic map (
                C_FILENAME => "program",
                C_MEM_SIZE => 1024,
                C_LITTLE_ENDIAN => false
              ) port map (
                           CLK => CLK,
                           nRST => NRST,
                           ADDR => I_ADDR,
                           WR => I_WRSTB,
                           DATAI => I_DATAOUT,
                           DATAO => I_DATAIN
                         );


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

  stim_proc: process
  begin
    -- "Reset"
    nRST <= '0';
    wait for CLK_PERIOD;

    -- Clock!
    nRST <= '1';
    wait for CLK_PERIOD*7;

    -- Very reset
    nRST <= '0';
    wait for CLK_PERIOD;
    assert (I_ADDR = X"0000_0000")
    report "Failed reset! Invalid I. address"
    severity error;

    -- Clock!
    nRST <= '1';
    wait for CLK_PERIOD*100;

    END_SIMULATION <= true;
    assert false
    report "Test done. Open EPWave to see signals."
    severity note;
    wait;
  end process;

end BEV;

