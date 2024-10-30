library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity Shifting_LEDs is
    Port( 
         CLK : in STD_LOGIC;
         LED_out : out STD_LOGIC_VECTOR(15 downto 0)
         );
end Shifting_LEDs;

architecture Behavioral of Shifting_LEDs is

    signal counter: natural range 0 to 12499999 := 0; -- Slower clock counter
    signal shifted_LEDs : std_logic_vector(15 downto 0) := "0000000000000001"; -- Start with rightmost LED ON
    signal direction : std_logic := '1'; -- '1' for left, '0' for right

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if counter = 12499999 then
                counter <= 0;  -- Reset counter
                
                -- Shifting logic based on direction
                if direction = '1' then  -- Shift left
                    if shifted_LEDs = "1000000000000000" then
                        direction <= '0';  -- Switch to rightward shift
                    else
                        shifted_LEDs <= std_logic_vector(shift_left(unsigned(shifted_LEDs), 1));
                    end if;
                else  -- Shift right
                    if shifted_LEDs = "0000000000000001" then
                        direction <= '1';  -- Switch to leftward shift
                    else
                        shifted_LEDs <= std_logic_vector(shift_right(unsigned(shifted_LEDs), 1));
                    end if;
                end if;

            else
                counter <= counter + 1;  -- Increment counter
            end if;
        end if;
    end process;

    LED_out <= shifted_LEDs;

end Behavioral;
