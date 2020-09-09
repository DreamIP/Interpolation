------------------------------------------------------------------------------
-- Title : three_cubic_two_linear
-- Project : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File : three_cubic_two_linear.vhd
-- Author : S. BOUKHTACHE
-- Company : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: 2D interpolation based on combination of three cubic and two linear interpolations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity three_cubic_two_linear is
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
        in_data01, in_data02                       : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data10, in_data11, in_data12, in_data13 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data20, in_data21, in_data22, in_data23 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data31, in_data32                       : in std_logic_vector((PIXEL_SIZE - 1) downto 0);

        -- interpolated pixel
        out_pixel : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
        out_dv    : out std_logic;
        out_fv    : out std_logic 
    ); 
end three_cubic_two_linear;

architecture rtl of three_cubic_two_linear is
    --------------------------------------------------------------------------------
    -- SIGNALS
    -------------------------------------------------------------------------------- 

    signal out_s0, out_s1, out_s2, out_s3         : std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);
    signal out_dv_1, out_dv_2, out_dv_3, out_dv_4 : std_logic;
    signal out_fv_1, out_fv_2, out_fv_3, out_fv_4 : std_logic; 
 
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

    component cubi1
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

    component linear
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
            in_data0, in_data1 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            x                  : in std_logic_vector((x_y_size - 1) downto 0);
            out_pixel          : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
            out_dv             : out std_logic;
            out_fv             : out std_logic 
        ); 
    end component;
    --------------------------------------------------------------------------------

begin
    -- The first linear interpolation in the first direction 
    linear_inst0 : linear
        generic map(
        PIXEL_SIZE => PIXEL_SIZE, 
        x_y_size   => x_y_size
        )
        port map(
            clk       => clk, 
            reset     => reset, 
            enable    => enable, 
            x         => x, 
            in_dv     => in_dv, 
            in_fv     => in_fv, 
            in_data0  => in_data10, 
            in_data1  => in_data20, 
            out_pixel => out_s0, 
            out_dv    => out_dv_1, 
            out_fv    => out_fv_1 
        ); 
            --------------------------------------------------------------------------------
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
                    x         => x, 
                    in_dv     => in_dv, 
                    in_fv     => in_fv, 
                    in_data00 => in_data01, 
                    in_data01 => in_data11, 
                    in_data02 => in_data21, 
                    in_data03 => in_data31, 
                    out_pixel => out_s1, 
                    out_dv    => out_dv_2, 
                    out_fv    => out_fv_2 
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
                            x         => x, 
                            in_dv     => in_dv, 
                            in_fv     => in_fv, 
                            in_data00 => in_data02, 
                            in_data01 => in_data12, 
                            in_data02 => in_data22, 
                            in_data03 => in_data32, 
                            out_pixel => out_s2, 
                            out_dv    => out_dv_3, 
                            out_fv    => out_fv_3 
                        ); 
                            --------------------------------------------------------------------------------
                            -- The second linear interpolation in the first direction
                            linear_inst1 : linear
                                generic map(
                                PIXEL_SIZE => PIXEL_SIZE, 
                                x_y_size   => x_y_size
                                )
                                port map(
                                    clk       => clk, 
                                    reset     => reset, 
                                    enable    => enable, 
                                    x         => x, 
                                    in_dv     => in_dv, 
                                    in_fv     => in_fv, 
                                    in_data0  => in_data13, 
                                    in_data1  => in_data23, 
                                    out_pixel => out_s3, 
                                    out_dv    => out_dv_4, 
                                    out_fv    => out_fv_4 
                                ); 
                                    --------------------------------------------------------------------------------
                                    -- The second cubic interpolation in the second direction 
                                    cubic_inst3 : cubi1
                                        generic map(
                                        PIXEL_SIZE => PIXEL_SIZE, 
                                        x_y_size   => x_y_size
                                        )
                                        port map(
                                            clk       => clk, 
                                            reset     => reset, 
                                            enable    => enable, 
                                            x         => y, 
                                            in_dv     => out_dv_4, 
                                            in_fv     => out_fv_4, 
                                            in_data00 => out_s0, 
                                            in_data01 => out_s1, 
                                            in_data02 => out_s2, 
                                            in_data03 => out_s3, 
                                            out_pixel => out_pixel, 
                                            out_dv    => out_dv, 
                                            out_fv    => out_fv 
                                        ); 
 
end rtl;