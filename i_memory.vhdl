library std;
  use std.textio.all;

library IEEE;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.numeric_std_unsigned.all;
  use ieee.std_logic_textio.all;


entity memoria is
  generic(
           C_FILENAME : string := "program";
           C_MEM_SIZE : integer := 1024;
           C_LITTLE_ENDIAN : boolean := true
         );
  PORT(
        ADDR : in std_logic_vector(31 downto 0);
        DATAI : in std_logic_vector(31 downto 0);
        DATAO : out std_logic_vector(31 downto 0);
        WR : in std_logic ;
        CLK : in std_logic ;
        nRST : in std_logic
      );
end memoria;

architecture Behavioral of memoria is

  type matriz is array(0 to C_MEM_SIZE-1) of STD_LOGIC_VECTOR(7 downto 0);
  signal RAM: matriz;
  signal AUX : STD_LOGIC_VECTOR (31 downto 0):= (others=>'0');


begin

  process (CLK)
    variable LOAD : boolean := true;
    variable ADDRESS : STD_LOGIC_VECTOR(31 downto 0);
    variable DATUM : STD_LOGIC_VECTOR(31 downto 0);
    file TEXTFILE : text; -- is in C_FILENAME;
    variable  current_line : line;

  begin

    if LOAD then
        -- primero iniciamos la memoria con ceros
      for i in 0 to C_MEM_SIZE-1 loop
        RAM(i) <= (others => '0');
      end loop;

        -- luego cargamos el archivo en la misma
      file_open(TEXTFILE, C_FILENAME, read_mode);
      while (not endfile (TEXTFILE)) loop
        readline (TEXTFILE, current_line);
        hread(current_line, ADDRESS);
        hread(current_line, DATUM);
        assert to_integer(ADDRESS(30 downto 0))<C_MEM_SIZE
        report "Direccion fuera de rango en el fichero de la memoria"
        severity failure;
        if (C_LITTLE_ENDIAN) then
          RAM(to_integer(ADDRESS(30 downto 0))) <= DATUM(31 downto 24);
          RAM(to_integer(ADDRESS(30 downto 0)+'1')) <= DATUM(23 downto 16);
          RAM(to_integer(ADDRESS(30 downto 0)+"10")) <= DATUM(15 downto 8);
          RAM(to_integer(ADDRESS(30 downto 0)+"11")) <= DATUM(7 downto 0);
        else
          RAM(to_integer(ADDRESS(30 downto 0))) <= DATUM(7 downto 0);
          RAM(to_integer(ADDRESS(30 downto 0)+'1')) <= DATUM(15 downto 8);
          RAM(to_integer(ADDRESS(30 downto 0)+"10")) <= DATUM(23 downto 16);
          RAM(to_integer(ADDRESS(30 downto 0)+"11")) <= DATUM(31 downto 24);
        end if;
      end loop;

        -- por ultimo cerramos el archivo y actualizamos el flag de RAMria cargada
      file_close (TEXTFILE);
      AUX <= X"0000_0000";
      LOAD := false;

    elsif (nRST = '0') then
      AUX <= X"0000_0000";

    elsif (rising_edge(CLK)) then
      if (WR = '1') then
        RAM(to_integer(Addr(30 downto 0))) <= DATAI(31 downto 24);
        RAM(to_integer(Addr(30 downto 0)+'1')) <= DATAI(23 downto 16);
        RAM(to_integer(Addr(30 downto 0)+"10")) <= DATAI(15 downto 8);
        RAM(to_integer(Addr(30 downto 0)+"11")) <= DATAI(7 downto 0);

      else
        AUX(31 downto 24) <= RAM(to_integer(ADDR(30 downto 0)));
        AUX(23 downto 16) <= RAM(to_integer(ADDR(30 downto 0)+'1'));
        AUX(15 downto 8) <= RAM(to_integer(ADDR(30 downto 0)+"10"));
        AUX(7 downto 0) <= RAM(to_integer(ADDR(30 downto 0)+"11"));
      end if;
    end if;
  end process;

  DATAO <= AUX;

end Behavioral;

