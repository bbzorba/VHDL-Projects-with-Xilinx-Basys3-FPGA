library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Shifting_LEDs_tb is
end;

architecture bench of Shifting_LEDs_tb is

  component Shifting_LEDs
      Port( 
           CLK : in STD_LOGIC;
           LED_out : out STD_LOGIC_VECTOR(15 downto 0)
           );
  end component;

  signal CLK: STD_LOGIC := '0';
  signal LED_out: STD_LOGIC_VECTOR(15 downto 0);

  constant clock_period: time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: Shifting_LEDs
    port map ( 
      CLK     => CLK,
      LED_out => LED_out 
    );

  -- Clock Generation Process
  clocking: process
  begin
    while true loop
      CLK <= '0';
      wait for clock_period / 2;
      CLK <= '1';
      wait for clock_period / 2;
    end loop;
  end process clocking;

  -- Test Stimulus Process
  stimulus: process
  begin
    wait for 1000 ns;  -- Run the simulation for a specific period
    wait;
  end process stimulus;

end;
