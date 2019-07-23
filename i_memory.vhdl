
library std;
  use std.textio.all;

library IEEE;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.numeric_std_unsigned.all;
  use ieee.std_logic_textio.all;

entity MEMORIA is
  generic (
    C_FILENAME      : string  := "program";
    C_MEM_SIZE      : integer := 1024;
    C_LITTLE_ENDIAN : boolean := true
  );
  port (
    ADDR  : in    std_logic_vector(31 downto 0);
    DATAI : in    std_logic_vector(31 downto 0);
    DATAO : out   std_logic_vector(31 downto 0);
    WR    : in    std_logic;
    CLK   : in    std_logic;
    NRST  : in    std_logic
  );
end entity MEMORIA;

architecture BEHAVIORAL of MEMORIA is

  type matriz is array(0 to C_MEM_SIZE - 1) of STD_LOGIC_VECTOR(7 downto 0);

  signal ram : matriz;
  signal aux : std_logic_vector(31 downto 0):= (others=>'0');

begin

  process (CLK) is

    variable load         : boolean := true;
    variable address      : std_logic_vector(31 downto 0);
    variable datum        : std_logic_vector(31 downto 0);
    file     TEXTFILE     : text; -- is in C_FILENAME;
    variable current_line : line;

  begin

    if (load) then
      -- primero iniciamos la memoria con ceros
      for i in 0 to C_MEM_SIZE - 1 loop
        ram(i) <= (others => '0');
      end loop;

      -- luego cargamos el archivo en la misma
      file_open(TEXTFILE, C_FILENAME, read_mode);
      while (not endfile (TEXTFILE)) loop
        readline (TEXTFILE, current_line);
        hread(current_line, address);
        hread(current_line, datum);
        assert to_integer(address(30 downto 0))<C_MEM_SIZE
          report "Direccion fuera de rango en el fichero de la memoria"
          severity failure;
        if (C_LITTLE_ENDIAN) then
          ram(to_integer(address(30 downto 0)))       <= datum(31 downto 24);
          ram(to_integer(address(30 downto 0) +'1'))  <= datum(23 downto 16);
          ram(to_integer(address(30 downto 0) +"10")) <= datum(15 downto 8);
          ram(to_integer(address(30 downto 0) +"11")) <= datum(7 downto 0);
        else
          ram(to_integer(address(30 downto 0)))       <= datum(7 downto 0);
          ram(to_integer(address(30 downto 0) +'1'))  <= datum(15 downto 8);
          ram(to_integer(address(30 downto 0) +"10")) <= datum(23 downto 16);
          ram(to_integer(address(30 downto 0) +"11")) <= datum(31 downto 24);
        end if;
      end loop;

      -- por ultimo cerramos el archivo y actualizamos el flag de RAMria cargada
      file_close (TEXTFILE);
      aux <= X"0000_0000";
      load := false;
    elsif (nRST = '0') then
      aux <= X"0000_0000";
    elsif (CLK'event and CLK = '1') then
      if (WR = '1') then
        ram(to_integer(Addr(30 downto 0)))       <= DATAI(31 downto 24);
        ram(to_integer(Addr(30 downto 0) +'1'))  <= DATAI(23 downto 16);
        ram(to_integer(Addr(30 downto 0) +"10")) <= DATAI(15 downto 8);
        ram(to_integer(Addr(30 downto 0) +"11")) <= DATAI(7 downto 0);
      else
        aux(31 downto 24) <= ram(to_integer(ADDR(30 downto 0)));
        aux(23 downto 16) <= ram(to_integer(ADDR(30 downto 0) +'1'));
        aux(15 downto 8)  <= ram(to_integer(ADDR(30 downto 0) +"10"));
        aux(7 downto 0)   <= ram(to_integer(ADDR(30 downto 0) +"11"));
      end if;
    end if;

  end process;

  DATAO <= aux;

end architecture BEHAVIORAL;

