------------------------------------------------------------------------------
-- Title : two_cubic_linear
-- Project : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File : two_cubic_linear.vhd
-- Author : S. BOUKHTACHE
-- Company : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: 2D interpolation based on combination of two cubic and one linear interpolations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 

entity two_cubic_linear is
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

        -- position of interpolation 
        x : in std_logic_vector((x_y_size - 1) downto 0);
        y : in std_logic_vector((x_y_size - 1) downto 0);
 
        -- neighboring pixels
        in_data00, in_data01, in_data02, in_data03 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data10, in_data11, in_data12, in_data13 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);

        -- interpolated pixel
        out_pixel : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
        out_dv    : out std_logic;
        out_fv    : out std_logic 
    ); 
end two_cubic_linear;

architecture rtl of two_cubic_linear is
 
    --------------------------------------------------------------------------------
    -- SIGNALS
    -------------------------------------------------------------------------------- 
 
    signal out_s0, out_s1, out_s2, out_s3 : std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);
    signal p                              : signed((x_y_size + PIXEL_SIZE) downto 0);
    signal in_dv_s, in_fv_s               : std_logic;
    signal out_dv_s, out_fv_s             : std_logic;
 
    --------------------------------------------------------------------------------
    -- COMPONENTS
    --------------------------------------------------------------------------------
    component cubi
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
            in_data00, in_data01, in_data02, in_data03 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            out_pixel                                  : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
            out_dv                                     : out std_logic;
            out_fv                                     : out std_logic
        ); 
    end component;
    --------------------------------------------------------------------------------

    component linear1
        generic (
            PIXEL_SIZE : integer;
            x_y_size   : integer 
        ); 
        port (
            clk                : in std_logic;
            reset              : in std_logic;
            in_dv              : in std_logic;
            in_fv              : in std_logic;
            enable             : in std_logic;
            in_data0, in_data1 : in std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
            x                  : in std_logic_vector((x_y_size - 1) downto 0); 
            out_pixel          : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
            out_dv             : out std_logic;
            out_fv             : out std_logic 
        ); 
    end component;
    --------------------------------------------------------------------------------

begin
    -- The first cubic interpolation in the first direction 
    cubic_inst0 : cubi
        generic map(
        PIXEL_SIZE => PIXEL_SIZE, 
        x_y_size   => x_y_size
        )
        port map(
            clk       => clk, 
            reset     => reset, 
            enable    => enable, 
            x         => y, 
            in_dv     => in_dv, 
            in_fv     => in_fv, 
            in_data00 => in_data00, 
            in_data01 => in_data01, 
            in_data02 => in_data02, 
            in_data03 => in_data03, 
            out_pixel => out_s0 
        ); 
            --------------------------------------------------------------------------------
            -- The second cubic interpolation in the first direction 
            cubic_inst1 : cubi
                generic map(
                PIXEL_SIZE => PIXEL_SIZE, 
                x_y_size   => x_y_size
                )
                port map(
                    clk       => clk, 
                    reset     => reset, 
                    enable    => enable, 
                    x         => y, 
                    in_dv     => in_dv, 
                    in_fv     => in_fv, 
                    in_data00 => in_data10, 
                    in_data01 => in_data11, 
                    in_data02 => in_data12, 
                    in_data03 => in_data13, 
                    out_pixel => out_s1, 
                    out_dv    => out_dv_s, 
                    out_fv    => out_fv_s 
                ); 
                    --------------------------------------------------------------------------------
                    -- The linear interpolation in the second direction
                    linear_inst : linear1
                        generic map(
                        PIXEL_SIZE => PIXEL_SIZE, 
                        x_y_size   => x_y_size
                        )
                        port map(
                            clk       => clk, 
                            reset     => reset, 
                            enable    => enable, 
                            x         => x, 
                            in_dv     => out_dv_s, 
                            in_fv     => out_fv_s, 
                            in_data0  => out_s0, 
                            in_data1  => out_s1, 
                            out_pixel => out_pixel, 
                            out_dv    => out_dv, 
                            out_fv    => out_fv 
                        ); 

 
end rtl;