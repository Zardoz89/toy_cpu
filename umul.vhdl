-- 32 bit naive unsigned multiplicator
-- Created by Luis Panadero Guardeño
-- MIT License

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  use IEEE.NUMERIC_STD_UNSIGNED.all;

-- unsigned multiplicator entity
entity umul is
  port(
    clk : in std_logic;
    start : in std_logic;
    opa : in std_logic_vector(31 downto 0);
    opb : in std_logic_vector(31 downto 0);
    output_lsb : out std_logic_vector(31 downto 0);
    output_msb : out std_logic_vector(31 downto 0);
    finish : out std_logic);
end umul;

-- unsigned multiplicator architecture
architecture umul_arch of umul is

  signal enabled : std_logic;
  signal multiplicand : std_logic_vector(63 downto 0);
  signal multiplier : std_logic_vector(63 downto 0);
  signal acumulator : std_logic_vector(63 downto 0);
begin

  Multiplicator: process (start, clk)
  variable counter : integer range 0 to 32;
  begin
    if rising_edge(clk) then
      if (start = '1' AND enabled /= '1') then
        -- re-start multiplication
        enabled <= '1';
        multiplicand <= X"0000_0000" & opa;
        multiplier <= X"0000_0000" & opb;
        acumulator <= X"0000_0000_0000_0000";
        finish <= '0';
        counter := 0;
      elsif (enabled = '1') then
        -- do a step
        if (counter <= 31) then
          -- Acumulate
          if (multiplier(0) = '1') then
            acumulator <= acumulator + multiplicand;
          end if;
          -- shift multiplicand and multipler
          multiplicand <= multiplicand(62 downto 0) & '0';
          multiplier <= '0' & multiplier(63 downto 1);
          counter := counter + 1;
        else
          -- finish
          enabled <= '0';
          finish <= '1';
          output_lsb <= acumulator(31 downto 0);
          output_msb <= acumulator(63 downto 32);
        end if;
      end if;
    end if;
  end process;

end umul_arch;

