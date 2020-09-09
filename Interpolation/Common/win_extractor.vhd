------------------------------------------------------------------------------
-- Title      : win_extractor
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : win_extractor.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: extraction of the 4x4 interpolation window 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity win_extractor is
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
end win_extractor;
architecture bhv of win_extractor is
    type fifo is array (0 to 3 * line_length + 3) of std_logic_vector (pixel_size - 1 downto 0);
    signal fifo_pix                      : fifo;
    signal fifo_fv                       : std_logic_vector (3 * line_length + 3 downto 0);
    signal fifo_dv                       : std_logic_vector (3 * line_length + 3 downto 0);
    signal in_data_s                     : std_logic_vector (pixel_size - 1 downto 0);
    signal out_dv_s, out_dv_ss, out_fv_s : std_logic;
 
begin
    process (clk, reset)
 
    variable i, cmp : integer := 0;
 
    begin
        if (reset = '0') then
 
            fifo_pix <= (others => (others => '0'));
            fifo_dv  <= (others => '0');
            fifo_fv  <= (others => '0');
            out_dv   <= '0';
            out_fv   <= '0';
 
            p00      <= (others => '0');
            p01      <= (others => '0');
            p02      <= (others => '0');
            p03      <= (others => '0');
 
            p10      <= (others => '0');
            p11      <= (others => '0');
            p12      <= (others => '0');
            p13      <= (others => '0');
 
            p20      <= (others => '0');
            p21      <= (others => '0');
            p22      <= (others => '0');
            p23      <= (others => '0');
 
            p30      <= (others => '0');
            p31      <= (others => '0');
            p32      <= (others => '0');
            p33      <= (others => '0');
 

        elsif (rising_edge(clk)) then 
 
            if (in_fv = '1') then
 
                if (in_dv = '1') then
 
                    fifo_pix(0) <= in_data;
                    fifo_fv (0) <= in_fv;
                    fifo_dv (0) <= in_dv;
 
                    for i in 1 to (3 * line_length + 3) loop
                        fifo_pix(i) <= fifo_pix(i - 1);
                        fifo_fv(i)  <= fifo_fv(i - 1);
                        fifo_dv(i)  <= fifo_dv(i - 1);
                    end loop;
 
                    p33      <= fifo_pix(0);
                    p32      <= fifo_pix(1);
                    p31      <= fifo_pix(2);
                    p30      <= fifo_pix(3);
 
                    p23      <= fifo_pix(line_length);
                    p22      <= fifo_pix(line_length + 1);
                    p21      <= fifo_pix(line_length + 2);
                    p20      <= fifo_pix(line_length + 3);
 
                    p13      <= fifo_pix(2 * line_length);
                    p12      <= fifo_pix(2 * line_length + 1);
                    p11      <= fifo_pix(2 * line_length + 2);
                    p10      <= fifo_pix(2 * line_length + 3);
 
                    p03      <= fifo_pix(3 * line_length);
                    p02      <= fifo_pix(3 * line_length + 1);
                    p01      <= fifo_pix(3 * line_length + 2); 
                    p00      <= fifo_pix(3 * line_length + 3);
 
                    out_fv_s <= fifo_fv(3 * line_length + 3);
                    out_dv_s <= fifo_dv(3 * line_length + 3);
 
 
                    if (fifo_fv(3 * line_length + 3) = '1') then
                        out_fv <= '1';
 
                        if (fifo_dv(3 * line_length + 3) = '1') then 
                            if ((cmp = (line_length - 3)) or (cmp = (line_length - 2)) or (cmp = (line_length - 1))) then
                                out_dv <= '0';
                            elsif (cmp = (line_length)) then
                                cmp := 0; 
                                out_dv <= '1';
                            else 
                                out_dv <= '1';
                            end if;
                            cmp := cmp + 1;
 
                        else
                            out_dv <= '0';
                        end if;
                    else
                        out_fv <= '0';
                        out_dv <= '0';
                    end if;
 
                else
                    out_dv <= '0';
                end if;
            else
                p33      <= fifo_pix(0);
                p32      <= fifo_pix(1);
                p31      <= fifo_pix(2);
                p30      <= fifo_pix(3);
 
                p23      <= fifo_pix(line_length);
                p22      <= fifo_pix(line_length + 1);
                p21      <= fifo_pix(line_length + 2);
                p20      <= fifo_pix(line_length + 3);
 
                p13      <= fifo_pix(2 * line_length);
                p12      <= fifo_pix(2 * line_length + 1);
                p11      <= fifo_pix(2 * line_length + 2);
                p10      <= fifo_pix(2 * line_length + 3);
 
                p03      <= fifo_pix(3 * line_length);
                p02      <= fifo_pix(3 * line_length + 1);
                p01      <= fifo_pix(3 * line_length + 2); 
                p00      <= fifo_pix(3 * line_length + 3);
 
                out_fv   <= fifo_fv(3 * line_length + 3);
                out_dv   <= fifo_dv(3 * line_length + 3);
 
 
                fifo_pix <= (others => (others => '0'));
                fifo_dv  <= (others => '0');
                fifo_fv  <= (others => '0');
                cmp := 0;
            end if;
 
        end if;
 
    end process;
end bhv;
