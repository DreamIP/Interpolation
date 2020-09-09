------------------------------------------------------------------------------
-- Title      : two_piecewise1
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : two_piecewise1.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: approximation of the cubic kernel with two_piecewise in the second direction  
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity two_piecewise1 is
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

        -- pixel coordinates
        x : in std_logic_vector(x_y_size - 1 downto 0);
 
        -- neighboring pixels
        in_data00, in_data01, in_data02, in_data03 : in std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);

        -- interpolated pixel
        out_pixel : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
        out_dv    : out std_logic;
        out_fv    : out std_logic 
    ); 
end two_piecewise1;

architecture rtl of two_piecewise1 is
--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------
    signal sig10, sig11, sig12, sig13, sig20, sig21,sig30,sig31 : signed(x_y_size + PIXEL_SIZE downto 0); 
    signal A0, A1, A2, A3                           : signed(x_y_size + PIXEL_SIZE downto 0);
    signal p                                        : signed((x_y_size + PIXEL_SIZE) downto 0);
    signal xx, sig14, sig22, x1, x2, x3, x4         : signed(x_y_size downto 0);
    signal out_dv_1, out_dv_2,out_dv_3              : std_logic;
    signal out_fv_1, out_fv_2,out_fv_3              : std_logic;
    
begin
    A0 <= signed(in_data00);
    A1 <= signed(in_data01);
    A2 <= signed(in_data02);
    A3 <= signed(in_data03);
    xx <= signed('0' & x);
    
    -- full-pipelined architecture
    process (clk, reset)
    begin
        if (reset = '0') then
            p      <= (others => '0');
            out_dv <= '0';
            out_fv <= '0';
 
        elsif (RISING_EDGE(clk)) then
            if (enable = '1') then 
 
                x1 <= xx;
                x2 <= x1;
                x3 <= x2;
					 x4 <= x3; 
 
                -- first stage
                sig10    <= shift_right(A3 - A0, 5);
                sig11    <= resize(A2 - A1, (x_y_size + PIXEL_SIZE + 1));
                sig12    <= shift_right(A3, 5);
                sig13    <= A1;
                sig14    <= x4;
                out_dv_1 <= in_dv;
                out_fv_1 <= in_fv;
 
                -- second stage
                sig20    <= resize(sig10 + sig11, (x_y_size + PIXEL_SIZE + 1));
                sig21    <= resize(sig13 - sig12, (x_y_size + PIXEL_SIZE + 1));
                sig22    <= sig14;
                out_dv_2 <= out_dv_1;
                out_fv_2 <= out_fv_1;
 
                -- third stage 
					 sig30 <= resize(shift_right(sig20 * sig22,x_y_size),(x_y_size+PIXEL_SIZE+1));
					 sig31 <= sig21;
                out_dv_3 <= out_dv_2; 
                out_fv_3 <= out_fv_2; 
							  
					 -- fourth stage 
   
                p <= resize((sig30 + sig31),(x_y_size+PIXEL_SIZE+1));
                out_dv <= out_dv_3; 
                out_fv <= out_fv_3;
            end if;
        end if;

    end process;
    out_pixel <= std_logic_vector(p);
end rtl;