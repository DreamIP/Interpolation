------------------------------------------------------------------------------
-- Title : three_cubic_two_modified_linear
-- Project : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File : three_cubic_two_modified_linear.vhd
-- Author : S. BOUKHTACHE
-- Company : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: 2D interpolation based on combination of three cubic and two modified linear interpolations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity three_cubic_two_modified_linear is
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
        in_data20, in_data21, in_data22, in_data23 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
        in_data30, in_data31, in_data32, in_data33 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);

        -- interpolated pixel
        out_pixel : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
        out_dv    : out std_logic;
        out_fv    : out std_logic 
    ); 
end three_cubic_two_modified_linear;

architecture rtl of three_cubic_two_modified_linear is

    --------------------------------------------------------------------------------
    -- SIGNALS
    -------------------------------------------------------------------------------- 
 
    signal out_s0, out_s1, out_s2, out_s3,out_s00,out_s03 : std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);
    signal out_dv_s, out_fv_s             : std_logic;
    signal x2, x3, x4, x5, x6, x7, x8, x9 : std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);
    signal y2, y3, y4, y5, y6, y7, y8, y9 : std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);
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

begin
    -- deux modified linear interpolations in the first direction 

    process (clk, reset)
    begin
        if (reset = '0') then
            out_s0 <= (others => '0');
            out_s3 <= (others => '0'); 
        elsif (RISING_EDGE(clk)) then
            if (enable = '1') then
                if (x < "010000000") then
                    out_s00 <= "0000000000" & in_data01;
                    out_s03 <= "0000000000" & in_data31;
 
                elsif (x < "110000000") then
                    out_s00 <= std_logic_vector(shift_right(signed("0000000000" & in_data01) + signed("0000000000" & in_data02), 1));
                    out_s03 <= std_logic_vector(shift_right(signed("0000000000" & in_data31) + signed("0000000000" & in_data32), 1));
 
                else
                    out_s00 <= "0000000000" & in_data02;
                    out_s03 <= "0000000000" & in_data32;
                end if;
 
                x2     <= out_s00;
                y2     <= out_s03;
 
                x3     <= x2;
                y3     <= y2;
 
                x4     <= x3;
                y4     <= y3;
 
                x5     <= x4;
                y5     <= y4;
 
                x6     <= x5;
                y6     <= y5;
 
                x7     <= x6;
                y7     <= y6;
 
                x8     <= x7;
                y8     <= y7;
 
                out_s0 <= x8;
                out_s3 <= y8;
 
            end if; 
        end if;
 
    end process;
    --------------------------------------------------------------------------------

    -- The first cubic interpolation in the first direction 
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
            out_pixel => out_s1 
        ); 
            --------------------------------------------------------------------------------

            -- The second cubic interpolation in the first direction
            cubic_inst2 : cubi
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
                    in_data00 => in_data20, 
                    in_data01 => in_data21, 
                    in_data02 => in_data22, 
                    in_data03 => in_data23, 
                    out_pixel => out_s2, 
                    out_dv    => out_dv_s, 
                    out_fv    => out_fv_s 
                ); 
                    --------------------------------------------------------------------------------

                    -- The Third cubic interpolation in the second direction
                    cubic1_inst0 : cubi1
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
                            in_data00 => out_s0, 
                            in_data01 => out_s1, 
                            in_data02 => out_s2, 
                            in_data03 => out_s3, 
                            out_pixel => out_pixel, 
                            out_dv    => out_dv, 
                            out_fv    => out_fv 
                        ); 

 
end rtl;