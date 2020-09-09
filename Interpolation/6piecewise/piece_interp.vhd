------------------------------------------------------------------------------
-- Title      : piece_interp
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : piece_interp.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: interpol block of the first direction  
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity piece_interp is
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

        -- interpolation coefficients
        x0, x1, x2, x3 : in std_logic_vector((x_y_size + 5) downto 0);
 
        -- neighboring pixels
        in_data00, in_data01, in_data02, in_data03 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);

        -- interpolated pixel
        out_pixel : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
        out_dv    : out std_logic;
        out_fv    : out std_logic 
    ); 
end piece_interp;
architecture rtl of piece_interp is
--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------
    signal sig10, sig11, sig12, sig13                                           : signed(x_y_size + PIXEL_SIZE + 6 downto 0);
    signal out_dv1, out_dv2                                                     : std_logic;
    signal out_fv1, out_fv2                                                     : std_logic;
    signal sig20, sig21, s                                                      : signed(x_y_size + PIXEL_SIZE + 6 downto 0);
    signal xx0, xx1, xx2, xx3                                                   : signed(x_y_size + 5 downto 0);
    signal A00, A01, A02, A03                                                   : signed(PIXEL_SIZE downto 0);
    signal p                                                                    : signed((x_y_size + PIXEL_SIZE) downto 0); 
    signal A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15 : signed(PIXEL_SIZE downto 0);
 
 
begin
    xx0 <= signed(x0);
    xx1 <= signed(x1);
    xx2 <= signed(x2);
    xx3 <= signed(x3);

    A0  <= signed('0' & in_data00);
    A1  <= signed('0' & in_data01);
    A2  <= signed('0' & in_data02);
    A3  <= signed('0' & in_data03); 
 
    process (clk, reset)
    begin
        if (reset = '0') then
            p      <= (others => '0');
            out_dv <= '0';
            out_fv <= '0';
 
        elsif (RISING_EDGE(clk)) then
            if (enable = '1') then
                 -- pipeline (4 stages of the piece block)
                A4  <= A0;
                A5  <= A1;
                A6  <= A2;
                A7  <= A3; 

                A8  <= A4;
                A9  <= A5;
                A10 <= A6;
                A11 <= A7;

                A12 <= A8;
                A13 <= A9;
                A14 <= A10;
                A15 <= A11;

                A00 <= A12;
                A01 <= A13;
                A02 <= A14;
                A03 <= A15;

 
                -- first stage
                sig10   <= xx0 * A00; 
                sig11   <= xx1 * A01;
                sig12   <= xx2 * A02;
                sig13   <= xx3 * A03;
                out_dv1 <= in_dv;
                out_fv1 <= in_fv;
 
                -- second stage
                sig20   <= sig10 + sig11;
                sig21   <= sig12 + sig13;
                out_dv2 <= out_dv1;
                out_fv2 <= out_fv1;
 
                -- third stage
                --s<= sig20 + sig21;
                p      <= resize(shift_right(sig20 + sig21, 3), x_y_size + PIXEL_SIZE + 1);
                out_dv <= out_dv2;
                out_fv <= out_fv2; 
 
            end if;
        end if;

    end process;
    out_pixel <= std_logic_vector(p);
 
 
end rtl;
