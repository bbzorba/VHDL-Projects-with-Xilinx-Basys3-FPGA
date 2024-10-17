library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RS232_FSM is
    Port ( clk, rst, trig : in STD_LOGIC;
           clk_9600Hz : inout std_logic;
           data_to_send : in std_logic_vector (7 downto 0);
           Tx : out std_logic);
end RS232_FSM;

architecture Behavioral of RS232_FSM is

type state is (idle, start_tx , st0, st1, st2, st3, st4, st5, st6, st7, stop);
signal present_state, next_state : state := idle;
signal count : positive range 1 to 5209 := 1; --to make the baudrate as 9600

begin

    -- Clock divider to generate 9600Hz clock from input clock
    process(clk, rst)
    begin
        if (rst = '1') then
            count <= 1;
            clk_9600Hz <= '0';
        elsif (rising_edge(clk)) then
            if (count = 5208) then
                clk_9600Hz <= not clk_9600Hz;
                count <= 1;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
    
    -- Synchronous state transition on clk_9600Hz
    process(clk_9600Hz, rst)
    begin
        if (rst = '1') then
            present_state <= idle;
        elsif (rising_edge(clk_9600Hz)) then
            present_state <= next_state;
        end if;
    end process;

    -- Combinational next state logic
    process (present_state, trig, data_to_send)
    begin
        -- Default assignment for next_state
        next_state <= present_state;  
        
        case present_state is
            when idle =>
                Tx <= '1';
                if (trig = '1') then
                    next_state <= start_tx;
                end if;
                
            when start_tx =>
                Tx <= '0'; 
                next_state <= st0;
            
            when st0 =>
                Tx <= data_to_send(0); 
                next_state <= st1;
            
            when st1 =>
                Tx <= data_to_send(1); 
                next_state <= st2;
            
            when st2 =>
                Tx <= data_to_send(2); 
                next_state <= st3;
            
            when st3 =>
                Tx <= data_to_send(3); 
                next_state <= st4;
            
            when st4 =>
                Tx <= data_to_send(4); 
                next_state <= st5;
            
            when st5 =>
                Tx <= data_to_send(5); 
                next_state <= st6;
        
            when st6 =>
                Tx <= data_to_send(6); 
                next_state <= st7;
            
            when st7 =>
                Tx <= data_to_send(7); 
                next_state <= stop;
            
            when stop =>
                Tx <= '1';
                if (trig = '0') then
                    next_state <= idle;
                end if;
                        
        end case;
    end process;

end Behavioral;
