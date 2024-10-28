library IEEE;
use IEEE.STD_LOGIC_1164.all;
use STD.TEXTIO.all;

entity TEXTIO_READ_WRITE is
    port(
        Clock : in STD_LOGIC;
        A_in : in BIT_VECTOR(3 downto 0) := "1010";
        B_in : in BIT_VECTOR(3 downto 0) := "1011";
        C_in : in BIT_VECTOR(3 downto 0) := "1100";
        A_out, B_out, C_out: out BIT_VECTOR(3 downto 0)
    );
end entity;

architecture Behavioral of TEXTIO_READ_WRITE is

constant Settling_time : Time := 5 NS;

begin

    -- Write Process
    write_proc: process
        file F: TEXT open WRITE_MODE is "E:/dev/FPGA/Xilinx/VHDL_Projects_with_Xilinx_FPGA/TextIO_Read_Write/test.txt";
        variable L: LINE;
    begin

        wait until Rising_edge(Clock);
        wait for Settling_time;
        
        -- Write values to file
        WRITE(L, NOW, LEFT, 10);
        WRITELINE(F, L);  -- Write the time on its own line
        
        WRITE(L, A_in, RIGHT, 5);
        WRITELINE(F, L);  -- Write A_in on a new line
        
        WRITE(L, B_in, RIGHT, 5);
        WRITELINE(F, L);  -- Write B_in on a new line
        
        WRITE(L, C_in, RIGHT, 5);
        WRITELINE(F, L);  -- Write C_in on a new line
        
        wait; -- Prevent further writing
    end process write_proc;

    -- Read Process
    read_proc: process
        file F: TEXT open READ_MODE is "E:/dev/FPGA/Xilinx/VHDL_Projects_with_Xilinx_FPGA/TextIO_Read_Write/test.txt";
        variable L: LINE;
        variable TimeWhen: TIME;
        variable A_read, B_read, C_read: BIT_VECTOR(3 downto 0);
    begin
        wait until Rising_edge(Clock);
        wait for Settling_time;
        
        -- Read and apply values from file
        while not ENDFILE(F) loop
            READLINE(F, L);
            READ(L, TimeWhen);
    
            -- Read A value from the next line
            READLINE(F, L);
            READ(L, A_read);
    
            -- Read B value from the next line
            READLINE(F, L);
            READ(L, B_read);
    
            -- Read C value from the next line
            READLINE(F, L);
            READ(L, C_read);

            
            wait for TimeWhen - NOW;  -- Wait until the specified time
            A_out <= A_read;
            B_out <= B_read;
            C_out <= C_read;
        end loop;

        wait; -- Prevent further reading
    end process read_proc;

end Behavioral;
