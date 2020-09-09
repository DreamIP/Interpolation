------------------------------------------------------------------------------
-- Title      : piece
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : piece.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: define the coefficients 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity piece is
    generic (
        PIXEL_SIZE : integer;
        x_y_size   : integer 
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        -- control
        in_dv  : in std_logic;
        in_fv  : in std_logic;
        enable : in std_logic;

        -- position of interpolation
        x : in std_logic_vector((x_y_size + 2) downto 0);
 
        -- coefficient
        out_pixel : out std_logic_vector((x_y_size + 5) downto 0); 
        out_dv    : out std_logic;
        out_fv    : out std_logic 
    ); 
end piece;
architecture rtl of piece is
--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------
    signal l1, l2, l3, l4, ll                                         : signed(x_y_size + 4 downto 0);
    signal a, b                                                       : integer;
    signal d                                                          : signed(x_y_size + 4 downto 0);
    signal c, e, out_dv0, out_dv1, out_dv2, out_fv0, out_fv1, out_fv2 : std_logic;
    signal p, pp                                                      : signed(x_y_size + 5 downto 0);
    signal xx, bx                                                     : signed(x_y_size + 5 downto 0);

begin

    ll <= "01000000000000";
    l1 <= "00010000000000";
    l2 <= "00111000000000";
    l3 <= "01001101111100";
    l4 <= "01011000000000";
    xx <= signed(x & "000");

    -- full-pipelined architecture
    process (clk, reset)
    begin
        if (reset = '0') then
            p      <= (others => '0');
            out_dv <= '0';
            out_fv <= '0';
 
        elsif (RISING_EDGE(clk)) then
            if (enable = '1') then 
                -- first stage
                if (xx < l1) then
                    a <= 1;
                    b <= 0;
                    c <= '1';
                    d <= "01000000000000";
                    e <= '0';
                elsif (xx < l2) then 
                    a <= 2;
                    b <= 0;
                    c <= '0';
                    d <= "01001100000000";
                    e <= '0';
                elsif (xx < ll) then
                    a <= 1;
                    b <= 2;
                    c <= '0';
                    d <= "00110000000000";
                    e <= '0';
                elsif (xx < l3) then
                    a <= 2;
                    b <= 4;
                    c <= '0';
                    d <= "00011000000000";
                    e <= '0'; 
                elsif (xx < l4) then
                    a <= 4;
                    b <= 0;
                    c <= '1';
                    d <= "00000001000000";
                    e <= '0'; 
                else 
                    a <= 3;
                    b <= 0;
                    c <= '1';
                    d <= "00010000000000";
                    e <= '1';
                end if; 
                out_dv0 <= in_dv;
                out_fv0 <= in_fv; 

                -- second stage
                if (c = '0') then
                    bx <= shift_right(xx, b); 
                else 
                    bx <= "000000000000000"; 
                end if;  
                out_dv1 <= out_dv0;
                out_fv1 <= out_fv0;

                -- third stage
                pp      <= d - shift_right(xx, a) - bx;
                out_dv2 <= out_dv1;
                out_fv2 <= out_fv1;

                -- fourth stage 
                if (e = '1') then
                    p <= - pp;
                else 
                    p <= pp;
                end if;
                out_dv <= out_dv2;
                out_fv <= out_fv2;
 
            end if;
        end if;

    end process;
    out_pixel <= std_logic_vector(resize(p, x_y_size + 6));
end rtl;
