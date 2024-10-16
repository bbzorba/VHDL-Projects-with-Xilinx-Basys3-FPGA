library IEEE;
use IEEE.Std_logic_1164.all;

entity fsm_spi_tb is
end;

architecture bench of spi_master_transmit_FSM_tb is
    
    component spi_master_transmit_FSM is
    generic(
        data_length : natural := 8
    );
    port( 
         clk, rst, tx_enable : in std_logic;
         data : in std_logic_vector(7 downto 0);
         control : in std_logic_vector(3 downto 0);
         mosi, ss, sclk: out std_logic );
    end component;
    
    signal clk, rst, tx_enable: std_logic;
    signal mosi, ss, sclk: std_logic;
    signal data : std_logic_vector (7 downto 0);
    signal control : std_logic_vector (3 downto 0);
    
    constant clock_period: time := 10 ns;
    
begin

    -- Instantiate the DUT (Device Under Test)
    u1: spi_master_transmit_FSM port map 
    (
        clk => clk,
        rst => rst,
        tx_enable => tx_enable,
        data => data,
        control => control,
        mosi => mosi,
        ss => ss,
        sclk => sclk
    );
    
    -- Stimulus process
    process
    begin
        -- Reset the system
        rst <= '1';
        wait for clock_period;
        rst <= '0';
        data <= "11010100";
        control <= "1010";
        
        -- Enable transmission
        tx_enable <= '1';
        wait for clock_period;
        
        -- Keep tx_enable active for 12 clock periods
        wait for clock_period * 12;
        tx_enable <= '0';
        
    
        wait; -- Continue indefinitely
    end process;

    
    -- Clock generation process using a variable for stopping the clock
    process
        variable stop_the_clock_var: boolean := false;
    begin
        while not stop_the_clock_var loop
            clk <= '0';
            wait for clock_period / 2;
            clk <= '1';
            wait for clock_period / 2;
        end loop;
        
        -- Ensure simulation ends after the clock is stopped
        wait;
    end process;

end bench;
