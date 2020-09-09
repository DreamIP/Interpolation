------------------------------------------------------------------------------
-- Title      : piece_coef
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : piece_coef.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: compute the interpolation coefficients  
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity piece_coef is
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
 
        -- interpolation coeffcients
        x0, x1, x2, x3 : out std_logic_vector((x_y_size + 1) downto 0); 
        out_dv         : out std_logic;
        out_fv         : out std_logic 
    ); 
end piece_coef;
architecture rtl of piece_coef is
--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------
    signal p0, p1, p2, p3 : signed(x_y_size + 1 downto 0);

begin
    
    process (clk, reset)
    begin
        if (reset = '0') then
            p0     <= (others => '0');
            p1     <= (others => '0');
            p2     <= (others => '0');
            p3     <= (others => '0');
            out_dv <= '0';
            out_fv <= '0';
 
        elsif (RISING_EDGE(clk)) then
            if (enable = '1') then 
                p0     <= signed("01" & x);
                p1     <= signed("00" & x);
                p2     <= signed("01000000000" - signed("00" & x));
                p3     <= resize (signed("010000000000" - signed("000" & x)), x_y_size + 2); 
                out_dv <= in_dv;
                out_fv <= in_fv; 
 
            end if;
        end if;
    end process;
            
    x0 <= std_logic_vector(p0);
    x1 <= std_logic_vector(p1);
    x2 <= std_logic_vector(p2);
    x3 <= std_logic_vector(p3);
 
end rtl;
