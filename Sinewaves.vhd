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
      FiringPulse_RisingEdge   : in std_logic_vector(15 downto 0);
      FiringPulse_FallingEdge  : in std_logic_vector(15 downto 0);
      Thyristors               : out std_logic_vector(5 downto 0);
      LED                      : out std_logic_vector(7 downto 0)
      );
end ThreePhase_SCRs_Controller;

architecture rtl of ThreePhase_SCRs_Controller is

signal SquareWave1           : std_logic; 
signal SquareWave1_dly1      : std_logic;
signal SquareWave1_dly2      : std_logic;

signal SquareWave2           : std_logic; 
signal SquareWave2_dly1      : std_logic;
signal SquareWave2_dly2      : std_logic;

signal SquareWave3           : std_logic; 
signal SquareWave3_dly1      : std_logic;
signal SquareWave3_dly2      : std_logic;

--signal FiringPulse_RisingEdge:integer range 0 to 1333335; 
--signal FiringPulse_FallingEdge:integer range 0 to 1333335; 

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

signal  FiringPulse_RisingEdge_latch   : std_logic_vector(15 downto 0);
signal  FiringPulse_FallingEdge_latch  : std_logic_vector(15 downto 0);
      
      
type SineConstants_Array is array(0 to 399) of integer range -1241 to 1241;     --signed(12 downto 0); --400 constants 11 bits each
constant SineConstants  : SineConstants_Array := (

19,39,58,78,97,117,136,156,175,194,213,233,252,271,290,309,328,346,365,384,402,420,439,457,475,493,511,528,546,563,581,
598,615,632,649,665,681,698,714,730,745,761,776,791,806,821,835,850,864,878,891,905,918,931,944,956,969,981,993,1004,1015,
1027,1037,1048,1058,1068,1078,1088,1097,1106,1115,1123,1131,1139,1147,1154,1161,1168,1174,1180,1186,1192,1197,1202,1207,
1211,1215,1219,1223,1226,1229,1231,1234,1236,1237,1239,1240,1241,1241,1241,1241,1241,1240,1239,1237,1236,1234,1231,1229,
1226,1223,1219,1215,1211,1207,1202,1197,1192,1186,1180,1174,1168,1161,1154,1147,1139,1131,1123,1115,1106,1097,1088,1078,
1068,1058,1048,1037,1027,1015,1004,993,981,969,956,944,931,918,905,891,878,864,850,835,821,806,791,776,761,745,730,714,
698,681,665,649,632,615,598,581,563,546,528,511,493,475,457,439,420,402,384,365,346,328,309,290,271,252,233,213,194,175,
156,136,117,97,78,58,39,19,0,-19,-39,-58,-78,-97,-117,-136,-156,-175,-194,-213,-233,-252,-271,-290,-309,-328,-346,-365,
-384,-402,-420,-439,-457,-475,-493,-511,-528,-546,-563,-581,-598,-615,-632,-649,-665,-681,-698,-714,-730,-745,-761,-776,
-791,-806,-821,-835,-850,-864,-878,-891,-905,-918,-931,-944,-956,-969,-981,-993,-1004,-1015,-1027,-1037,-1048,-1058,-1068,
-1078,-1088,-1097,-1106,-1115,-1123,-1131,-1139,-1147,-1154,-1161,-1168,-1174,-1180,-1186,-1192,-1197,-1202,-1207,-1211,
-1215,-1219,-1223,-1226,-1229,-1231,-1234,-1236,-1237,-1239,-1240,-1241,-1241,-1241,-1241,-1241,-1240,-1239,-1237,-1236,
-1234,-1231,-1229,-1226,-1223,-1219,-1215,-1211,-1207,-1202,-1197,-1192,-1186,-1180,-1174,-1168,-1161,-1154,-1147,-1139,
-1131,-1123,-1115,-1106,-1097,-1088,-1078,-1068,-1058,-1048,-1037,-1027,-1015,-1004,-993,-981,-969,-956,-944,-931,-918,
-905,-891,-878,-864,-850,-835,-821,-806,-791,-776,-761,-745,-730,-714,-698,-681,-665,-649,-632,-615,-598,-581,-563,-546,
-528,-511,-493,-475,-457,-439,-420,-402,-384,-365,-346,-328,-309,-290,-271,-252,-233,-213,-194,-175,-156,-136,-117,-97,
-78,-58,-39,-19,0);

begin

--------------------------------------------------------------------------
--Sine waves generation:
--------------------------------------------------------------------------
SineWaves:process (clock,reset)


variable counter      : integer range 0 to 5000;

begin

   if(reset='0') then
		Sine1_out<=(others=>'Z');
		Sine2_out<=(others=>'Z');
		Sine3_out<=(others=>'Z');
		
		Sine1_out_dly<=(others=>'Z');
        Sine2_out_dly<=(others=>'Z');
        Sine3_out_dly<=(others=>'Z');
                
		index1 <=0;
		index2 <=133;
		index3 <=266;
   elsif(rising_edge(clock)) then
      counter :=counter+1;
           if(counter=5000) then
              Sine1_out<= std_logic_vector(to_signed(SineConstants(index1),12));  
              Sine2_out<= std_logic_vector(to_signed(SineConstants(index2),12)); 
              Sine3_out<= std_logic_vector(to_signed(SineConstants(index3),12));
        
              Sine1_out_dly<=Sine1_out;
              Sine2_out_dly<=Sine2_out;
              Sine3_out_dly<=Sine3_out;
              
              if(index1<399) then
              index1<=index1+1;
              else
              index1<=0;
              end if;
              
              if(index2<399) then
              index2<=index2+1;
              else
              index2<=0;
              end if;
                          
              if(index3<399) then
              index3<=index3+1;
              else
              index3<=0;
              end if;
                                                     
             counter :=0;
        end if;
            
   end if;        
end process SineWaves;

----------------------------------------------------
--squareWaves generation/ Real signals input
------------------------------------------------------
Gen_Squarewaves: process(clock,reset)

begin

if(reset='0') then
 
   SquareWave1  <='0';
   SquareWave1_dly1  <='0';
   SquareWave1_dly2  <='0';
    
   SquareWave2  <='0';
   SquareWave2_dly1  <='0';    
   SquareWave2_dly2  <='0'; 
    
   SquareWave3  <='0';
   SquareWave3_dly1  <='0';
   SquareWave3_dly2  <='0';
   
elsif(rising_edge(clock)) then

    SquareWave1_dly1 <=SquareWave1; 
    SquareWave1_dly2 <=SquareWave1_dly1;
    
    SquareWave2_dly1 <=SquareWave2;
    SquareWave2_dly2 <=SquareWave2_dly1;
        
    SquareWave3_dly1 <=SquareWave3;
    SquareWave3_dly2 <=SquareWave3_dly1;
    
    if(Sine1_out(11)='0') then
       SquareWave1<='1';
    else
       SquareWave1<='0';
    end if;
    
    if(Sine2_out(11)='0') then
       SquareWave2<='1';
    else
       SquareWave2<='0';
    end if;
    
    if(Sine3_out(11)='0') then
       SquareWave3<='1';
    else
       SquareWave3<='0';
    end if;
    
end if; 
 
end process Gen_Squarewaves;

 ----------------------------------------------------
--Squarewave Comparator Process
---------------------------------------------------
SquareWave_Compatator: process(clock,reset)

begin

     if(reset='0') then
     
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
counters:process (clock,reset,SynchFlag2)

begin

  if(reset='0' OR SynchFlag2='0' ) then
  
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
        PhaseCounter1<=3;              --set to 3 to account for latching delay of Sinewave1_CrossUp
        SynchFlag1(0)<='1';
        end if;
               
   PhaseCounter2<=PhaseCounter2+1; 
      if(SW3_CrossDwn_Pulse='1')then
         PhaseCounter2<=3; 
         SynchFlag1(1)<='1';             --set to 3 to account for latching delay of Sinewave3_CrossDwn
        end if; 
        
   PhaseCounter3<=PhaseCounter3+1; 
     if(SW2_CrossUp_Pulse='1')then       --set to 3 to account for latching delay of Sinewave2_CrossUp
       PhaseCounter3<=3;
       SynchFlag1(2)<='1';
       end if;
       
   PhaseCounter4<=PhaseCounter4+1;
      if(SW1_CrossDwn_Pulse='1')then
        PhaseCounter4<=3;              --set to 3 to account for latching delay of Sinewave1_CrossDwn
        SynchFlag1(3)<='1';
       end if; 
       
   PhaseCounter5<=PhaseCounter5+1; 
   if(SW3_CrossUp_Pulse='1')then
     PhaseCounter5<=3;                -- --set to 3 to account for latching delay of Sinewave3_CrossUp
     SynchFlag1(4)<='1';
    end if;
    
   PhaseCounter6<=PhaseCounter6+1; 
   if(SW2_CrossDwn_Pulse='1')then         
      PhaseCounter6<=3;              --set to 3 to account for latching delay of Sinewave2_CrossDwn
      SynchFlag1(5)<='1';
    end if;
  
   
   end if;  
 end process counters; 
----------------------------------------------------------------------------------------

SCRs_Control:process (clock,reset)

begin

  if(reset='0') then
 
   Thyristors_Sig<=(others=>'0');
	  
  elsif(rising_edge(clock)) then
     --------------------------------------------------------------
	  --SCR T1 Control   --Sinewave1_CrossUp='1'
	  ---------------------------------------------------------------   
            if(PhaseCounter1=FiringPulse_RisingEdge) then
              Thyristors_Sig(0)<='1'; --T1
            elsif(PhaseCounter1=FiringPulse_FallingEdge)then
              Thyristors_Sig(0)<='0';
			 end if;
	  --------------------------------------------------------------
	  --SCR T2 Control  --Sinewave3_CrossDwn='1' 
	  -------------------------------------------------------  
           if(PhaseCounter2=FiringPulse_RisingEdge) then
			  Thyristors_Sig(1)<='1'; --
           elsif(PhaseCounter2=FiringPulse_FallingEdge)then
             Thyristors_Sig(1)<='0';
		  end if;
     --------------------------------------------------------------
	  --SCR T3 Control	--Sinewave2_CrossUp='1'	
     -----------------------------------------------------------
         if(PhaseCounter3=FiringPulse_RisingEdge) then
           Thyristors_Sig(2)<='1';  --
         elsif(PhaseCounter3=FiringPulse_FallingEdge)then
           Thyristors_Sig(2)<='0';
         end if;	
	 --------------------------------------------------------------
	 --SCR T4 Control    --Sinewave1_CrossDwn='1'
	 ----------------------------------------------------------
          if(PhaseCounter4=FiringPulse_RisingEdge) then
             Thyristors_Sig(3)<='1'; --T3 and T2
          elsif(PhaseCounter4=FiringPulse_FallingEdge)then
             Thyristors_Sig(3)<='0';
          end if;
	-------------------------------------------------------------
	--SCR T5 Control  --Sinewave3_CrossUp='1'
	-------------------------------------------------------------
          if(PhaseCounter5=FiringPulse_RisingEdge) then
             Thyristors_Sig(4)<='1'; 
          elsif(PhaseCounter5=FiringPulse_FallingEdge)then
             Thyristors_Sig(4)<='0';
          end if;
	--------------------------------------------------------------
	--SCR T6 Control  --Sinewave2_CrossDwn='1'
	--------------------------------------------------------------
       if(PhaseCounter6=FiringPulse_RisingEdge) then
          Thyristors_Sig(5)<='1'; 
       elsif(PhaseCounter6=FiringPulse_FallingEdge)then
          Thyristors_Sig(5)<='0';
       end if;  
  end if;
end process;
------------------------------------------------------------------------------------
 process(clock,reset)
 
 begin
 
      if reset = '0' then
      
      SynchFlag2<='0';
      FiringPulse_RisingEdge_latch<=(others=>'0');
      FiringPulse_FallingEdge_latch<=(others=>'0');
      
       elsif rising_edge(clock) then
       
       FiringPulse_RisingEdge_latch<=FiringPulse_RisingEdge;
       FiringPulse_FallingEdge_latch<=FiringPulse_FallingEdge;
       
       if(FiringPulse_RisingEdge_latch/=FiringPulse_RisingEdge)OR (FiringPulse_FallingEdge_latch/=FiringPulse_FallingEdge)then
       SynchFlag2<='1';
       else
       SynchFlag2<='0';
       end if; 

   end if; 
   
   end process; 
------------------------------------------------------------------------------------------------------------------------------------------
 count : process(clock,reset)
   variable count : natural range 0 to 100000000;
    begin
       if reset = '0' then
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
    Thyristors<=Thyristors_Sig when (SynchFlag1="111111" OR  SynchFlag2='0')  else"000000" ;
    
end rtl;

 
