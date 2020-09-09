------------------------------------------------------------------------------
-- Title      : linear interpolation
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : linear1.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: one dimensional linear interpolation (second direction)
------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

entity linear1 is
    generic (
        PIXEL_SIZE :integer; 
        x_y_size   :integer       
            );
    port(
        clk   : in std_logic;
        reset : in std_logic;

        -- control 
        in_dv       : in  std_logic;
        in_fv       : in  std_logic;
        enable      : in  std_logic;
         
          -- data 
        in_data0,in_data1    : in std_logic_vector(PIXEL_SIZE+x_y_size downto 0);
          
        -- position of interpolation      
        x           : in std_logic_vector((x_y_size-1) downto 0);
        
        -- interpolated pixel      
        out_pixel   : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);  
        out_dv      : out std_logic;
        out_fv      : out std_logic  
    );    
end linear1;
 
 
architecture rtl of linear1 is

--------------------------------------------------------------------------------
-- SIGNALS
-------------------------------------------------------------------------------- 
  
  signal A0,A1,p                                                           : signed((PIXEL_SIZE + x_y_size) downto 0);
  signal xx,sig14                                                          : signed(x_y_size downto 0);
  signal sig10,sig11,sig20,sig21                                           : signed((PIXEL_SIZE + x_y_size) downto 0);
  signal sig30,sig40,sig50,sig60,sig70,sig80                               : signed((PIXEL_SIZE + x_y_size) downto 0);
  signal x1,x2,x3,x4,x5,x6,x7,x8,x9                                        : signed(x_y_size downto 0);
  signal in_dv1,in_dv2,in_dv3,in_dv4,in_dv5,in_dv6,in_dv7,in_dv8           : std_logic; 
  signal in_fv1,in_fv2,in_fv3,in_fv4,in_fv5,in_fv6,in_fv7,in_fv8           : std_logic; 
  
begin
  
  A0 <= signed(in_data0);
  A1 <= signed(in_data1);
  xx <= signed('0'& x); 
  
  -- full-pipelined architecture 
    process (clk,reset) 
        begin

            if (reset = '0')     then
                p <= (others => '0');
                out_dv <=  '0'; 
                out_fv <=  '0';
           
            elsif   (RISING_EDGE(clk)) then 
                  if (enable = '1') then
                    -- position pipeline (9 stages of the first direction stages)
                    x1 <= xx; 
                    x2 <= x1;
                    x3 <= x2;
                    x4 <= x3;
                    x5 <= x4;
                    x6 <= x5;
                    x7 <= x6;
                    x8 <= x7;
                    x9 <= x8;
                    
                    -- fisrt stage  
                    sig10  <= A0; 
                    sig11  <= A1-A0; 
                    sig14  <= x9; 
                    in_dv1 <= in_dv;
                    in_fv1 <= in_fv;
                    
                   -- second stage 
                    sig20  <= sig10;
                    sig21  <= resize(shift_right(sig11*Sig14,x_y_size),PIXEL_SIZE+x_y_size+1);
                    in_dv2 <= in_dv1;
                    in_fv2 <= in_fv1;
                    
                  
                    -- third stage 
                    sig30  <= resize(sig21 + sig20,PIXEL_SIZE+x_y_size+1) ;
                    in_dv3 <= in_dv2;
                    in_fv3 <= in_fv2;
                    
                    -- fourth stage 
                    sig40  <= sig30; 
                    in_dv4 <= in_dv3;
                    in_fv4 <= in_fv3;
                    
                    --  fiveth stage 
                    sig50  <= sig40;
                    in_dv5 <= in_dv4;
                    in_fv5 <= in_fv4;
                    
                    -- sixth stage 
                    sig60  <= sig50;
                    in_dv6 <= in_dv5;
                    in_fv6 <= in_fv5;
                    
                     -- 7 stage 
                    sig70  <= sig60;
                    in_dv7 <= in_dv6;
                    in_fv7 <= in_fv6;
                    
                     -- 8 stage 
                    sig80  <= sig70;
                    in_dv8 <= in_dv7;
                    in_fv8 <= in_fv7;
                    
                    -- 9 stage 
                    p      <= sig80;  
                    out_dv <= in_dv8;
                    out_fv <= in_fv8;

                end if;                    
            end if; 
    end process; 

    out_pixel <= std_logic_vector(p);  
  
end rtl;




