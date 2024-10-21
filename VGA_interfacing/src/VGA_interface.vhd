Library ieee;
Use ieee.std_logic_1164.all;
---------------------------------------------------------
Entity VGA_interface is
    Generic (
        Ha: INTEGER := 96; --Hpulse
        Hb: INTEGER := 144; --Hpulse+HBP
        Hc: INTEGER := 784; --Hpulse+HBP+Hactive
        Hd: INTEGER := 800; --Hpulse+HBP+Hactive+HFP
        Va: INTEGER := 2; --Vpulse
        Vb: INTEGER := 35; --Vpulse+VBP
        Vc: INTEGER := 515; --Vpulse+VBP+Vactive
        Vd: INTEGER := 525); --Vpulse+VBP+Vactive+VFP
    Port (
        clk, reset: IN std_logic; -- 100MHz in our board
        Hsync, Vsync: BUFFER std_logic;
        R, G, B: OUT std_logic_vector (3 downto 0)
        --nblanck, nsync : OUT STD_LOGIC
        );
End VGA_interface;

Architecture Behavioral OF VGA_interface is
    signal Hactive, Vactive, dena: std_logic;
    signal pixel_clk,pixel_clk1: std_logic;
    signal Vcount: INTEGER range 0 TO Vd;
    signal Hcount: INTEGER range 0 TO Hd;
begin

process(clk, reset) -- 25 MHz pixel clock generation
    variable count: positive range 1 to 3;
begin
    if(reset='1') then
        pixel_clk <='0';
        count:=1;
    elsif (rising_edge(clk)) then
        count := count + 1;
        if(count=3) then
            pixel_clk<=not pixel_clk;
            count:=1;
        end if;
    end if;
end process;

--Horizontal signals generation:
process (pixel_clk)
begin
    if (pixel_clk'event and pixel_clk='1') then
        Hcount <= Hcount + 1;
        if (Hcount=Ha) then
            Hsync <= '1';
        elsif (Hcount=Hb) then
            Hactive <= '1';
        elsif (Hcount=Hc) then
            Hactive <= '0';
        elsif (Hcount=Hd) then
            Hsync <= '0';
            Hcount <= 0;
        end if;
    end if;
end process;

--Vertical signals generation:
process (Hsync)
begin
    if (Hsync'event and Hsync='0') then
        Vcount <= Vcount + 1;
        if (Vcount=Va) then
            Vsync <= '1';
        elsif (Vcount=Vb) then
            Vactive <= '1';
        elsif (Vcount=Vc) then
            Vactive <= '0';
        elsif (Vcount=Vd) then
            Vsync <= '0';
            Vcount <= 0;
        end if;
    end if;
end process;

---Display enable generation:
dena <= Hactive and Vactive;

--image generator
process (pixel_clk)
begin
    if (dena = '1') then
        if (Hcount >= Hb + 290 and Hcount <= Hb + 290 + 60 and Vcount >= Vb + 60 and Vcount = Vb +60 + 360) then
            R <= "1100"; G <= "1011"; B <= "0010"; --yellow
        elsif (Hcount >= Hb + 290 and Hcount <= Hb + 290 + 60 and Vcount >= Vb + 70 and Vcount = Vb +70 + 360) then
            R <= "0011"; G <= "0110"; B <= "1101"; --navy
        else
            R <= "0000"; G <= "0000"; B <= "0000"; --black
        end if;
    end if;
end process;

end Behavioral;