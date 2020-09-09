------------------------------------------------------------------------------
-- Title      : four_piecewise
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : four_piecewise.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: 1D interpolation (first direction) based on approximated cubic kernel with four_piecewise
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity four_piecewise is
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
        x : in std_logic_vector((x_y_size - 1) downto 0);
 
        -- neighboring pixels
        in_data00, in_data01, in_data02, in_data03 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data10, in_data11, in_data12, in_data13 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data20, in_data21, in_data22, in_data23 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data30, in_data31, in_data32, in_data33 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);

        -- interpolated pixel
        out_pixel0, out_pixel1, out_pixel2, out_pixel3 : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
        out_dv                                         : out std_logic;
        out_fv                                         : out std_logic 
    ); 
end four_piecewise;
architecture rtl of four_piecewise is
--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------  
    signal out_s0, out_s1, out_s2, out_s3 : std_logic_vector((x_y_size + 5) downto 0);
    signal x0, x1, x2, x3                 : std_logic_vector((x_y_size + 2) downto 0); 
    signal out_dv_s, out_fv_s             : std_logic;
    signal in_dv1, in_fv1                 : std_logic;
    --------------------------------------------------------------------------------
    -- COMPONENTS
    --------------------------------------------------------------------------------
    component piece
        generic (
            PIXEL_SIZE : integer;
            x_y_size   : integer 
        );
        port (
            clk       : in std_logic;
            reset     : in std_logic;
            in_dv     : in std_logic;
            in_fv     : in std_logic;
            enable    : in std_logic;
            x         : in std_logic_vector((x_y_size + 2) downto 0);
            out_pixel : out std_logic_vector((x_y_size + 5) downto 0); 
            out_dv    : out std_logic;
            out_fv    : out std_logic 
        ); 
    end component;
    --------------------------------------------------------------------------------

    component piece_interp
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
            x0, x1, x2, x3                             : in std_logic_vector((x_y_size + 5) downto 0);
            in_data00, in_data01, in_data02, in_data03 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            out_pixel                                  : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
            out_dv                                     : out std_logic;
            out_fv                                     : out std_logic 
        ); 
    end component;
    --------------------------------------------------------------------------------
begin
    x0 <= std_logic_vector(signed("001" & x));
    x1 <= std_logic_vector(signed("000" & x));
    x2 <= std_logic_vector(signed("001000000000" - signed("000" & x)));
    x3 <= std_logic_vector(signed("010000000000" - signed("000" & x)));
 
    -- define the first coefficient of the first 1D interpolation
    piece_inst0 : piece
        generic map(
        PIXEL_SIZE => PIXEL_SIZE, 
        x_y_size   => x_y_size
        )
        port map(
            clk       => clk, 
            reset     => reset, 
            enable    => enable, 
            x         => x0, 
            in_dv     => in_dv, 
            in_fv     => in_fv, 
            out_pixel => out_s0 
        ); 
     --------------------------------------------------------------------------------   
        
            -- define the second coefficient of the first 1D interpolation
            piece_inst1 : piece
                generic map(
                PIXEL_SIZE => PIXEL_SIZE, 
                x_y_size   => x_y_size
                )
                port map(
                    clk       => clk, 
                    reset     => reset, 
                    enable    => enable, 
                    x         => x1, 
                    in_dv     => in_dv, 
                    in_fv     => in_fv, 
                    out_pixel => out_s1 
                ); 
            --------------------------------------------------------------------------------   
                
                    -- define the third coefficient of the first 1D interpolation
                    piece_inst2 : piece
                        generic map(
                        PIXEL_SIZE => PIXEL_SIZE, 
                        x_y_size   => x_y_size
                        )
                        port map(
                            clk       => clk, 
                            reset     => reset, 
                            enable    => enable, 
                            x         => x2, 
                            in_dv     => in_dv, 
                            in_fv     => in_fv, 
                            out_pixel => out_s2 
                        );
                    --------------------------------------------------------------------------------   
                
                            -- define the fourth coefficient of the first 1D interpolation
                            piece_inst3 : piece
                                generic map(
                                PIXEL_SIZE => PIXEL_SIZE, 
                                x_y_size   => x_y_size
                                )
                                port map(
                                    clk       => clk, 
                                    reset     => reset, 
                                    enable    => enable, 
                                    x         => x3, 
                                    in_dv     => in_dv, 
                                    in_fv     => in_fv, 
                                    out_pixel => out_s3, 
                                    out_dv    => out_dv_s, 
                                    out_fv    => out_fv_s 
                                ); 
                             --------------------------------------------------------------------------------   
                
                                    -- The first 1D interpolation in the first direction 
                                    piece_interp_inst0 : piece_interp
                                        generic map(
                                        PIXEL_SIZE => PIXEL_SIZE, 
                                        x_y_size   => x_y_size
                                        )
                                        port map(
                                            clk       => clk, 
                                            reset     => reset, 
                                            enable    => enable, 
                                            in_dv     => out_dv_s, 
                                            in_fv     => out_fv_s, 
                                            in_data00 => in_data00, 
                                            in_data01 => in_data01, 
                                            in_data02 => in_data02, 
                                            in_data03 => in_data03, 
                                            x0        => out_s0, 
                                            x1        => out_s1, 
                                            x2        => out_s2, 
                                            x3        => out_s3, 
                                            out_pixel => out_pixel0 
                                        ); 
                                     --------------------------------------------------------------------------------   
                
                                            -- The second 1D interpolation in the first direction 
                                            piece_interp_inst1 : piece_interp
                                                generic map(
                                                PIXEL_SIZE => PIXEL_SIZE, 
                                                x_y_size   => x_y_size
                                                )
                                                port map(
                                                    clk       => clk, 
                                                    reset     => reset, 
                                                    enable    => enable, 
                                                    in_dv     => out_dv_s, 
                                                    in_fv     => out_fv_s, 
                                                    in_data00 => in_data10, 
                                                    in_data01 => in_data11, 
                                                    in_data02 => in_data12, 
                                                    in_data03 => in_data13, 
                                                    x0        => out_s0, 
                                                    x1        => out_s1, 
                                                    x2        => out_s2, 
                                                    x3        => out_s3, 
                                                    out_pixel => out_pixel1 
                                                ); 
                                             --------------------------------------------------------------------------------   
                
                                                   -- The third 1D interpolation in the first direction 
                                                    piece_interp_inst2 : piece_interp
                                                        generic map(
                                                        PIXEL_SIZE => PIXEL_SIZE, 
                                                        x_y_size   => x_y_size
                                                        )
                                                        port map(
                                                            clk       => clk, 
                                                            reset     => reset, 
                                                            enable    => enable, 
                                                            in_dv     => out_dv_s, 
                                                            in_fv     => out_fv_s, 
                                                            in_data00 => in_data20, 
                                                            in_data01 => in_data21, 
                                                            in_data02 => in_data22, 
                                                            in_data03 => in_data23, 
                                                            x0        => out_s0, 
                                                            x1        => out_s1, 
                                                            x2        => out_s2, 
                                                            x3        => out_s3, 
                                                            out_pixel => out_pixel2 
                                                        ); 
                                                   --------------------------------------------------------------------------------   
                
                                                            -- The fourth 1D interpolation in the first direction 
                                                            piece_interp_inst3 : piece_interp
                                                                generic map(
                                                                PIXEL_SIZE => PIXEL_SIZE, 
                                                                x_y_size   => x_y_size
                                                                )
                                                                port map(
                                                                    clk       => clk, 
                                                                    reset     => reset, 
                                                                    enable    => enable, 
                                                                    in_dv     => out_dv_s, 
                                                                    in_fv     => out_fv_s, 
                                                                    in_data00 => in_data30, 
                                                                    in_data01 => in_data31, 
                                                                    in_data02 => in_data32, 
                                                                    in_data03 => in_data33, 
                                                                    x0        => out_s0, 
                                                                    x1        => out_s1, 
                                                                    x2        => out_s2, 
                                                                    x3        => out_s3, 
                                                                    out_pixel => out_pixel3, 
                                                                    out_dv    => out_dv, 
                                                                    out_fv    => out_fv 
                                                                ); 

end rtl;
