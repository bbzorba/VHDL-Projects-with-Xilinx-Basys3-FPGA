Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all; -- To perform arithmetic on signals

ENTITY VGA_interactive IS
    GENERIC (
        Ha: INTEGER := 96;  -- Horizontal pulse
        Hb: INTEGER := 144; -- Horizontal back porch
        Hc: INTEGER := 784; -- Horizontal active area
        Hd: INTEGER := 800; -- Total horizontal period
        Va: INTEGER := 2;   -- Vertical pulse
        Vb: INTEGER := 35;  -- Vertical back porch
        Vc: INTEGER := 515; -- Vertical active area
        Vd: INTEGER := 525  -- Total vertical period
    );
    PORT (
        clk, reset : IN std_logic;       -- 100MHz clock and reset
        btn_up, btn_down, btn_left, btn_right : IN std_logic; -- Button inputs
        Hsync, Vsync : BUFFER std_logic; -- Horizontal and Vertical sync
        R, G, B : OUT std_logic_vector(3 downto 0) -- RGB outputs
    );
END VGA_interactive;

ARCHITECTURE Behavioral OF VGA_interactive IS
    signal Hactive, Vactive, dena : std_logic;
    signal pixel_clk : std_logic;
    signal Vcount : INTEGER range 0 TO Vd;
    signal Hcount : INTEGER range 0 TO Hd;
    signal btn_right_prev, btn_left_prev, btn_up_prev, btn_down_prev : std_logic := '0'; -- Signal to track previous button state
    signal X_pos, Y_pos : INTEGER range 0 TO (Hc - 100); -- Position of the square
    
begin

-- 25 MHz pixel clock generation process
process(clk, reset)
    variable count: positive range 1 to 3;
begin
    if(reset = '1') then
        pixel_clk <= '0';
        count := 1;
    elsif (rising_edge(clk)) then
        count := count + 1;
        if(count = 3) then
            pixel_clk <= not pixel_clk;
            count := 1;
        end if;
    end if;
end process;

-- Horizontal signals generation
process (pixel_clk)
begin
    if (pixel_clk'event and pixel_clk = '1') then
        Hcount <= Hcount + 1;
        if (Hcount = Ha) then
            Hsync <= '1';
        elsif (Hcount = Hb) then
            Hactive <= '1';
        elsif (Hcount = Hc) then
            Hactive <= '0';
        elsif (Hcount = Hd) then
            Hsync <= '0';
            Hcount <= 0;
        end if;
    end if;
end process;

-- Vertical signals generation
process (Hsync)
begin
    if (Hsync'EVENT AND Hsync = '0') then
        Vcount <= Vcount + 1;
        if (Vcount = Va) then
            Vsync <= '1';
        elsif (Vcount = Vb) then
            Vactive <= '1';
        elsif (Vcount = Vc) then
            Vactive <= '0';
        elsif (Vcount = Vd) then
            Vsync <= '0';
            Vcount <= 0;
        end if;
    end if;
end process;

-- Display enable generation
dena <= Hactive AND Vactive;

-- Update square position based on button inputs
process(pixel_clk, reset)
begin
    
    if reset = '1' then
        X_pos <= 270; -- Initial X position
        Y_pos <= 170; -- Initial Y position
        btn_right_prev <= '0'; -- Reset button state tracking
        btn_left_prev <= '0';
        
    elsif rising_edge(pixel_clk) then
        
        -- Horizontal movement (left and right buttons)
        if btn_left = '1' and btn_left_prev = '0' and X_pos > 0 then
            X_pos <= X_pos - 10; -- Move left by 10 pixels
        elsif btn_right = '1' and btn_right_prev = '0' and X_pos < (Hc - Hb - 100) then
            X_pos <= X_pos + 10; -- Move right by 10 pixels
        end if;
        
        -- Vertical movement (up and down buttons)
        if btn_up = '1' and btn_up_prev = '0' and Y_pos > 0 then
            Y_pos <= Y_pos - 10; -- Move up by 10 pixels
        elsif btn_down = '1' and btn_down_prev = '0' and Y_pos < (Vc - Vb - 100) then
            Y_pos <= Y_pos + 10; -- Move down by 10 pixels
        end if;

        -- Update previous button state
        btn_right_prev <= btn_right;
        btn_left_prev <= btn_left;
        btn_up_prev <= btn_up;
        btn_down_prev <= btn_down;
        
    end if;
    
end process;



-- Image generator
process(pixel_clk)
begin
    if dena = '1' then
        -- Generate a square at X_pos, Y_pos
        if (Hcount >= Hb + X_pos and Hcount <= Hb + X_pos + 100 and 
            Vcount >= Vb + Y_pos and Vcount <= Vb + Y_pos + 100) then
            R <= "1111"; G <= "1111"; B <= "1111"; -- White square
        else
            R <= "0000"; G <= "0000"; B <= "0000"; -- Black background
        end if;
    end if;
end process;

END Behavioral;
