library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LED_Blink is
    Port ( CLK : in STD_LOGIC;
           LED_out : out STD_LOGIC);
end LED_Blink;

architecture Behavioral of LED_Blink is

    signal counter: natural range 0 to 49999999 := 0; -- Initialize counter to 0, range 0 to 49 for 50 half cycles
    signal toggle_LED: std_logic := '0';      -- Initialize clock_output to '0'

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if counter = 49999999 then  -- Change condition to check for 24 to complete 25 cycles
                toggle_LED <= not toggle_LED;  -- Toggle the clock output
                counter <= 0;  -- Reset counter
            else
                counter <= counter + 1;  -- Increment counter
            end if;
        end if;
    end process;

    LED_out <= toggle_LED;

end Behavioral;
