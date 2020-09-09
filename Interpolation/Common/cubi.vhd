------------------------------------------------------------------------------
-- Title      : cubic interpolation
-- Project    : alternatives to bicubic interpolation
------------------------------------------------------------------------------
-- File       : cubi.vhd
-- Author     : S. BOUKHTACHE
-- Company    : Institut Pascal
-- Last update: 06-03-2020
------------------------------------------------------------------------------
-- Description: one dimensional cubic interpolation (first direction)
------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

entity cubi is
    generic (
        PIXEL_SIZE :integer:=8; 
        x_y_size   :integer:=9        
            ); 
    port(
        clk   : in std_logic;
        reset : in std_logic;
        
        -- control 
        in_dv       : in  std_logic;
        in_fv       : in  std_logic;
        enable      : in  std_logic;

        -- position of interpolation     
        x : in std_logic_vector((x_y_size-1) downto 0);
        
        -- neighbor pixels  
        in_data00,in_data01,in_data02,in_data03 : in std_logic_vector((PIXEL_SIZE -1) downto 0);
       
        -- interpolated pixel 
        out_pixel  : out std_logic_vector((x_y_size + PIXEL_SIZE) downto 0);  
        out_dv     : out std_logic;
        out_fv     : out std_logic  
    );    
end cubi;
 
 
architecture rtl of cubi is

--------------------------------------------------------------------------------
-- SIGNALS
-------------------------------------------------------------------------------- 
  
  signal A00,A01,A02,A03,p                                                       : signed(PIXEL_SIZE+x_y_size downto 0);
  signal xx,sig14,sig24,sig34,sig44,sig54,sig14b,sig14bb                         : signed(x_y_size downto 0);
  signal sig10,sig11,sig12,sig15,sig16,sig17,sig18,sig19,sig200                  : signed(PIXEL_SIZE+x_y_size downto 0);
  signal sig10b,sig11b,sig12b,sig15b,sig16b,sig17b,sig18b                        : signed(PIXEL_SIZE+x_y_size downto 0);
  signal sig10bb,sig11bb,sig12bb,sig15bb,sig16bb                                 : signed(PIXEL_SIZE+x_y_size downto 0);
  signal sig20,sig21,sig22,sig25,sig26                                           : signed(PIXEL_SIZE+x_y_size downto 0);
  signal sig30,sig31,sig32,sig35                                                 : signed(PIXEL_SIZE+x_y_size downto 0);
  signal sig40,sig41,sig42,sig45                                                 : signed(PIXEL_SIZE+x_y_size downto 0);
  signal sig51,sig55,sig61,sig65                                                 : signed(PIXEL_SIZE+x_y_size downto 0);
  signal in_dv1,in_dv2,in_dv3,in_dv4,in_dv5,in_dv6,in_dv1b,in_dv1bb              : std_logic; 
  signal in_fv1,in_fv2,in_fv3,in_fv4,in_fv5,in_fv6,in_fv1b,in_fv1bb              : std_logic; 
  
begin
  
  A00 <= signed('0'& in_data00&"000000000");
  A01 <= signed('0'& in_data01&"000000000");
  A02 <= signed('0'& in_data02&"000000000");
  A03 <= signed('0'& in_data03&"000000000"); 
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

                    -- fisrt stage              
                    sig10   <= A00; 
                    sig11   <= A01;
                    sig12   <= A02; 
                    sig14   <= xx;
                    sig15   <= resize(shift_right(A01,1) + A01,PIXEL_SIZE+x_y_size+1);
                    sig16   <= shift_right( A00,1) + shift_right(A02 ,1);
                    sig17   <= shift_right(A03,1) - A02;
                    sig18   <= A00 - shift_left(A01,1);
                    sig19   <= shift_left(A02,1) - shift_right(A03,1);
                    sig200  <= shift_right(A01,1) ;
                    in_dv1b <= in_dv;
                    in_fv1b <= in_fv;
                    
                    -- fisrt stage bis                       
                    sig10b   <= sig10; 
                    sig11b   <= sig11;
                    sig12b   <= sig12;    
                    sig14b   <= sig14;
                    sig15b   <= sig15-sig16;
                    sig16b   <= sig17;
                    sig17b   <= sig18+sig19;
                    sig18b   <= sig200;
                    in_dv1bb <= in_dv1b;
                    in_fv1bb <= in_fv1b;
                    
                    -- fisrt stage bisbis                    
                    sig10bb <= sig10b; 
                    sig11bb <= sig11b;
                    sig12bb <= sig12b; 
                    sig14bb <= sig14b;
                    sig15bb <= sig15b+sig16b;
                    sig16bb <= sig17b-sig18b;
                    in_dv1  <= in_dv1bb;
                    in_fv1  <= in_fv1bb;
                    
                   -- second stage                 
                    sig20  <= sig10bb; 
                    sig21  <= sig11bb;
                    sig22  <= sig12bb;  
                    sig24  <= sig14bb;
                    sig25  <= resize(shift_right(sig15bb*Sig14bb,x_y_size),PIXEL_SIZE+x_y_size+1);
                    sig26  <= sig16bb;
                    in_dv2 <= in_dv1;
                    in_fv2 <= in_fv1;
                    
                    -- third stage                  
                    sig30  <= sig20; 
                    sig31  <= sig21;
                    sig32  <= sig22; 
                    sig34  <= sig24;
                    sig35  <= sig25 + sig26;
                    in_dv3 <= in_dv2;
                    in_fv3 <= in_fv2;
                    
                    -- fourth stage                     
                    sig40  <= sig30; 
                    sig41  <= sig31;
                    sig42  <= sig32; 
                    sig44  <= sig34;
                    sig45  <= resize(shift_right(sig35*Sig34,x_y_size),PIXEL_SIZE+x_y_size+1);
                    in_dv4 <= in_dv3;
                    in_fv4 <= in_fv3;
                    
                    --  fiveth stage                    
                    sig51  <= sig41;
                    sig54  <= sig44;
                    sig55  <= sig45 + shift_right(sig42 - sig40,1);
                    in_dv5 <= in_dv4;
                    in_fv5 <= in_fv4;
                    
                    -- sixth stage 
                    sig61  <= sig51;
                    sig65  <= resize(shift_right(sig55*Sig54,x_y_size),PIXEL_SIZE+x_y_size+1) ;
                    in_dv6 <= in_dv5;
                    in_fv6 <= in_fv5;
                    
                    -- seventh stage                    
                    p      <= resize(sig65 + sig61,PIXEL_SIZE+x_y_size+1);  
                    out_dv <= in_dv6;
                    out_fv <= in_fv6;
                    
                  
                end if;                    
            end if; 
    end process; 

    out_pixel <= std_logic_vector(p);  
  
end rtl;



