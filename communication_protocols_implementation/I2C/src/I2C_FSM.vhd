library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity I2C_FSM is
    port( 
         clk, rst, wr_enable: in std_logic; -- Input clock and control signals
         sclk, dclk : in std_logic;         -- SCLK and DCLK generated externally
         sda: inout std_logic               -- Bidirectional SDA line
    );
end entity;

architecture Behavioral of I2C_FSM is

    type state is (st_idle, st0_start, st1_txSlaveAddress, st2_ack1, st3_txRegAddress, st4_ack2, st5_txData, st6_ack3, st7_stop);
    signal present_state, next_state: state;
    
    constant data: std_logic_vector(7 downto 0) := "11101100";
    constant slave_address: std_logic_vector(7 downto 0) := "11101100"; -- With write flag
    constant register_address: std_logic_vector(7 downto 0) := "11101100";
    constant max_length: natural := 8;
    constant max_delay: natural := 8;
    
    signal data_index: natural range 0 to max_length - 1;
    signal timer: natural range 0 to max_delay;
    signal ack_bits: std_logic_vector(2 downto 0);

begin

    -- State transition process, triggered by slower SCLK
    process(sclk, rst)
    begin
        if (rst = '1') then
            present_state <= st_idle;
            data_index <= 0;
        elsif (sclk'event and sclk = '1') then  -- Trigger on SCLK
            if (data_index = timer - 1) then
                present_state <= next_state;
                data_index <= 0;
            else
                data_index <= data_index + 1;
            end if;
        end if;
    end process;
    
    -- FSM logic process
    process(present_state, wr_enable)
    begin
        case present_state is
            when st_idle =>
                sda <= '1';  -- SDA high (idle)
                timer <= 1;
                if (wr_enable = '1') then
                    next_state <= st0_start;
                else
                    next_state <= st_idle;
                end if;
            
            when st0_start =>
                sda <= dclk;  -- SDA starts with DCLK
                timer <= 1;
                next_state <= st1_txSlaveAddress;
            
            when st1_txSlaveAddress =>
                sda <= slave_address(7 - data_index);  -- Transmit slave address
                timer <= 8;
                next_state <= st2_ack1;
            
            when st2_ack1 =>
                sda <= 'Z';  -- Release SDA for ACK
                timer <= 1;
                next_state <= st3_txRegAddress;
            
            when st3_txRegAddress =>
                sda <= register_address(7 - data_index);  -- Transmit register address
                timer <= 8;
                next_state <= st4_ack2;
            
            when st4_ack2 =>
                sda <= 'Z';  -- Release SDA for ACK
                timer <= 1;
                next_state <= st5_txData;
            
            when st5_txData =>
                sda <= data(7 - data_index);  -- Transmit data
                timer <= 8;
                next_state <= st6_ack3;
            
            when st6_ack3 =>
                sda <= 'Z';  -- Release SDA for ACK
                timer <= 1;
                next_state <= st7_stop;
            
            when st7_stop =>
                sda <= not dclk;  -- SDA stop condition
                timer <= 1;
                next_state <= st_idle;
        end case;
    end process;

end Behavioral;
