library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

ENTITY ControllerPolicy IS
GENERIC ( OPENFLOW_MATCH_SIZE:  integer:= 256;
		  OPENFLOW_MASK_SIZE:   integer:= 256;
          OPENFLOW_ACTION_SIZE: integer:= 256
);
Port (
  asclk 								: IN STD_LOGIC;
  asresetn 								: IN STD_LOGIC;
  policy_req 							: IN STD_LOGIC; --az samte actionLUT vared mishavad va agar 1 bashad iani be ezaie 1 voroodi match nadarad
  policy_input 							: IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0); --az samte actionLUT vared mishavad va voroodi E ast ke match nadarad
  table_is_full 						: IN STD_LOGIC; --az samte actionLUT vared mishavad va agar 1 bashad iani digar baraie neveshtan ja nadarim
  
  input_to_write 					    : OUT STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0); --be actionLUT ersal mishavad va voroodi jadid baraie neveshte shodan ast
  action_to_write						: OUT STD_LOGIC_VECTOR (OPENFLOW_ACTION_SIZE-1 DOWNTO 0); --be actionLUT ersal mishavad va action jadid baraie neveshte shodan ast
  mask_to_write 						: OUT STD_LOGIC_VECTOR (OPENFLOW_MASK_SIZE-1 downto 0); --be actionLUT ersal mishavad va mask jadid baraie neveshte shodan ast  
  mask_enable							: OUT STD_LOGIC;--be actionLUT ersal mishavad va agar 1 bashad iani mask baiad emal shavad
  write_enable 							: OUT STD_LOGIC; --be actionLUT ersal mishavad va agar 1 bashad iani baiad amaliat neveshtan shoroo shavad

  clear_en 								: OUT STD_LOGIC; --agar 1 bashad iani amaliat pak kardan baiad shoroo shavad
  input_to_clear 						: OUT STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0); --be actionLUT ersal mishavad va voroodi baraie pak shodan ast

  policy_req_to_agent 					: OUT STD_LOGIC; --be agent(python) ersal mishavad va haman policy_req dariafti az actionLUT ast
  policy_input_to_agent 				: OUT STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0); --be agent(python) ersal mishavad va haman policy_input dariafti az actionLUT ast
  table_is_full_to_agent 				: OUT STD_LOGIC;
  
  --signal haie zir marbot be neveshtan hastand ke az agent(pythoyn) dariaft mishavand va be actionLUT ferestade mishavand
  input_to_write_from_agent 			: IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
  action_to_write_from_agent 			: IN STD_LOGIC_VECTOR (OPENFLOW_ACTION_SIZE-1 DOWNTO 0);
  mask_to_write_from_agent 				: IN STD_LOGIC_VECTOR (OPENFLOW_MASK_SIZE-1 downto 0);  
  mask_enable_from_agent 				: IN STD_LOGIC;  
  write_enable_from_agent 				: IN STD_LOGIC;
 
  clear_en_agent 						: IN STD_LOGIC;
  input_to_clear_agent 				    : IN STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0);
  
  w_ready 								: IN STD_LOGIC; --az actionLUT dariaft mishavad ta bedanad amade neveshtan ast ia kheir
  w_ready_agent 						: OUT STD_LOGIC --haman w_ready  ast ke be agent(python) ersal mishavad
);
END ControllerPolicy;
ARCHITECTURE ControllerPolicy of ControllerPolicy IS
BEGIN
PROCESS (asclk,asresetn)
BEGIN
IF ( asresetn = '1') THEN

ELSE
    policy_req_to_agent <= policy_req;
    policy_input_to_agent <= policy_input;
    table_is_full_to_agent <= table_is_full;
    mask_enable <= mask_enable_from_agent;
    w_ready_agent <= w_ready;
    IF((write_enable_from_agent = '1') and (w_ready = '1')) THEN   
		write_enable <= write_enable_from_agent;
		input_to_write <= input_to_write_from_agent;
		action_to_write <= action_to_write_from_agent;
		mask_to_write <= mask_to_write_from_agent;
    ELSIF((clear_en_agent = '1') and (w_ready = '1')) THEN
		clear_en <= clear_en_agent;
		input_to_clear <= input_to_clear_agent;
    ELSE 
		write_enable <= '0';
    END IF;
END IF;
END PROCESS;    
END ControllerPolicy;