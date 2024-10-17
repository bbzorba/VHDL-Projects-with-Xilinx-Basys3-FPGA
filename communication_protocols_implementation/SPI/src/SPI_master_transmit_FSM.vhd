library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  -- For natural type

entity spi_master_transmit_FSM is
    generic(
        data_length : natural := 8
    );
    port( 
         clk, rst, tx_enable : in std_logic;
         data : in std_logic_vector(data_length - 1 downto 0);
         control : in std_logic_vector(3 downto 0);
         mosi, ss, sclk: out std_logic );
end entity;

architecture logic_flow of spi_master_transmit_FSM is

    type state is (st_idle, st0_tx_ctrl_bits, st1_tx_data_bits);
    signal present_state, next_state: state;

    signal timer: natural range 0 to data_length;
    signal data_index: natural range 0 to data_length;
    signal spi_sclk: std_logic := '0';
    signal clk_divider: natural range 0 to 3 := 0;  -- Clock divider for SCLK

begin

    -- Clock divider to generate slower spi_sclk from input clk
    process(clk, rst)
    begin
        if rst = '1' then
            spi_sclk <= '0';
            clk_divider <= 0;
        elsif rising_edge(clk) then
            if clk_divider = 7 then  -- Change this to 7 for a divide-by-8 clock divider
                spi_sclk <= not spi_sclk;  -- Toggle spi_sclk
                clk_divider <= 0;
            else
                clk_divider <= clk_divider + 1;
            end if;
        end if;
    end process;


    -- Next state logic process, synchronous with spi_sclk
    process(spi_sclk, rst)
    begin
        if (rst = '1') then
            present_state <= st_idle;
            data_index <= 0;
        elsif rising_edge(spi_sclk) then
            if (data_index = timer - 1) then
                present_state <= next_state;
                data_index <= 0;
            else
                data_index <= data_index + 1;
            end if;
        end if;
    end process;
    
    -- SPI state machine process
    process(present_state, tx_enable, data_index)
    begin
        case present_state is
            when st_idle =>
                ss <= '1';  -- Set SS high (idle state)
                mosi <= 'X';  -- Idle state, MOSI is undefined
                timer <= 1;  -- Initialize the timer for ST0
                if (tx_enable = '1') then
                    next_state <= st0_tx_ctrl_bits;
                else
                    next_state <= st_idle;
                end if;
                
            when st0_tx_ctrl_bits =>
                ss <= '0';  -- Set SS low to select slave
                timer <= 4;  -- Length of control data
                mosi <= control(3 - data_index);  -- Send control bits
                if data_index = 3 then
                    next_state <= st1_tx_data_bits;
                else
                    next_state <= st0_tx_ctrl_bits;
                end if;
                
            when st1_tx_data_bits =>
                ss <= '0';  -- Keep SS low
                timer <= data_length;  -- Length of data transmission
                mosi <= data(7 - data_index);  -- Send data bits
                if data_index = 7 then
                    next_state <= st_idle;  -- After data transmission, go to idle
                else
                    next_state <= st1_tx_data_bits;
                end if;
        end case;
    end process;

    -- Assign the generated spi_sclk to the output SCLK
    sclk <= spi_sclk;

end logic_flow;
