library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_divider_by_100 is
    Port ( CLK : in STD_LOGIC;
           CLK_divided_by_100 : out STD_LOGIC);
end clock_divider_by_100;

architecture Behavioral of clock_divider_by_100 is

    signal counter: natural range 0 to 49 := 0; -- Initialize counter to 0, range 0 to 49 for 50 half cycles
    signal clock_output: std_logic := '0';      -- Initialize clock_output to '0'

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if counter = 49 then  -- Change condition to check for 24 to complete 25 cycles
                clock_output <= not clock_output;  -- Toggle the clock output
                counter <= 0;  -- Reset counter
            else
                counter <= counter + 1;  -- Increment counter
            end if;
        end if;
    end process;

    CLK_divided_by_100 <= clock_output;

end Behavioral;
