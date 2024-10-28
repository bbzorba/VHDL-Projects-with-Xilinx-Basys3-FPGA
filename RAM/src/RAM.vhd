-- Random Access Memory (RAM) with 1 read/write port

LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- RAM entity
ENTITY RAM_volatile IS
  GENERIC(
      DATA_SIZE : NATURAL := 8;
      ADDRESS_SIZE : NATURAL := 8;
      MEMORY_DEPTH : NATURAL := 256
    );
  PORT(
       DATA_IN : IN STD_LOGIC_VECTOR(DATA_SIZE - 1 downto 0);
       ADDRESS : IN STD_LOGIC_VECTOR(ADDRESS_SIZE - 1 downto 0);
       Read_Write : IN STD_LOGIC;
       DATA_OUT : OUT STD_LOGIC_VECTOR(DATA_SIZE - 1 downto 0)
       );
END ENTITY;

Architecture Behavioral of RAM_volatile is

type MEMORY is array (MEMORY_DEPTH -1 downto 0) of STD_LOGIC_VECTOR(ADDRESS_SIZE - 1 downto 0);

signal RAM : MEMORY;
signal ADDRESS_INT : INTEGER RANGE 0 TO 255;

begin

  Process(ADDRESS, DATA_IN, Read_Write)
  begin

    ADDRESS_INT <= CONV_INTEGER(ADDRESS);
    
    if (Read_Write='0') then --Read when 1
      RAM(ADDRESS_INT) <= DATA_IN;    
    elsif (Read_Write='1') then --Write when 0
      DATA_OUT <= RAM(ADDRESS_INT);
    else
      DATA_OUT <= (others => 'Z');
    end if;
    
  end process;
end Behavioral;
