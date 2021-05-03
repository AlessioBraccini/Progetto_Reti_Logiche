library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity project_reti_logiche is

    port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_start : in std_logic;
            i_data : in std_logic_vector(7 downto 0);
            o_address : out std_logic_vector(15 downto 0);
            o_done : out std_logic;
            o_en : out std_logic;
            o_we : out std_logic;
            o_data : out std_logic_vector (7 downto 0)
    );

end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

    signal elemTerminati: std_logic;
    signal numelemi, numelemi_next: integer;
    signal numelem2, numelem2_next: integer;
    signal max, max_next: integer;
    signal min, min_next: integer;
    signal dv, dv_next: integer;
    signal dv1, dv1_next:  std_logic_vector(7 downto 0);
    signal sl, sl_next: integer;
    signal log, log_next:  std_logic_vector(2 downto 0);
    signal numrig, numcol, numcol_next, numrig_next : std_logic_vector(7 downto 0);
    signal address, address_next: std_logic_vector(15 downto 0);
    signal address2, address2_next: std_logic_vector(15 downto 0);
    signal minl, minl_next: std_logic_vector(15 downto 0);
    signal minl8, minl8_next: std_logic_vector(7 downto 0);
    
    type S is (
        START,
        INIT,
        GET_ROW,
        ROW_WFR,
        GET_COL,
        CALC_ELEM,
        LOAD_ADDRESS,
        PREPARE_FOR_MAXMIN,
        MAX_MIN_WFR,
        CALC_MAXMIN,
        CALC_DV,
        CONV_DV,
        CALC_LOG2,
        CALC_SL,
        LOAD_IADDRESS,        
        INPUT_WFR, 
        STORE_VALUE,
        DONE 
    );
    
    signal cur_state, next_state : S;
    
    begin
    
        process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
            
                cur_state <= START;
                
            elsif rising_edge(i_clk) then
            
                cur_state <= next_state;
                numcol <= numcol_next;
                numrig <= numrig_next;
                address <= address_next;
                address2 <= address2_next;
                max <= max_next;
                min <= min_next;
                numelemi <= numelemi_next;
                numelem2 <= numelem2_next;
                dv <= dv_next;
                dv1 <= dv1_next;
                log <= log_next;
                sl <= sl_next;
                minl <= minl_next;
                minl8 <= minl8_next;
            end if;
            
        end process;
        
    process(cur_state, i_start, elemTerminati, numelemi, numelemi, numelem2, max,  min, minl8, minl, dv, dv1, sl, log, numrig, numcol, address, address2)
        
        begin
        
            o_en <= '0';
            o_we <= '0';
            o_address <= "0000000000000000";
            o_done <= '0';
            o_data <= "00000000";
            
            next_state <= cur_state;
            
            elemTerminati <= '0';
            
            numelemi_next <= 0;
            numelem2_next <= 0;
            max_next <= 0;
            min_next <= 255;
            minl8_next <= "00000000";
            minl_next <= "0000000000000000";
            dv_next <= 0;
            dv1_next <= "00000000";
            sl_next <= 0;
            log_next <= "000";
            numrig_next <= "00000000"; 
            numcol_next <= "00000000";
            address_next <= "0000000000000000";
            address2_next <= "0000000000000000";
        
            case cur_state is
    
                when START =>
                    o_address <= "0000000000000000";
                    o_en <= '1';

                    if i_start = '1' then
                        next_state <= INIT;
                    end if;
                
                when INIT =>

                    if (i_rst = '0') then
                        next_state <= GET_ROW;
                    else
                        next_state <= START;
                    end if;
                    
                when GET_ROW =>
                    numrig_next <= i_data;
                    o_address <= "0000000000000001";
                    o_en <= '1';
                    
                    if (i_rst = '0') then
                        next_state <= ROW_WFR;
                    else
                        next_state <= START;
                    end if;
                    
                when ROW_WFR =>
                    
                    numrig_next <= numrig;
                    
                    if (i_rst = '0') then
                        next_state <= GET_COL; 
                    else
                        next_state <= START;
                    end if;
                    
                when GET_COL =>
                    o_address <= "0000000000000001";
                    numcol_next <= i_data;
                    numrig_next <= numrig;

                    if (i_rst = '0') then
                        next_state <= CALC_ELEM; 
                    else
                        next_state <= START;
                    end if;
                    
                when CALC_ELEM =>
                
                    if numrig > "000000000" then               
                        numelemi_next <= numelemi + to_integer(unsigned(numcol));
                        numrig_next <= numrig - 1;  
                    else 
                        numelemi_next <= numelemi;                              
                    end if;
                    
                    numcol_next <= numcol;

                    if (i_rst = '0') then
                        if numrig = 0 then 
                            next_state <= PREPARE_FOR_MAXMIN;
                        else
                            next_state <= CALC_ELEM;
                        end if; 
                    else
                        next_state <= START;
                    end if;

                when PREPARE_FOR_MAXMIN =>
                    address_next <= "0000000000000010";
                    max_next <= 0;
                    min_next <= 255;
                    
                    numelem2_next <= numelemi;
                    numelemi_next <= numelemi;

                    if (i_rst = '0') then
                        if numelemi = 0 then 
                            next_state <= DONE;
                        else
                            next_state <= LOAD_ADDRESS;
                        end if; 
                    else
                        next_state <= START;
                    end if;

                when LOAD_ADDRESS =>
                    address_next <= address + x"0001";
                    o_address <= address;
                    o_en <= '1';
                    
                    max_next <= max;
                    min_next <= min;                    
                    numelemi_next <= numelemi;
                    numelem2_next <= numelem2;
                    address2_next <= address2;

                    if (i_rst = '0') then
                        next_state <= MAX_MIN_WFR;
                    else
                        next_state <= START;
                    end if;

                when MAX_MIN_WFR =>  

                     address_next <= address;
                     address2_next <= address2;
                     max_next <= max;
                     min_next <= min; 
                     numelemi_next <= numelemi;
                     numelem2_next <= numelem2;

                     if (i_rst = '0') then
                        next_state <= CALC_MAXMIN;
                    else
                        next_state <= START;
                    end if;

                when CALC_MAXMIN =>
                
                     o_address <= address;
                     if (to_integer(unsigned(i_data)) < min) then 
                        min_next <= to_integer(unsigned(i_data));
                     else
                        min_next <= min; 
                     end if;
                     
                     if (to_integer (unsigned(i_data)) > max) then 
                        max_next <= to_integer(unsigned(i_data));
                     else
                        max_next <= max;
                     end if;
                     
                     numelemi_next <= numelemi - 1;
                     if (numelemi = 1) then
                        elemTerminati <= '1';   
                     else
                        elemTerminati <= '0';
                     end if;
                     
                     address2_next <= address;
                    
                    if (i_rst = '0') then
                        
                        if elemTerminati = '1'  then
                            next_state <= CALC_DV;
                        else
                            next_state <= LOAD_ADDRESS;
                        end if;
                    else
                        next_state <= START;
                     end if;
                     
                     numelem2_next <= numelem2;
                     address_next <= address; 

                when CALC_DV =>
                    elemTerminati <= '0';
                    dv_next <= max-min+1;
                    
                    numelem2_next <= numelem2;
                    address2_next <= address2;
                    min_next <= min;
 
                    if (i_rst = '0') then
                        next_state <= CONV_DV;
                    else
                        next_state <= START;
                    end if;

                when CONV_DV =>
                    if(dv > 255) then
                        dv_next <= dv;
                    else
                        dv1_next <= std_logic_vector(to_unsigned(dv, dv1'length));
                    end if;
                    
                    numelem2_next <= numelem2;
                    address2_next <= address2;
                    min_next <= min;

                    if (i_rst = '0') then
                        next_state <= CALC_LOG2;
                    else
                        next_state <= START;
                    end if;

                when CALC_LOG2=> 
                    
                    if (dv > 255) then
                    
                        dv_next <= dv;
                        
                    else
                    
                        if dv1(7) = '1' then 
                            log_next <= "111";
                         elsif dv1(6) = '1' then 
                            log_next <= "110";
                         elsif dv1(5) = '1' then 
                            log_next <= "101";
                         elsif dv1(4) = '1' then 
                            log_next <= "100";
                         elsif dv1(3) = '1' then 
                            log_next <= "011";
                         elsif dv1(2) = '1' then 
                            log_next <= "010";
                         elsif dv1(1) = '1' then 
                            log_next <= "001";
                         else 
                            log_next <= "000";
                         end if;
                         
                     end if;

                    elemTerminati <= '0';
                    
                    numelem2_next <= numelem2;
                    address2_next <= address2;
                    min_next <= min;
               
                    if (i_rst = '0') then
                        next_state <= CALC_SL;
                    else
                        next_state <= START;
                    end if;
 
                when CALC_SL =>
                    if dv > 255 then 
                        sl_next <= 0;
                    else
                        sl_next <= 8 - to_integer(unsigned(log));
                    end if;
                    
                    address_next <= x"0002";
                    address2_next <= address2; 
                        
                    
                    minl_next <= std_logic_vector(to_unsigned(min,16));
                    minl8_next <= std_logic_vector(to_unsigned(min,8));
                    
                    numelem2_next <= numelem2;
  
                    if (i_rst = '0') then
                        next_state <= LOAD_IADDRESS;
                    else
                        next_state <= START;
                    end if;
   
                 when LOAD_IADDRESS=>
                    o_en <= '1';
                    o_address <= address;      
                    
                    numelem2_next <= numelem2;
                    sl_next <= sl;
                    address_next <= address;
                    address2_next <= address2;
                    minl_next <= minl;
                    minl8_next <= minl8;
 
                    if (i_rst = '0') then
                        next_state <= INPUT_WFR;
                    else
                        next_state <= START;
                    end if;

                 when INPUT_WFR =>

                    numelem2_next <= numelem2;
                    sl_next <= sl;
                    minl_next <= minl;
                    minl8_next <= minl8;
                    address_next <= address;
                    address2_next <= address2;
                    
                    if (i_rst = '0') then
                        next_state <= STORE_VALUE;
                    else
                        next_state <= START;
                    end if;

                 when STORE_VALUE=>
                 
                    o_address <= address2;
                           
                    if ((std_logic_vector(shift_left(unsigned(i_data-minl),sl))) < "0000000011111111") then
                       o_data <= std_logic_vector(shift_left(unsigned(i_data-minl8),sl));
                    else
                        o_data <= "11111111";
                    end if;

                    o_we <= '1';
                    o_en <= '1';
                    
                    address_next <= address + x"0001";
                    address2_next <= address2 + x"0001";

                    numelem2_next <= numelem2 - 1;
                     if (numelem2 = 1) then
                        elemTerminati <= '1';   
                     else
                        elemTerminati <= '0';
                     end if;
                     
                    sl_next <= sl;
                    minl_next <= minl;
                    minl8_next <= minl8;
                    
                    if (i_rst = '0') then
                        
                        if elemTerminati = '1' then
                            next_state <= DONE;
                        else
                            next_state <= LOAD_IADDRESS;
                        end if;
                       
                    else
                        next_state <= START;
                    end if;
 
                 when DONE=> 
                    elemTerminati <= '0';
                    o_done <= '1';
                        
                        if(i_start = '1') then
                            next_state <= START;
                        else
                            next_state <= DONE;
                        end if;                    
                    
             end case;            
        
    end process;

end Behavioral;
