library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all; 
   
entity ThreePhase_SCRs_Controller is

generic (FullCycle_Counts:integer:=2000000      -- =20ms/10ns; 20ms is period of sinewave
	     );

port (
      clock                    : in  std_logic;
      reset                    : in  std_logic;
      SquareWave1              : in  std_logic;
      SquareWave2              : in  std_logic;
      SquareWave3              : in  std_logic;
      PS_reset                 : in  std_logic;
      FiringPulse_RisingEdge   : in std_logic_vector(31 downto 0);
      FiringPulse_FallingEdge  : in std_logic_vector(31 downto 0);
      Thyristors               : out std_logic_vector(5 downto 0);
      LED                      : out std_logic_vector(7 downto 0)
      );
end ThreePhase_SCRs_Controller;

architecture rtl of ThreePhase_SCRs_Controller is

signal SquareWave1_dly1      : std_logic;
signal SquareWave1_dly2      : std_logic;

signal SquareWave2_dly1      : std_logic;
signal SquareWave2_dly2      : std_logic;

signal SquareWave3_dly1      : std_logic;
signal SquareWave3_dly2      : std_logic;


signal SW1_CrossUp_Pulse  : std_logic;
signal SW1_CrossDwn_Pulse : std_logic;
signal SW2_CrossUp_Pulse  : std_logic;
signal SW2_CrossDwn_Pulse : std_logic;
signal SW3_CrossUp_Pulse  : std_logic;
signal SW3_CrossDwn_Pulse : std_logic;
  
signal LED_Sig    : std_logic_vector(7 downto 0);

signal Pulse_sig      : std_logic; 
signal Sine1_out      : std_logic_vector(11 downto 0);--integer range -1241 to 1241; 
signal Sine1_out_dly  : std_logic_vector(11 downto 0);--integer range -1241 to 1241;
signal Sine2_out      : std_logic_vector(11 downto 0);--integer range -1241 to 1241; 
signal Sine2_out_dly  : std_logic_vector(11 downto 0);--integer range -1241 to 1241;
signal Sine3_out      : std_logic_vector(11 downto 0);--integer range -1241 to 1241; 
signal Sine3_out_dly  : std_logic_vector(11 downto 0);--integer range -1241 to 1241;
signal Sine1_out_dly2 : std_logic_vector(11 downto 0);--integer range -1241 to 1241;


signal Sinewave1_CrossUp      :  std_logic;
signal Sinewave1_CrossUp_dly1 :  std_logic;
signal Sinewave1_CrossUp_dly2 :  std_logic;
signal Sinewave1_CrossDwn     :  std_logic;
signal Sinewave1_CrossDwn_dly1:  std_logic;
signal Sinewave1_CrossDwn_dly2:  std_logic;
signal Sinewave2_CrossUp      :  std_logic;
signal Sinewave2_CrossUp_dly1 :  std_logic;
signal Sinewave2_CrossUp_dly2 :  std_logic;
signal Sinewave2_CrossDwn     :  std_logic;
signal Sinewave2_CrossDwn_dly1:  std_logic;
signal Sinewave2_CrossDwn_dly2:  std_logic;
signal Sinewave3_CrossUp      :  std_logic;
signal Sinewave3_CrossUp_dly1 :  std_logic;
signal Sinewave3_CrossUp_dly2 :  std_logic;
signal Sinewave3_CrossDwn     :  std_logic;
signal Sinewave3_CrossDwn_dly1:  std_logic;
signal Sinewave3_CrossDwn_dly2:  std_logic;

signal Thyristors_Sig   : std_logic_vector(5 downto 0);

signal PhaseCounter1: integer range 0 to FullCycle_Counts; --equal to 10 ms/half cycle
signal PhaseCounter2: integer range 0 to FullCycle_Counts; --equal to 10 ms/half cycle
signal PhaseCounter3: integer range 0 to FullCycle_Counts;
signal PhaseCounter4: integer range 0 to FullCycle_Counts;
signal PhaseCounter5: integer range 0 to FullCycle_Counts;
signal PhaseCounter6: integer range 0 to FullCycle_Counts;

signal index1       : integer range 0 to 400;  -- 110001111  399
signal index2       : integer range 0 to 400;  -- 110001111  399
signal index3       : integer range 0 to 400;  -- 110001111  399

signal SynchFlag1   : std_logic_vector(5 downto 0);
signal SynchFlag2   : std_logic;

signal  FiringPulse_RisingEdge_dly1   :  std_logic_vector(31 downto 0);
signal  FiringPulse_FallingEdge_dly1  :  std_logic_vector(31 downto 0);
signal  FiringPulse_RisingEdge_dly2   :  std_logic_vector(31 downto 0);
signal  FiringPulse_FallingEdge_dly2  :  std_logic_vector(31 downto 0);

signal  reset_int    :  std_logic; 
      

begin

----------------------------------------------------
-- Real signals input
------------------------------------------------------
Gen_Squarewaves: process(clock,reset_int)

begin

if(reset_int='0') then
 
   SquareWave1_dly1  <='0';
   SquareWave1_dly2  <='0';
    
   SquareWave2_dly1  <='0';    
   SquareWave2_dly2  <='0'; 
    
   SquareWave3_dly1  <='0';
   SquareWave3_dly2  <='0';
   
elsif(rising_edge(clock)) then

    SquareWave1_dly1 <=SquareWave1; 
    SquareWave1_dly2 <=SquareWave1_dly1;
    
    SquareWave2_dly1 <=SquareWave2;
    SquareWave2_dly2 <=SquareWave2_dly1;
        
    SquareWave3_dly1 <=SquareWave3;
    SquareWave3_dly2 <=SquareWave3_dly1;  
    
end if; 
 
end process Gen_Squarewaves;

 ----------------------------------------------------
--Squarewave Comparator Process
---------------------------------------------------
SquareWave_Compatator: process(clock,reset_int)

begin

     if(reset_int='0') then
     
     SW1_CrossUp_Pulse<= '0';
     SW1_CrossDwn_Pulse<= '0';
     
     SW2_CrossUp_Pulse<= '0';
     SW2_CrossDwn_Pulse<= '0';
      
     SW3_CrossUp_Pulse<= '0';
     SW3_CrossDwn_Pulse<= '0';
                
     elsif(rising_edge(clock)) then
   
        if(SquareWave1_dly2='0' and SquareWave1='1')then
           SW1_CrossUp_Pulse<= '1';
        elsif(SquareWave1_dly2='1' and SquareWave1='0')then
           SW1_CrossDwn_Pulse<= '1';
         else
           SW1_CrossUp_Pulse<= '0';
           SW1_CrossDwn_Pulse<= '0';
        end if; 
          
        if(SquareWave2_dly2='0' and SquareWave2='1')then
           SW2_CrossUp_Pulse<= '1';
        elsif(SquareWave2_dly2='1' and SquareWave2='0')then
           SW2_CrossDwn_Pulse<= '1';
        else
           SW2_CrossUp_Pulse<= '0';
           SW2_CrossDwn_Pulse<= '0';
        end if;
          
        if(SquareWave3_dly2='0' and SquareWave3='1')then
           SW3_CrossUp_Pulse<= '1';
        elsif(SquareWave3_dly2='1' and SquareWave3='0')then
           SW3_CrossDwn_Pulse<= '1';
        else
           SW3_CrossUp_Pulse<= '0';
           SW3_CrossDwn_Pulse<= '0';
        end if;
            
    end if;    
 end process SquareWave_Compatator;
 
----------------------------------------------------
--Timer counters 
------------------------------------------------------
counters:process (clock,reset_int)

begin

  --if(reset='0' OR SynchFlag2='0' ) then
  if(reset_int='0') then
  
   PhaseCounter1<=0;
   PhaseCounter2<=0;
   PhaseCounter3<=0;
   PhaseCounter4<=0;
   PhaseCounter5<=0;
   PhaseCounter6<=0;
     
   SynchFlag1<="000000";
   
   elsif(rising_edge(clock)) then
   
    
    PhaseCounter1<=PhaseCounter1+1;
      if(SW1_CrossUp_Pulse='1')then
        PhaseCounter1<=0;              --set to 3 to account for latching delay of Sinewave1_CrossUp
        SynchFlag1(0)<='1';
        end if;
               
   PhaseCounter2<=PhaseCounter2+1; 
      if(SW3_CrossDwn_Pulse='1')then
         PhaseCounter2<=0; 
         SynchFlag1(1)<='1';             --set to 3 to account for latching delay of Sinewave3_CrossDwn
        end if; 
        
   PhaseCounter3<=PhaseCounter3+1; 
     if(SW2_CrossUp_Pulse='1')then       --set to 3 to account for latching delay of Sinewave2_CrossUp
       PhaseCounter3<=0;
       SynchFlag1(2)<='1';
       end if;
       
   PhaseCounter4<=PhaseCounter4+1;
      if(SW1_CrossDwn_Pulse='1')then
        PhaseCounter4<=0;              --set to 3 to account for latching delay of Sinewave1_CrossDwn
        SynchFlag1(3)<='1';
       end if; 
       
   PhaseCounter5<=PhaseCounter5+1; 
   if(SW3_CrossUp_Pulse='1')then
     PhaseCounter5<=0;                -- --set to 3 to account for latching delay of Sinewave3_CrossUp
     SynchFlag1(4)<='1';
    end if;
    
   PhaseCounter6<=PhaseCounter6+1; 
   if(SW2_CrossDwn_Pulse='1')then         
      PhaseCounter6<=0;              --set to 3 to account for latching delay of Sinewave2_CrossDwn
      SynchFlag1(5)<='1';
    end if;
  
   
   end if;  
 end process counters; 
----------------------------------------------------------------------------------------

SCRs_Control:process (clock,reset_int)

begin

  if(reset_int='0') then
 
   Thyristors_Sig<=(others=>'0');
	  
  elsif(rising_edge(clock)) then
     --------------------------------------------------------------
	  --SCR T1 Control   --Sinewave1_CrossUp='1'
	  ---------------------------------------------------------------   
            if(PhaseCounter1=FiringPulse_RisingEdge) then
              Thyristors_Sig(5)<='1';   --T1
            elsif(PhaseCounter1=FiringPulse_FallingEdge)then
              Thyristors_Sig(5)<='0';
			 end if;
	  --------------------------------------------------------------
	  --SCR T2 Control  --Sinewave3_CrossDwn='1' 
	  -------------------------------------------------------  
           if(PhaseCounter2=FiringPulse_RisingEdge) then
			 Thyristors_Sig(4)<='1'; --T2
           elsif(PhaseCounter2=FiringPulse_FallingEdge)then
             Thyristors_Sig(4)<='0';
		  end if;
     --------------------------------------------------------------
	  --SCR T3 Control	--Sinewave2_CrossUp='1'	
     -----------------------------------------------------------
         if(PhaseCounter3=FiringPulse_RisingEdge) then  
           Thyristors_Sig(3)<='1'; 
         elsif(PhaseCounter3=FiringPulse_FallingEdge)then
           Thyristors_Sig(3)<='0';
         end if;	
	 --------------------------------------------------------------
	 --SCR T4 Control    --Sinewave1_CrossDwn='1'
	 ----------------------------------------------------------
          if(PhaseCounter4=FiringPulse_RisingEdge) then
             Thyristors_Sig(2)<='1';
          elsif(PhaseCounter4=FiringPulse_FallingEdge)then
             Thyristors_Sig(2)<='0';
          end if;
	-------------------------------------------------------------
	--SCR T5 Control  --Sinewave3_CrossUp='1'
	-------------------------------------------------------------
          if(PhaseCounter5=FiringPulse_RisingEdge) then
             Thyristors_Sig(1)<='1';
          elsif(PhaseCounter5=FiringPulse_FallingEdge)then
             Thyristors_Sig(1)<='0';
          end if;
	--------------------------------------------------------------
	--SCR T6 Control  --Sinewave2_CrossDwn='1'
	--------------------------------------------------------------
       if(PhaseCounter6=FiringPulse_RisingEdge) then
          Thyristors_Sig(0)<='1';
       elsif(PhaseCounter6=FiringPulse_FallingEdge)then
           Thyristors_Sig(0)<='0';
       end if;  
  end if;
end process;
----------------------------------------------------------------------------------------------
 count : process(clock,reset_int)
   variable count : natural range 0 to 100000000;
    begin
       if reset_int = '0' then
            count := 0;
            LED_Sig <= "00000000";
        elsif rising_edge(clock) then
              count := count + 1;
              if (count=100000000) then
                  LED_Sig(6 downto 0) <= not LED_Sig(6 downto 0);
                  count := 0;
               end if;
         end if;
    end process count; 
      
    --Combinatorial logic   
    LED(6 downto 0)<= LED_Sig(6 downto 0);     

    Thyristors<=Thyristors_Sig when (SynchFlag1="111111")  else"000000" ;
    
    reset_int<='0' when (reset='0' OR PS_reset='1') else '1';
    
    
end rtl;

 