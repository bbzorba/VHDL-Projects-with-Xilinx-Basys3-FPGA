library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity RS232_FSM_tb is
end;

architecture bench of RS232_FSM_tb is

  component RS232_FSM
      Port(
          clk, rst, trig : in STD_LOGIC;
          clk_9600Hz : inout std_logic;
          data_to_send : in std_logic_vector (7 downto 0);
          Tx : out std_logic);
end component;

  signal clk, rst, trig: STD_LOGIC;
  signal clk_9600Hz : std_logic;
  signal data_to_send: std_logic_vector (7 downto 0);
  signal Tx: std_logic;

  constant clock_period: time := 10 ns;

begin

  uut: RS232_FSM port map ( clk          => clk,
                            clk_9600Hz   => clk_9600Hz,
                            rst          => rst,
                            trig         => trig,
                            data_to_send => data_to_send,
                            Tx           => Tx );

  stimulus: process
  begin
    
    rst <= '1';
    wait for clock_period;
    
    rst <= '0';
    data_to_send <= "11010110";
    trig <= '1';
    wait for clock_period;
    
    wait for 12*clock_period;
    trig <= '0';
    
    wait;
  end process;

  clocking: process
  begin
    while True loop
        clk <= '0';
        wait for clock_period / 2;
        clk <= '1';
        wait for clock_period / 2;
    end loop;
  end process;

end;
  