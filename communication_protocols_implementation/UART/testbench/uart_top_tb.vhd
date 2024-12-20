library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_uart is
-- Testbench has no ports
end tb_top_uart;

architecture Behavioral of tb_top_uart is

    -- Component Declaration for the Unit Under Test (UUT)
    component top_uart
        Port (
            clk : in std_logic;
            rst : in std_logic;
            tx : out std_logic
        );
    end component;

    -- Testbench signals
    signal clk : std_logic := '0';        -- 100 MHz clock
    signal rst : std_logic := '1';        -- Reset signal
    signal tx  : std_logic;               -- UART transmit line

    constant CLK_PERIOD : time := 10 ns;  -- Clock period for 100 MHz
    constant BAUD_RATE  : integer := 9600;
    constant BAUD_PERIOD : time := 1 sec / BAUD_RATE; -- Bit period for UART baud rate

    -- UART clock monitoring
    signal uart_clk : std_logic := '0';
    signal uart_clk_counter : integer := 0;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: top_uart
        Port map (
            clk => clk,
            rst => rst,
            tx => tx
        );

    -- Clock generation process (100 MHz)
    clk_process : process
    begin
        while True loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Generate a reset signal
    rst_process : process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait;
    end process;

    -- Monitor UART clock (baud rate)
    uart_clk_process : process(clk)
    begin
        if rising_edge(clk) then
            if uart_clk_counter = integer(CLK_PERIOD / BAUD_PERIOD) then
                uart_clk <= not uart_clk;
                uart_clk_counter <= 0;
            else
                uart_clk_counter <= uart_clk_counter + 1;
            end if;
        end if;
    end process;

    -- Simulate UART transmission
    uart_tx_monitor : process
    begin
        wait until tx'event and tx = '0'; -- Start bit detected
        report "Start bit detected";
        wait for BAUD_PERIOD; -- Wait for first data bit

        for i in 0 to 7 loop
            report "Data bit " & integer'image(i) & ": " & std_logic'image(tx);
            wait for BAUD_PERIOD;
        end loop;

        report "Stop bit: " & std_logic'image(tx);
        wait for BAUD_PERIOD;
    end process;

end Behavioral;
