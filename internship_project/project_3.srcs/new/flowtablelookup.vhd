library IEEE; use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

ENTITY FlowTableLookup IS
GENERIC ( 
  OPENFLOW_MATCH_SIZE  : INTEGER:= 256;
  OPENFLOW_MASK_SIZE   : INTEGER:= 256;
  OPENFLOW_ACTION_SIZE : INTEGER:= 256
);
PORT (
  asclk 				: IN STD_LOGIC;
  asresetn 				: IN STD_LOGIC;
  lu_req1 				: IN STD_LOGIC;
  lu_req2 				: IN STD_LOGIC;
  lu_req3 				: IN STD_LOGIC;
  lu_req4 				: IN STD_LOGIC;
  lu_req5 				: IN STD_LOGIC;
  lu_req6 				: IN STD_LOGIC;
  lu_entry1 			: IN STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_entry2 			: IN STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_entry3 			: IN STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_entry4				: IN STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_entry5				: IN STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_entry6				: IN STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  input_to_write 		: IN STD_LOGIC_vector(OPENFLOW_MATCH_SIZE-1 downto 0);
  mask_to_write 		: IN STD_LOGIC_VECTOR (OPENFLOW_MASK_SIZE-1 DOWNTO 0);
  mask_enable 			: IN STD_LOGIC;
  write_enable 			: IN STD_LOGIC;
  lu_done 				: OUT STD_LOGIC;
  lu_ack1 				: OUT STD_LOGIC;
  lu_ack2 				: OUT STD_LOGIC;
  lu_ack3 				: OUT STD_LOGIC;
  lu_ack4 				: OUT STD_LOGIC;
  lu_ack5 				: OUT STD_LOGIC;
  lu_ack6 				: OUT STD_LOGIC;
  policy_req 			: OUT STD_LOGIC;
  output_to_policy 		: OUT STD_LOGIC_vector(OPENFLOW_MATCH_SIZE-1 downto 0); --vorodi E ke match baraie on peida nashode be policy ferestade mishavad
  action_to_write		: IN STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE-1 DOWNTO 0);
  action_out			: OUT STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE-1 DOWNTO 0);
  table_is_full 		: OUT STD_LOGIC;
  match 				: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
  clear_en 				: IN STD_LOGIC; --clear
  input_to_clear 		: IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0);
  fwd_redy 				: IN STD_LOGIC;
  w_ready 				: OUT STD_LOGIC
);
END FlowTableLookup;
ARCHITECTURE FlowTableLookup of FlowTableLookup is
--LUT
component action_lut
port(
     asclk 				: IN STD_LOGIC;
     rsten 				: IN STD_LOGIC;
     flow_entry_req 	: IN STD_LOGIC;
     input_to_check 	: IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE- 1 DOWNTO 0);
     input_to_write 	: IN STD_LOGIC_VECTOR (OPENFLOW_MATCH_SIZE- 1 DOWNTO 0);
	 mask_enable 		: IN STD_LOGIC;
	 mask_to_write 				: IN STD_LOGIC_VECTOR(OPENFLOW_MASK_SIZE-1 DOWNTO 0);
	 we 				: IN STD_LOGIC;
	 check_match 		: OUT STD_LOGIC;
	 in_action 			: IN STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE - 1 DOWNTO 0);
	 out_action 		: OUT STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE- 1 DOWNTO 0);
	 table_is_full 		: OUT STD_LOGIC;
     lu_done 			: OUT STD_LOGIC;
     lu_ack 			: OUT STD_LOGIC;
     req_num 			: IN STD_LOGIC_VECTOR(5 downto 0);
     clear_en 			: IN STD_LOGIC; --clear
     input_to_clear 	: IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0);
     fwd_redy 			: IN STD_LOGIC;
     w_ready 			: OUT STD_LOGIC
	 );
END component;	      
  SIGNAL lu_entry							: STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  SIGNAL out_action							: STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE-1 DOWNTO 0);
  SIGNAL flow_entry_req, controller_req		: STD_LOGIC;
  SIGNAL req_num							: STD_LOGIC_VECTOR(5 DOWNTO 0);
  signal match_is_true 						: STD_LOGIC;
  signal lu_ack 							: STD_LOGIC;
  signal lu_done_nxt 						: STD_LOGIC;
BEGIN
----------------------------------------------- Request Selection (Round Robin) -----------------------------------------------
PROCESS(asclk,asresetn, lu_req1, lu_req2, lu_req3, lu_req4, lu_req5, lu_req6)
variable i : std_logic_vector(3 downto 0);
BEGIN
  IF (asresetn = '1' ) THEN
      lu_entry <= (others =>'0');
      req_num <= (others =>'0');
      i := B"0000";    
  ELSIF (asclk'event and asclk = '1') THEN
          IF (lu_req1 = '1') THEN
              i := B"0000";
              flow_entry_req <= '1';
              lu_entry <= lu_entry1;
              req_num <= B"000001";
          ELSIF (lu_req2 = '1') THEN
              i := B"0000";
              flow_entry_req <= '1';
              lu_entry <= lu_entry2;
              req_num <= B"000010";
          ELSIF (lu_req3 = '1') THEN
              i := B"0000";
              flow_entry_req <= '1';
              lu_entry <= lu_entry3;
              req_num <= B"000100";
          ELSIF (lu_req4 = '1') THEN
              i := B"0000";
              flow_entry_req <= '1';
              lu_entry <= lu_entry4;
              req_num <= B"001000";
              
          ELSIF (lu_req5 = '1') THEN
              flow_entry_req <= '1';
              lu_entry <= lu_entry5;
              req_num <= B"010000";
              
          ELSIF (lu_req6 = '1') THEN
              flow_entry_req <= '1';
              lu_entry <= lu_entry6;
              req_num <= B"100000";
              
          ELSE
              lu_done <= lu_done_nxt;
              IF (i < 1) THEN
                i := i + B"1";
              ELSE                
                 flow_entry_req <= '0';
              END IF;
          END IF;
END IF;  
END PROCESS;
----------------------------------------------- Write Flow Entry Process -----------------------------------------------
PROCESS (asclk,asresetn,controller_req,flow_entry_req,write_enable,req_num)
BEGIN
-- khorooji hamishe meghdar darad ama inke khande shavad ia na tavasot signal lu_done ersali be forwarder moshakhas mishavad

IF (asresetn = '1' ) THEN
      match <= B"000000";
      action_out <= (others => '0');
      policy_req <='0';
ELSIF (asclk'event and asclk = '1') THEN
    IF (req_num = B"000001") THEN
        lu_ack1 <= lu_ack;
        lu_ack2 <= '0';
        lu_ack3 <= '0';
        lu_ack4 <= '0';
        lu_ack5 <= '0';
        lu_ack6 <= '0';
    ELSIF (req_num = B"000010") THEN
        lu_ack1 <= '0';
        lu_ack2 <= lu_ack;
        lu_ack3 <= '0';
        lu_ack4 <= '0';
        lu_ack5 <= '0';
        lu_ack6 <= '0';
    ELSIF (req_num = B"000100") THEN
        lu_ack1 <= '0';
        lu_ack2 <= '0';
        lu_ack3 <= lu_ack;
        lu_ack4 <= '0';
        lu_ack5 <= '0';
        lu_ack6 <= '0';
    ELSIF (req_num = B"001000") THEN
        lu_ack1 <= '0';
        lu_ack2 <= '0';
        lu_ack3 <= '0';
        lu_ack4 <= lu_ack;
        lu_ack5 <= '0';
        lu_ack6 <= '0';
    ELSIF (req_num = B"010000") THEN
        lu_ack1 <= '0';
        lu_ack2 <= '0';
        lu_ack3 <= '0';
        lu_ack4 <= '0';
        lu_ack5 <= lu_ack;
        lu_ack6 <= '0';
    ELSIF (req_num = B"100000") THEN
        lu_ack1 <= '0';
        lu_ack2 <= '0';
        lu_ack3 <= '0';
        lu_ack4 <= '0';
        lu_ack5 <= '0';
        lu_ack6 <= lu_ack;
    END IF;
    --lu_done <= lu_done_nxt;
    IF (match_is_true = '1') THEN
         action_out <= out_action;
         match <= req_num;        
         policy_req <='0';
    ELSIF (match_is_true = '0') THEN
        match <= B"000000";
        policy_req <= '1';
        output_to_policy <= lu_entry;
        action_out <= (others => '0');
    END IF;

END IF;
END PROCESS;
  Inst_action_lut : action_lut port map(
  asclk => asclk,
  rsten => asresetn,
  flow_entry_req => flow_entry_req,
  input_to_check => lu_entry,
  input_to_write => input_to_write,
  mask_enable => mask_enable,
  mask_to_write => mask_to_write,
  we => write_enable,
  check_match => match_is_true,
  in_action => action_to_write,
  out_action => out_action,
  table_is_full => table_is_full,
  lu_done => lu_done_nxt,
  lu_ack => lu_ack,
  req_num => req_num,
  clear_en => clear_en,
  input_to_clear => input_to_clear,
  fwd_redy => fwd_redy,
  w_ready => w_ready
     );
END FlowTableLookup;
