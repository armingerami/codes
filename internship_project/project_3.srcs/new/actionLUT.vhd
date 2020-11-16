

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity action_lut is
GENERIC ( 
  OPENFLOW_MATCH_SIZE: INTEGER:= 256;
  OPENFLOW_MASK_SIZE : INTEGER:= 256;
  OPENFLOW_ACTION_SIZE: INTEGER:= 256;
  ADDRESS_SIZE: integer:= 10
  
);
PORT (
     asclk					  : IN STD_LOGIC;
     rsten 					  : IN STD_LOGIC;
     flow_entry_req 		  : IN STD_LOGIC; --agar 1 bashad iani input jadidi baraie check vared shode ast
     input_to_check 		  : IN STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE- 1 DOWNTO 0);
     input_to_write 		  : IN STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE- 1 DOWNTO 0);
	 mask_enable 			  : IN STD_LOGIC;
	 mask_to_write 					  : IN STD_LOGIC_VECTOR(OPENFLOW_MASK_SIZE-1 DOWNTO 0);
	 we						  : IN STD_LOGIC;
	 check_match 			  : OUT STD_LOGIC; --agar 1 bashad iani match peida shode ast
	 in_action 				  : IN STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE - 1 DOWNTO 0); --action baraie neveshte shodan
	 out_action 			  : OUT STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE - 1 DOWNTO 0);
	 table_is_full 			  : OUT STD_LOGIC;
	 lu_done 				  : OUT STD_LOGIC;
	 lu_ack 				  : OUT STD_LOGIC;
	 req_num 				  : IN STD_LOGIC_VECTOR(5 downto 0); --bedanim az kodam cache estefade konim
	 clear_en 				  : IN STD_LOGIC; --agar 1 bashad clear shoroo mishavad
	 input_to_clear 		  : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0); --clear
	 fwd_redy 				  : IN STD_LOGIC; --az forwarder miaiad ta bedanim amade dariaft ast ia kheir
	 w_ready 				  : OUT STD_LOGIC --be controller ersal mishavad ta bedanad amade neveshtan va pak kardan ast ia kheir
	 );
END action_lut;

----------------------------------------------- look-up
architecture Behavioral of action_lut is
component my_memory
port (
addra 						  : IN STD_LOGIC_VECTOR(ADDRESS_SIZE-1 downto 0);
addrb 						  : IN STD_LOGIC_VECTOR(ADDRESS_SIZE-1 downto 0);
clka 						  : IN STD_LOGIC;
clkb 						  : IN STD_LOGIC;
dina 						  : IN STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE-1 downto 0);
doutb 						  : OUT STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE-1 downto 0);
wea 						  : IN STD_LOGIC_VECTOR(0 downto 0)
);
END component;
component full_memory
port (
addra 						  : IN STD_LOGIC_VECTOR(ADDRESS_SIZE-1 downto 0);
clka 						  : IN STD_LOGIC;
dina 						  : IN STD_LOGIC_VECTOR(0 downto 0);
douta 						  : OUT STD_LOGIC_VECTOR(0 downto 0);
ena 						  : IN STD_LOGIC;
wea 						  : IN STD_LOGIC_VECTOR(0 downto 0)
);
END component;
TYPE search_state is (hold,start,continue,done);
SIGNAL search_state_nxt,write_state,clear_state : search_state;

--signalhaie marbot be 5 memory
SIGNAL addrs1r,addrs1w,addrs2r,addrs2w,addrs3r,addrs3w,addrs4,addrs5r 	: STD_LOGIC_VECTOR(ADDRESS_SIZE-1 downto 0);
SIGNAL output1,output2,output3,output5 									: STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 downto 0);
SIGNAL output4 															: STD_LOGIC_VECTOR (0 downto 0);
SIGNAL in1,in2,in3 														: STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 downto 0);
SIGNAL in4 																: STD_LOGIC_VECTOR (0 downto 0);
SIGNAL we1,we2,we3,we4 													: STD_LOGIC_VECTOR(0 downto 0);
SIGNAL policy_input 													: STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 downto 0);

SIGNAL i,j,k 															: STD_LOGIC_VECTOR(10 downto 0); -- i,j,k shomarandehaie lookup, write, clear
SIGNAL lim,limw														    : STD_LOGIC_VECTOR(9 downto 0); -- lim baraie danestan hadeaksar tedad khanehaie por va limw baraie update kardan lim

 -- vojood 2 SIGNAL zir be IN dalil ast ke ba avaz shodane voroodi va ta peida shodane javab khorooji ghalat nabashad
SIGNAL req_num_p 														: STD_LOGIC_VECTOR(5 downto 0);
SIGNAL input_to_check_p 												: STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 downto 0);

BEGIN
PROCESS(asclk,rsten,search_state_nxt,flow_entry_req,input_to_check,req_num)
--karbord in 3 variable emal mask ast
VARIABLE masked_input 													: STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
VARIABLE masked 														: STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
VARIABLE the_mask 														: STD_LOGIC_VECTOR(OPENFLOW_MASK_SIZE-1 DOWNTO 0);

VARIABLE the_output 													: STD_LOGIC_VECTOR(OPENFLOW_MASK_SIZE-1 DOWNTO 0);

VARIABLE cache_i,cache1_i,cache2_i,cache3_i,cache4_i,cache5_i,cache6_i  : STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 downto 0);
VARIABLE cache_a,cache1_a,cache2_a,cache3_a,cache4_a,cache5_a,cache6_a  : STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 downto 0);

VARIABLE ludone 														: STD_LOGIC;
VARIABLE luack 															: STD_LOGIC;
VARIABLE check 															: STD_LOGIC; --agar check 1 bashad iani match peida shode ast
VARIABLE cache_check 													: STD_LOGIC; --agar cacje_check 1 bashad iani match az tarigh cache peida shode ast
VARIABLE oo 															: STD_LOGIC;
--vojoode oo be dalil in ast ke ba avalin reset dastgah va shoroo kar lim sefr bashad, albate dar amal baiad hadeaghal 4 bashad

BEGIN
IF (rsten = '1') THEN
	search_state_nxt <= hold;
	cache_i := (others=>'0');
	cache_a := (others=>'0');
	cache1_i := (others=>'0');
	cache1_a := (others=>'0');
	cache2_i := (others=>'0');
	cache2_a := (others=>'0');
	cache3_i := (others=>'0');
	cache3_a := (others=>'0');
	cache4_i := (others=>'0');
	cache4_a := (others=>'0');
	cache5_i := (others=>'0');
	cache5_a := (others=>'0');
	cache6_i := (others=>'0');
	cache6_a := (others=>'0');
	addrs1r <= (others=>'0');
	addrs2r <= (others=>'0');
	addrs3r <= (others=>'0');
	IF (oo /= '1') THEN
		lim <= B"0000000100";
	END IF;
	check_match <='1';
	req_num_p <= B"000000";
	input_to_check_p <= (others=>'0');
	lu_done <= '0';
	lu_ack <= '0';
	i <= (others => '0');
ELSIF (asclk'event and asclk = '1') THEN
    IF ( limw > lim ) THEN
        lim <= limw ;
    END IF;
    IF ( cache1_i = input_to_clear and clear_en = '1') THEN
          cache1_i := (others => '0');
    ELSIF ( cache2_i = input_to_clear and clear_en = '1') THEN
          cache2_i := (others => '0');
    ELSIF ( cache3_i = input_to_clear and clear_en = '1') THEN
          cache3_i := (others => '0');
    ELSIF ( cache4_i = input_to_clear and clear_en = '1') THEN
          cache4_i := (others => '0');
    ELSIF ( cache5_i = input_to_clear and clear_en = '1') THEN
          cache5_i := (others => '0');
    ELSIF ( cache6_i = input_to_clear and clear_en = '1') THEN
          cache6_i := (others => '0');
    END IF;      
    IF (req_num_p /= req_num or input_to_check /= input_to_check_p) THEN
        search_state_nxt <= hold;
        req_num_p <= req_num;
        input_to_check_p <= input_to_check;
        lu_done <= '0';
        lu_ack <= '0';
        out_action <= (others => '0');
    ELSE
    IF (req_num = B"000001") THEN
        cache_i := cache1_i;
        cache_a := cache1_a;
    ELSIF (req_num = B"000010") THEN
        cache_i := cache2_i;
        cache_a := cache2_a;
    ELSIF (req_num = B"000100") THEN
        cache_i := cache3_i;
        cache_a := cache3_a;
    ELSIF (req_num = B"001000") THEN
        cache_i := cache4_i;
        cache_a := cache4_a;
    ELSIF (req_num = B"010000") THEN
        cache_i := cache5_i;
        cache_a := cache5_a;
    ELSIF (req_num = B"1000000") THEN
        cache_i := cache6_i;
        cache_a := cache6_a;
    END IF;
    CASE search_state_nxt is 
        WHEN hold =>
			lu_done <= '0';
			lu_ack <= '0';
			IF (flow_entry_req = '1') THEN
				search_state_nxt <= start;                     
			ELSE
				search_state_nxt <= hold;
			END IF;
		WHEN start =>                
			IF (cache_i = input_to_check) THEN
				check := '1';
				search_state_nxt <= done;
				cache_check := '1';
			ELSE
				check := '0';
				cache_check := '0';    
				addrs1r <= (others => '0');
				addrs3r <= (others => '0');
				addrs2r <= (others => '0');
				i <= (others => '0');
				search_state_nxt <= continue;
			END IF;
		WHEN continue =>
			lu_done <= '0';                  
			IF ( i > lim) THEN
				check := '0';
				search_state_nxt <= done;
			ELSE
				IF (mask_enable = '1') THEN            
					the_mask := output3;
					masked := the_mask or output1;
					masked_input := the_mask or input_to_check;
					IF ( masked = masked_input ) THEN
						check := '1';
						the_output := output2;
						search_state_nxt <= done;            
					ELSE
						addrs1r <= addrs1r + B"1";
						addrs3r <= addrs3r + B"1";
						addrs2r <= addrs2r + B"1";
						search_state_nxt <= continue;
						i <= i + B"1";             
					END IF;
				ELSE
					IF ( output1 = input_to_check ) THEN
						check := '1';
						the_output := output2;
						search_state_nxt <= done;                               
					ELSE
						addrs1r <= addrs1r + B"1";
						addrs2r <= addrs2r + B"1";
						search_state_nxt <= continue;
						i <= i + B"1"; 
					END IF;                      
				END IF;    
			END IF;
		WHEN done =>
			IF (fwd_redy = '0') THEN
				search_state_nxt <= done;
			ELSE    
				check_match <= check;
				IF (check = '1') THEN
					out_action <= the_output; 
					IF (cache_check = '0') THEN
						IF (req_num = B"000001") THEN
							cache1_i := input_to_check;
							cache1_a := the_output;          
						ELSIF (req_num = B"000010") THEN
							cache2_i := input_to_check;
							cache2_a := the_output;
						ELSIF (req_num = B"000100") THEN
							cache3_i := input_to_check;
							cache3_a := the_output;
						ELSIF (req_num = B"001000") THEN
							cache4_i := input_to_check;
							cache4_a := the_output;
						ELSIF (req_num = B"010000") THEN
							cache5_i := input_to_check;
							cache5_a := the_output;
						ELSIF (req_num = B"100000") THEN
							cache6_i := input_to_check;
							cache6_a := the_output;
						END IF;
					ELSIF (cache_check = '1') THEN
						out_action <= cache_a;
					END IF; 
				END IF;
				lu_done <= '1';
				lu_ack <= '1';
				search_state_nxt <= hold;
			END IF; 
		END CASE;  
	END IF; 
END IF;
END PROCESS;

--------------------------------------------------------------------write

PROCESS(asclk,rsten,write_state,we,input_to_write,mask_to_write,in_action)
VARIABLE a : STD_LOGIC;
--vojood in variable va tafrighhaie emal shode bar roie address ha dar khotoot 336 ta 340 dorost neveshte shodan dar addrees marbote ast
--agar nabashand har dade be jaie inke 1 bar neveshte shavad 3 bar neveshte mishavad
--albate baraie avalin neveshtan in etefagh nemioftad baraie hamin a tarif shode ast 
BEGIN
IF (rsten = '1') THEN
	write_state <= hold;
	clear_state <= hold;
	addrs1w <= (others => '0');
	addrs2w <= (others => '0');
	addrs3w <= (others => '0');
	addrs4 <= (others => '0');
	we1 <= B"0";
	we2 <= B"0";
	we3 <= B"0";
	we4 <= B"0";
	j <= (others => '0');
	k <= (others => '0');
	w_ready <= '0';
ELSIF (asclk'event and asclk = '1') THEN
	we1 <= B"0";
	we2 <= B"0";
	we3 <= B"0";
	we4 <= B"0";
	IF (clear_en /= '1') THEN
		w_ready <= '0';
		CASE write_state is
			WHEN hold =>
				w_ready <= '1';
				we1 <= B"0";
				we2 <= B"0";
				we3 <= B"0";
				we4 <= B"0";
				IF (we /= '1') THEN
					write_state <= hold;
				ELSE
					write_state <= start;
				END IF;
			WHEN start =>
				addrs4  <=  (others => '0');
				addrs1w <=  (others => '0');
				addrs2w <=  (others => '0');
				addrs3w <=  (others => '0');
				j <= (others => '0');
				write_state <= continue;  
			WHEN continue =>
				write_state <= continue;             
			IF (j = B"10000000000") THEN
				table_is_full <= '1';
				write_state <= done;
				j <= j - B"1"; --baraie be ham narikhtan lim
			ELSE
				IF (output4 = B"0") THEN              
					table_is_full <= '0';
					in2 <= in_action;
					in1 <= input_to_write;
					in3 <= mask_to_write;
					in4 <= B"1";
					we1 <= B"1";
					we2 <= B"1";
					we3 <= B"1";
					we4 <= B"1";
					IF ( a = '1' ) THEN
						addrs5r <= addrs5r - B"10";
						addrs1w <= addrs1w - B"10";
						addrs2w <= addrs2w - B"10";
						addrs3w <= addrs3w - B"10";
						addrs4  <= addrs4  - B"10";
					END IF;
					write_state <= done;
					a := '1';                      
				ELSE
					we1 <= B"0";
					we2 <= B"0";
					we3 <= B"0";
					we4 <= B"0";          
					addrs4 <= addrs4 + B"1";
					addrs1w <= addrs1w + B"1";
					addrs2w <= addrs2w + B"1";
					addrs3w <= addrs3w + B"1";
					j <= j + B"1";
				END IF;
			END IF;     
		WHEN done =>
			limw <= addrs4;
			write_state <= hold;     
	END CASE;  
--------------------------------------------------clear
ELSE
	CASE clear_state is 
        WHEN hold =>
			w_ready <= '1';
			we1 <= B"0";
			we2 <= B"0";
			we3 <= B"0";
			we4 <= B"0"; 
			IF (clear_en = '1') THEN        
				clear_state <= start;
			ELSE
				clear_state <= hold;
			END IF;      
		WHEN start =>
			addrs5r  <=  (others => '0');
			addrs1w  <=  (others => '0');
			addrs2w  <=  (others => '0');
			addrs3w  <=  (others => '0');
			addrs4  <=  (others => '0');
			k <= (others => '0');
			clear_state <= continue;
		WHEN continue =>
			clear_state <= continue;
			IF (k > lim) THEN
				clear_state <= done;
			ELSE
				IF (output5 = input_to_clear) THEN				
					clear_state <= done;
					in1 <= (others => '0');
					in2 <= (others => '0');
					in3 <= (others => '0');
					in4 <= B"0";
					we1 <= B"1";
					we2 <= B"1";
					we3 <= B"1";
					we4 <= B"1";
					addrs5r <= addrs5r - B"10";
					addrs1w <= addrs1w - B"10";
					addrs2w <= addrs2w - B"10";
					addrs3w <= addrs3w - B"10";
					addrs4 <= addrs4 - B"10";
					clear_state <= done;
				ELSE
					we1 <= B"0";
					we2 <= B"0";
					we3 <= B"0";
					we4 <= B"0"; 
					addrs5r <= addrs5r + B"1";
					addrs1w <= addrs1w + B"1";
					addrs2w <= addrs2w + B"1";
					addrs3w <= addrs3w + B"1";
					addrs4 <= addrs4 + B"1";
					k <= k+1;
				END IF;          
			END IF;   
		WHEN done =>
			clear_state <= hold;
		END CASE;
	END IF;		
END IF;
END PROCESS;
---------memory1 = memory exact , memory2 = memory action , memory3 = memory mask , memory5 = memory clear(copy memory 1) , memory4 = por ia khali budan address
inst_memory1 : my_memory port map (
addra => addrs1w ,
addrb => addrs1r ,
clka => asclk ,
clkb => asclk ,
dina => in1,
doutb => output1,
wea => we1
);
inst_memory2 : my_memory port map (
addra => addrs2w ,
addrb => addrs2r ,
clka => asclk ,
clkb => asclk ,
dina => in2 ,
doutb => output2,
wea => we2
);
inst_memory3 : my_memory port map (
addra => addrs3w ,
addrb => addrs3r ,
clka => asclk ,
clkb => asclk ,
dina => in3,
doutb => output3,
wea => we3
);
inst_memory4 : full_memory port map(
addra => addrs4 ,
clka => asclk ,
dina => in4,
douta => output4, --agar 0 bashad iani khali 
ena => '1',
wea => we4
);
inst_memory5 : my_memory port map (
addra => addrs1w ,
addrb => addrs5r ,
clka => asclk ,
clkb => asclk ,
dina => in1,
doutb => output5,
wea => we1
);
END Behavioral;