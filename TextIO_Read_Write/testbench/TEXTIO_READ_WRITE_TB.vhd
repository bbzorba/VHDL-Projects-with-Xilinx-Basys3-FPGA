library IEEE;
use IEEE.STD_LOGIC_1164.all;
use STD.TEXTIO.all;

entity TEXTIO_TESTBENCH is
end TEXTIO_TESTBENCH;

architecture Behavioral of TEXTIO_TESTBENCH is
    
    -- Component declaration for the unit under test (UUT)
    component TEXTIO_READ_WRITE is
        port(
            Clock : in STD_LOGIC;
            A_in, B_in, C_in: in BIT_VECTOR(3 downto 0);
            A_out, B_out, C_out: out BIT_VECTOR(3 downto 0)
    );
end component;

    signal Clock: STD_LOGIC := '0';
    signal A_in, B_in, C_in: BIT_VECTOR(3 downto 0);
    signal A_out, B_out, C_out: BIT_VECTOR (3 downto 0);
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: TEXTIO_READ_WRITE
        port map (
            Clock => Clock,
            A_in => A_in, 
            B_in => B_in, 
            C_in => C_in,
            A_out => A_out, 
            B_out => B_out, 
            C_out => C_out
        );
        
    seq: process
    begin
        wait for CLK_PERIOD;
        
        wait; -- Continue indefinitely
    end process;

    -- Clock generation process
    clock_proc: process
    begin
        while true loop
            Clock <= '0';
            wait for CLK_PERIOD / 2;
            Clock <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

end Behavioral;
