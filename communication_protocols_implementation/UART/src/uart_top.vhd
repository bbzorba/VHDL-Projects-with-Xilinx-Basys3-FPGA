library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_uart is
    Port (
        clk : in std_logic;                -- 100 MHz FPGA clock
        rst : in std_logic;                -- Reset
        tx : out std_logic                 -- UART transmit line
    );
end top_uart;

architecture Behavioral of top_uart is

    -- Component Declaration
    component uart
        generic (
            CLK_FREQ : integer := 100;     -- Clock frequency in MHz
            SER_FREQ : integer := 9600     -- Baud rate
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            rx : in std_logic;
            tx : out std_logic;
            par_en : in std_logic;
            tx_req : in std_logic;
            tx_end : out std_logic;
            tx_data : in std_logic_vector(7 downto 0);
            rx_ready : out std_logic;
            rx_data : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Internal Signals
    signal tx_req : std_logic := '0';
    signal tx_end : std_logic;
    signal tx_data : std_logic_vector(7 downto 0);
    signal par_en : std_logic := '0';  -- No parity

    -- Counter for delays
    signal delay_counter : integer range 0 to 100000000 := 0; -- Adjust as needed
    constant DELAY_COUNT : integer := 5000000;               -- Approx. 50ms for 100 MHz clock
    constant ONE_SECOND_COUNT : integer := 100000000;        -- Approx. 1 second for 100 MHz clock

    -- Updated FSM States
    type state_type is (IDLE, SEND_H, WAIT_H, SEND_E, WAIT_E, SEND_L1, WAIT_L1, SEND_L2, WAIT_L2, SEND_O, WAIT_O, SEND_CR, WAIT_CR, SEND_LF, WAIT_LF, WAIT_ST);
    signal state : state_type := IDLE;

begin

    -- Instantiate UART
    uart_inst : uart
        generic map (
            CLK_FREQ => 100,               -- Basys-3 clock frequency (MHz)
            SER_FREQ => 9600               -- UART baud rate
        )
        port map (
            clk => clk,
            rst => rst,
            rx => '1',                     -- Not receiving in this example
            tx => tx,
            par_en => par_en,
            tx_req => tx_req,
            tx_end => tx_end,
            tx_data => tx_data,
            rx_ready => open,              -- Unused in this example
            rx_data => open                -- Unused in this example
        );

    -- FSM for sending "HELLO" repeatedly with delays
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                tx_req <= '0';
                delay_counter <= 0;
            else
                case state is
                    when IDLE =>
                        tx_data <= "01001000";  -- ASCII 'H'
                        tx_req <= '1';
                        state <= SEND_H;
                    when SEND_H =>
                        if tx_end = '1' then
                            tx_req <= '0';
                            delay_counter <= 0;
                            state <= WAIT_H;
                        end if;
                    when WAIT_H =>
                        if delay_counter < DELAY_COUNT then
                            delay_counter <= delay_counter + 1;
                        else
                            tx_data <= "01000101";  -- ASCII 'E'
                            tx_req <= '1';
                            state <= SEND_E;
                        end if;
                    when SEND_E =>
                        if tx_end = '1' then
                            tx_req <= '0';
                            delay_counter <= 0;
                            state <= WAIT_E;
                        end if;
                    when WAIT_E =>
                        if delay_counter < DELAY_COUNT then
                            delay_counter <= delay_counter + 1;
                        else
                            tx_data <= "01001100";  -- ASCII 'L'
                            tx_req <= '1';
                            state <= SEND_L1;
                        end if;
                    when SEND_L1 =>
                        if tx_end = '1' then
                            tx_req <= '0';
                            delay_counter <= 0;
                            state <= WAIT_L1;
                        end if;
                    when WAIT_L1 =>
                        if delay_counter < DELAY_COUNT then
                            delay_counter <= delay_counter + 1;
                        else
                            tx_data <= "01001100";  -- ASCII 'L'
                            tx_req <= '1';
                            state <= SEND_L2;
                        end if;
                    when SEND_L2 =>
                        if tx_end = '1' then
                            tx_req <= '0';
                            delay_counter <= 0;
                            state <= WAIT_L2;
                        end if;
                    when WAIT_L2 =>
                        if delay_counter < DELAY_COUNT then
                            delay_counter <= delay_counter + 1;
                        else
                            tx_data <= "01001111";  -- ASCII 'O'
                            tx_req <= '1';
                            state <= SEND_O;
                        end if;
                    when SEND_O =>
                        if tx_end = '1' then
                            tx_req <= '0';
                            delay_counter <= 0;
                            state <= WAIT_O;
                        end if;
                    when WAIT_O =>
                        if delay_counter < DELAY_COUNT then
                            delay_counter <= delay_counter + 1;
                        else
                            tx_data <= "00001101";  -- ASCII '\r' (Carriage Return)
                            tx_req <= '1';
                            state <= SEND_CR;
                        end if;
                    when SEND_CR =>
                        if tx_end = '1' then
                            tx_req <= '0';
                            delay_counter <= 0;
                            state <= WAIT_CR;
                        end if;
                    when WAIT_CR =>
                        if delay_counter < DELAY_COUNT then
                            delay_counter <= delay_counter + 1;
                        else
                            tx_data <= "00001010";  -- ASCII '\n' (Line Feed)
                            tx_req <= '1';
                            state <= SEND_LF;
                        end if;
                    when SEND_LF =>
                        if tx_end = '1' then
                            tx_req <= '0';
                            delay_counter <= 0;
                            state <= WAIT_LF;
                        end if;
                    when WAIT_LF =>
                        if delay_counter < DELAY_COUNT then
                            delay_counter <= delay_counter + 1;
                        else
                            delay_counter <= 0;
                            state <= WAIT_ST;
                        end if;
                    when WAIT_ST =>
                        if delay_counter < ONE_SECOND_COUNT then
                            delay_counter <= delay_counter + 1;
                        else
                            delay_counter <= 0;
                            state <= IDLE;  -- Repeat the message
                        end if;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
