-- Generic naive unsigned multiplicator
-- Does a bitsxbits to 2*bits output using classic long multiplication
-- Number of clock cycles is infuction of the number of bits for any number with this method
-- Clocks = bits + 2 ?
-- Created by Luis Panadero Guardeño
-- MIT License

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  use IEEE.NUMERIC_STD_UNSIGNED.all;

-- unsigned multiplicator entity

entity UMUL is
  generic (
    BITS : integer := 32
  );
  port (
    CLK        : in    std_logic;                           -- CPU clock
    START      : in    std_logic;                           -- Start multiplication os OPA x OPB
    OPA        : in    std_logic_vector(bits - 1 downto 0); -- Operator A
    OPB        : in    std_logic_vector(bits - 1 downto 0); -- Operator B
    OUTPUT_LSB : out   std_logic_vector(bits - 1 downto 0); -- Lower 32 bits of the output
    OUTPUT_MSB : out   std_logic_vector(bits - 1 downto 0); -- Highest 32 bits of the output
    FINISH     : out   std_logic                            -- Set to high to indicate when the multiplication has finished
  );
end entity UMUL;

-- unsigned multiplicator architecture

architecture UMUL_ARCH of UMUL is

  signal enabled      : std_logic; -- Internal control of is doing a multiplication
  signal multiplicand : std_logic_vector(bits * 2 - 1 downto 0);
  signal multiplier   : std_logic_vector(bits * 2 - 1 downto 0);
  signal acumulator   : std_logic_vector(bits * 2 - 1 downto 0);

begin

  -- Multiplication process
  -- Start the multiplication when start is togle high
  MULTIPLICATOR : process (start, clk) is

    variable counter : integer range 0 to bits; -- Count binary digit

  begin

    if (clk'event and clk = '1') then
      if (start = '1' AND enabled /= '1') then
        -- re-start multiplication
        enabled      <= '1';
        multiplicand <= (bits - 1 downto 0 => '0') & opa;
        multiplier   <= (bits - 1 downto 0 => '0') & opb;
        acumulator   <= (others => '0');
        finish       <= '0';
        counter := 0;
      elsif (enabled = '1') then
        -- do a step
        if (counter <= bits - 1) then
          -- Acumulate
          if (multiplier(0) = '1') then
            acumulator <= acumulator + multiplicand;
          end if;
          -- shift multiplicand and multipler
          multiplicand <= multiplicand(bits * 2 - 2 downto 0) & '0';
          multiplier   <= '0' & multiplier(bits * 2 - 1 downto 1);
          counter := counter + 1;
        else
          -- finish
          enabled    <= '0';
          finish     <= '1';
          output_lsb <= acumulator(bits - 1 downto 0);
          output_msb <= acumulator(bits * 2 - 1 downto bits);
        end if;
      end if;
    end if;

  end process MULTIPLICATOR;

end architecture UMUL_ARCH;

