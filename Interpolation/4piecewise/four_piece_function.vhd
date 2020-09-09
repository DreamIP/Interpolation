------------------------------------------------------------------------------
-- Title      : four_piece_function
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : four_piece_function.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: 2D interpolation based on approximated cubic kernel with four_piecewise
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity four_piece_function is
    generic (
        PIXEL_SIZE : integer := 8;
        x_y_size   : integer := 9 
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        -- control
        in_dv  : in std_logic;
        in_fv  : in std_logic;
        enable : in std_logic;

        -- pixel coordinates
        x : in std_logic_vector((x_y_size - 1) downto 0);
        y : in std_logic_vector((x_y_size - 1) downto 0);
 
        -- neighboring pixels
        in_data00, in_data01, in_data02, in_data03 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data10, in_data11, in_data12, in_data13 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data20, in_data21, in_data22, in_data23 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data30, in_data31, in_data32, in_data33 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);

        -- interpolated pixel
        out_pixel : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
        out_dv    : out std_logic;
        out_fv    : out std_logic 
    );
end four_piece_function;
architecture rtl of four_piece_function is
 --------------------------------------------------------------------------------
 -- SIGNALS
 --------------------------------------------------------------------------------
    signal out_s0, out_s1, out_s2, out_s3 : std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);
    signal out_dv_s, out_fv_s             : std_logic;
    signal x1,x2,x3,x4,x5,x6,x7,x8     : std_logic_vector(x_y_size - 1 downto 0);
    --------------------------------------------------------------------------------
    -- COMPONENTS
    --------------------------------------------------------------------------------
 
    component four_piecewise
        generic (
            PIXEL_SIZE : integer;
            x_y_size   : integer 
        );
        port (
            clk                                            : in std_logic;
            reset                                          : in std_logic;
            in_dv                                          : in std_logic;
            in_fv                                          : in std_logic;
            enable                                         : in std_logic;
            x                                              : in std_logic_vector((x_y_size - 1) downto 0);
            in_data00, in_data01, in_data02, in_data03     : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            in_data10, in_data11, in_data12, in_data13     : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            in_data20, in_data21, in_data22, in_data23     : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            in_data30, in_data31, in_data32, in_data33     : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            out_pixel0, out_pixel1, out_pixel2, out_pixel3 : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
            out_dv                                         : out std_logic;
            out_fv                                         : out std_logic 
        );
    end component;
    --------------------------------------------------------------------------------

    component four_piecewise1
        generic (
            PIXEL_SIZE : integer;
            x_y_size   : integer 
        );
        port (
            clk                                        : in std_logic;
            reset                                      : in std_logic;
            in_dv                                      : in std_logic;
            in_fv                                      : in std_logic;
            enable                                     : in std_logic;
            x                                          : in std_logic_vector((x_y_size - 1) downto 0);
            in_data00, in_data01, in_data02, in_data03 : in std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);
            out_pixel                                  : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
            out_dv                                     : out std_logic;
            out_fv                                     : out std_logic 
        );
    end component;
    --------------------------------------------------------------------------------

begin
    
    -- The four_piecewise interpolations in the first direction 
    four_piecewise_inst0 : four_piecewise
        generic map(
        PIXEL_SIZE => PIXEL_SIZE, 
        x_y_size   => x_y_size
        )
        port map(
            clk        => clk, 
            reset      => reset, 
            enable     => enable, 
            x          => y, 
            in_dv      => in_dv, 
            in_fv      => in_fv, 
            in_data00  => in_data00, 
            in_data01  => in_data01, 
            in_data02  => in_data02, 
            in_data03  => in_data03, 
            in_data10  => in_data10, 
            in_data11  => in_data11, 
            in_data12  => in_data12, 
            in_data13  => in_data13, 
            in_data20  => in_data20, 
            in_data21  => in_data21, 
            in_data22  => in_data22, 
            in_data23  => in_data23, 
            in_data30  => in_data30, 
            in_data31  => in_data31, 
            in_data32  => in_data32, 
            in_data33  => in_data33, 
            out_pixel0 => out_s0, 
            out_pixel1 => out_s1, 
            out_pixel2 => out_s2, 
            out_pixel3 => out_s3, 
            out_dv     => out_dv_s, 
            out_fv     => out_fv_s 
        ); 
     --------------------------------------------------------------------------------
        
        -- pipeline 
          process (clk,reset) 
            begin
            if (reset = '0')     then
           
            elsif   (RISING_EDGE(clk)) then 
                  if (enable = '1') then    
                    -- position pipeline (8 stages of the first direction)
                    x1 <= x; 
                    x2 <= x1;
                    x3 <= x2;
                    x4 <= x3;
                    x5 <= x4;
                    x6 <= x5;
                    x7 <= x6;
                    x8 <= x7;
                  end if;                    
            end if; 
           end process; 
           -------------------------------------------------------------------------------- 
                
           -- The four_piecewise interpolation in the second direction
            four_piecewise1_inst0 : four_piecewise1
                generic map(
                PIXEL_SIZE => PIXEL_SIZE, 
                x_y_size   => x_y_size
                )
                port map(
                    clk       => clk, 
                    reset     => reset, 
                    enable    => enable, 
                    x         => x8, 
                    in_dv     => out_dv_s, 
                    in_fv     => out_fv_s, 
                    in_data00 => out_s0, 
                    in_data01 => out_s1, 
                    in_data02 => out_s2, 
                    in_data03 => out_s3, 
                    out_pixel => out_pixel, 
                    out_dv    => out_dv, 
                    out_fv    => out_fv 
                ); 
 
end rtl;
