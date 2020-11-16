library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY FlowTableController IS
GENERIC ( 
  OPENFLOW_MATCH_SIZE: INTEGER:= 256;
  OPENFLOW_MASK_SIZE: INTEGER:= 256;
  OPENFLOW_ACTION_SIZE: INTEGER:= 256
);
PORT ( 
  asclk : IN STD_LOGIC;
  asresetn: IN STD_LOGIC;
  lu_req1 : IN STD_LOGIC;
  lu_req2 : IN STD_LOGIC;
  lu_req3 : IN STD_LOGIC;
  lu_req4 : IN STD_LOGIC;
  lu_req5 : IN STD_LOGIC;
  lu_req6 : IN STD_LOGIC;
  lu_entry1 : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_entry2 : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_entry3 : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0); 
  lu_entry4 : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_entry5 : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_entry6 : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  lu_done : OUT STD_LOGIC;
  lu_ack1 : OUT STD_LOGIC;
  lu_ack2 : OUT STD_LOGIC;
  lu_ack3 : OUT STD_LOGIC;
  lu_ack4 : OUT STD_LOGIC;
  lu_ack5 : OUT STD_LOGIC;
  lu_ack6 : OUT STD_LOGIC;
  action: OUT STD_LOGIC_VECTOR(OPENFLOW_ACTION_SIZE-1 DOWNTO 0);
  match : OUT STD_LOGIC_VECTOR (5 downto 0);
  fwd_redy : in STD_LOGIC;
  
  policy_req_agent : out STD_LOGIC;
  policy_input_agent : out STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  table_is_full_agent : out STD_LOGIC;
  add_entry_agent : in STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  mask_enable_agent : in STD_LOGIC;
  action_agent :in STD_LOGIC_VECTOR (OPENFLOW_ACTION_SIZE-1 DOWNTO 0);
  add_entry_reply_agent : in STD_LOGIC;
  mask_agent : in STD_LOGIC_VECTOR (openflow_mask_size-1 downto 0);
  clear_en_agent : in STD_LOGIC;
  input_to_clear_agent : in STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0);
  w_ready_agent : out STD_LOGIC
   );
END FlowTableController;
ARCHITECTURE FlowTableController of FlowTableController IS
  SIGNAL add_entry_int, no_match_entry_int:std_logic_vector(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  SIGNAL add_mask_int: std_logic;
  SIGNAL policy_req_int, add_entry_reply_int, add_entry_done_int :std_logic;
  SIGNAL action_in_int :std_logic_vector(OPENFLOW_ACTION_SIZE-1 DOWNTO 0);
  signal mask_int : STD_LOGIC_VECTOR (openflow_mask_size-1 downto 0);
  signal policy_input_int : std_logic_vector(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  signal table_is_full : STD_LOGIC;
  signal clear_en :  STD_LOGIC; --clear
  signal input_to_clear :  STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0); --clear
  signal w_ready : STD_LOGIC;
----------------------------------------------- Flow Table Lookup -----------------------------------------------
COMPONENT FlowTableLookup
PORT(
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
END COMPONENT;
----------------------------------------------- Controller Policy -----------------------------------------------
COMPONENT ControllerPolicy
PORT(
   asclk 								: IN STD_LOGIC;
 asresetn                                 : IN STD_LOGIC;
 policy_req                             : IN STD_LOGIC; --az samte actionLUT vared mishavad va agar 1 bashad iani be ezaie 1 voroodi match nadarad
 policy_input                             : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0); --az samte actionLUT vared mishavad va voroodi E ast ke match nadarad
 table_is_full                         : IN STD_LOGIC; --az samte actionLUT vared mishavad va agar 1 bashad iani digar baraie neveshtan ja nadarim
 
 input_to_write                         : OUT STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0); --be actionLUT ersal mishavad va voroodi jadid baraie neveshte shodan ast
 action_to_write                        : OUT STD_LOGIC_VECTOR (OPENFLOW_ACTION_SIZE-1 DOWNTO 0); --be actionLUT ersal mishavad va action jadid baraie neveshte shodan ast
 mask_to_write                         : OUT STD_LOGIC_VECTOR (OPENFLOW_MASK_SIZE-1 downto 0); --be actionLUT ersal mishavad va mask jadid baraie neveshte shodan ast  
 mask_enable                            : OUT STD_LOGIC;--be actionLUT ersal mishavad va agar 1 bashad iani mask baiad emal shavad
 write_enable                             : OUT STD_LOGIC; --be actionLUT ersal mishavad va agar 1 bashad iani baiad amaliat neveshtan shoroo shavad

 clear_en                                 : OUT STD_LOGIC; --agar 1 bashad iani amaliat pak kardan baiad shoroo shavad
 input_to_clear                         : OUT STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0); --be actionLUT ersal mishavad va voroodi baraie pak shodan ast

 policy_req_to_agent                     : OUT STD_LOGIC; --be agent(python) ersal mishavad va haman policy_req dariafti az actionLUT ast
 policy_input_to_agent                 : OUT STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0); --be agent(python) ersal mishavad va haman policy_input dariafti az actionLUT ast
 table_is_full_to_agent                 : OUT STD_LOGIC;
 
 --signal haie zir marbot be neveshtan hastand ke az agent(pythoyn) dariaft mishavand va be actionLUT ferestade mishavand
 input_to_write_from_agent             : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
 action_to_write_from_agent             : IN STD_LOGIC_VECTOR (OPENFLOW_ACTION_SIZE-1 DOWNTO 0);
 mask_to_write_from_agent                 : IN STD_LOGIC_VECTOR (OPENFLOW_MASK_SIZE-1 downto 0);  
 mask_enable_from_agent                 : IN STD_LOGIC;  
 write_enable_from_agent                 : IN STD_LOGIC;

 clear_en_agent                         : IN STD_LOGIC;
 input_to_clear_agent                     : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0);
 
 w_ready                                 : IN STD_LOGIC; --az actionLUT dariaft mishavad ta bedanad amade neveshtan ast ia kheir
 w_ready_agent                         : OUT STD_LOGIC --haman w_ready  ast ke be agent(python) ersal mishavad
);
END COMPONENT;
BEGIN
  Inst_FlowTableLookup: FlowTableLookup PORT MAP(
  asclk => asclk,
  asresetn => asresetn,
  lu_req1 => lu_req1,
  lu_req2 => lu_req2,
  lu_req3 => lu_req3,
  lu_req4 => lu_req4,
  lu_req5 => lu_req5,
  lu_req6 => lu_req6,
  lu_entry1 => lu_entry1,
  lu_entry2 => lu_entry2,
  lu_entry3 => lu_entry3,
  lu_entry4 => lu_entry4,
  lu_entry5 => lu_entry5,
  lu_entry6 => lu_entry6,
  input_to_write => add_entry_int,
  mask_to_write => mask_int,
  write_enable => add_entry_reply_int,
  mask_enable => add_mask_int,
  lu_done => lu_done,
  lu_ack1 => lu_ack1,
  lu_ack2 => lu_ack2,
  lu_ack3 => lu_ack3,
  lu_ack4 => lu_ack4,
  lu_ack5 => lu_ack5,
  lu_ack6 => lu_ack6,
  policy_req => policy_req_int,
  output_to_policy => policy_input_int,
  action_to_write => action_in_int,
  action_out=> action,
  table_is_full => table_is_full,
  match => match,
  clear_en => clear_en,--clear
  input_to_clear => input_to_clear,--clear
  fwd_redy => fwd_redy,
  w_ready => w_ready
);
Inst_ControllerPolicy: ControllerPolicy PORT MAP(
  asclk => asclk,
  asresetn => asresetn,
  policy_req => policy_req_int,
  policy_input => policy_input_int,
  table_is_full => table_is_full,
  input_to_write => add_entry_int,
  mask_enable => add_mask_int,
  action_to_write => action_in_int,
  write_enable => add_entry_reply_int,
  mask_to_write => mask_int,
  clear_en => clear_en,--clear
  input_to_clear => input_to_clear,--clear
  policy_req_to_agent => policy_req_agent,
  policy_input_to_agent => policy_input_agent,
  table_is_full_to_agent => table_is_full_agent,
  input_to_write_from_agent => add_entry_agent,
  mask_enable_from_agent => mask_enable_agent,
  action_to_write_from_agent => action_agent,
  write_enable_from_agent => add_entry_reply_agent,
  mask_to_write_from_agent => mask_agent,
  clear_en_agent => clear_en_agent,
  input_to_clear_agent => input_to_clear_agent,
  w_ready => w_ready,
  w_ready_agent => w_ready_agent
);
END FlowTableController;
