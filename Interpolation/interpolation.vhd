------------------------------------------------------------------------------
-- Title      : interpolation
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : interpolation.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: 2D interpolation based on an approximated cubic kernel
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interpolation is
    generic (
        pixel_size  : integer := 8;
        x_y_size    : integer := 9;
        line_length : integer   -- image width 
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
 
        -- pixels
        in_data : in std_logic_vector((pixel_size - 1) downto 0);
 
        -- interpolated pixel
        out_pixel : out std_logic_vector((x_y_size + pixel_size) downto 0); 
        out_dv    : out std_logic;
        out_fv    : out std_logic 
    ); 
end interpolation;

architecture rtl of interpolation is
    --------------------------------------------------------------------------------
    -- SIGNALS
    --------------------------------------------------------------------------------
    signal p00, p01, p02, p03 : std_logic_vector((pixel_size - 1) downto 0);
    signal p10, p11, p12, p13 : std_logic_vector((pixel_size - 1) downto 0);
    signal p20, p21, p22, p23 : std_logic_vector((pixel_size - 1) downto 0);
    signal p30, p31, p32, p33 : std_logic_vector((pixel_size - 1) downto 0);
    signal in_dv_s, in_fv_s   : std_logic;
	
    --------------------------------------------------------------------------------
    -- COMPONENTS
    -------------------------------------------------------------------------------- 
    component win_extractor 
        generic (
            pixel_size  : integer;
            line_length : integer
        );
        port (
            clk                : in std_logic;
            reset              : in std_logic;
            enable             : in std_logic;
            in_data            : in std_logic_vector (pixel_size - 1 downto 0);
            in_dv              : in std_logic;
            in_fv              : in std_logic;
            p00, p01, p02, p03 : out std_logic_vector (pixel_size - 1 downto 0);
            p10, p11, p12, p13 : out std_logic_vector (pixel_size - 1 downto 0);
            p20, p21, p22, p23 : out std_logic_vector (pixel_size - 1 downto 0);
            p30, p31, p32, p33 : out std_logic_vector (pixel_size - 1 downto 0);
            out_dv             : out std_logic; 
            out_fv             : out std_logic
        );
    end component;
    -------------------------------------------------------------------------------- 
	
    -- add the desired component (in this case the "two_piece_function" ) 
    component two_piece_function
        generic (
            PIXEL_SIZE : integer;
            x_y_size   : integer 
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;
            in_dv  : in std_logic;
            in_fv  : in std_logic;
            enable : in std_logic;
            x : in std_logic_vector((x_y_size - 1) downto 0);
            y : in std_logic_vector((x_y_size - 1) downto 0);
            in_data00, in_data01, in_data02, in_data03 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            in_data10, in_data11, in_data12, in_data13 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            in_data20, in_data21, in_data22, in_data23 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            in_data30, in_data31, in_data32, in_data33 : in std_logic_vector((PIXEL_SIZE - 1) downto 0);
            out_pixel : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0); 
            out_dv    : out std_logic;
            out_fv    : out std_logic 
        );
    end component;
    -------------------------------------------------------------------------------- 

begin

    -- extract the 4x4 neighoring pixels 
    window4x4 : win_extractor
        generic map(
        pixel_size  => pixel_size, 
        line_length => line_length
        )
        port map(
            clk     => clk, 
            reset   => reset, 
            enable  => enable, 
            in_data => in_data, 
            in_dv   => in_dv, 
            in_fv   => in_fv, 
            p00     => p00, 
            p01     => p01, 
            p02     => p02, 
            p03     => p03, 
            p10     => p10, 
            p11     => p11, 
            p12     => p12, 
            p13     => p13, 
            p20     => p20, 
            p21     => p21, 
            p22     => p22, 
            p23     => p23, 
            p30     => p30, 
            p31     => p31, 
            p32     => p32, 
            p33     => p33, 
            out_dv  => in_dv_s, 
            out_fv  => in_fv_s 
        ); 
	--------------------------------------------------------------------------------
			
	    -- perform the 2D interpolation based on the desired approximation 
            two_piece_function_inst : two_piece_function
                generic map(
                PIXEL_SIZE => pixel_size, 
                x_y_size   => x_y_size
                )
                port map(
                    clk       => clk, 
                    reset     => reset, 
                    in_dv     => in_dv_s, 
                    in_fv     => in_fv_s, 
                    enable    => enable, 
                    x         => x, 
                    y         => y, 
                    in_data00 => p00, 
                    in_data01 => p01, 
                    in_data02 => p02, 
                    in_data03 => p03, 
                    in_data10 => p10, 
                    in_data11 => p11, 
                    in_data12 => p12, 
                    in_data13 => p13, 
                    in_data20 => p20, 
                    in_data21 => p21, 
                    in_data22 => p22, 
                    in_data23 => p23, 
                    in_data30 => p30, 
                    in_data31 => p31, 
                    in_data32 => p32, 
                    in_data33 => p33, 
                    out_pixel => out_pixel, 
                    out_dv    => out_dv, 
                    out_fv    => out_fv 
                ); 
end rtl;
