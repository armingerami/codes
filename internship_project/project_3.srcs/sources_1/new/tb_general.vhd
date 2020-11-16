LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY tb_general IS
GENERIC (
 OPENFLOW_MATCH_SIZE: INTEGER :=256;
 OPENFLOW_MASK_SIZE: INTEGER :=256;
 OPENFLOW_ACTION_SIZE: integer := 256
);
END tb_general;

  ARCHITECTURE behavior OF tb_general IS 

  -- Component Declaration
  COMPONENT FlowTableController
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
  END COMPONENT;
signal asclk : std_logic;
signal asresetn : std_logic;
signal lu_req1 : std_logic;
signal lu_req2 : std_logic;
signal lu_req3 : std_logic;
signal lu_req4 : std_logic;
signal lu_req5 : std_logic;
signal lu_req6 : std_logic;
signal lu_entry1 : std_logic_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
signal lu_entry2 : std_logic_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
signal lu_entry3 : std_logic_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
signal lu_entry4 : std_logic_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
signal lu_entry5 : std_logic_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
signal lu_entry6 : std_logic_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
signal lu_ack1 : std_logic;
signal lu_ack2 : std_logic;
signal lu_ack3 : std_logic;
signal lu_ack4 : std_logic;
signal lu_ack5 : std_logic;
signal lu_ack6 : std_logic;
signal lu_done : STD_LOGIC;
signal action : std_logic_VECTOR(OPENFLOW_action_SIZE-1 DOWNTO 0);
signal match : std_logic_VECTOR(5 DOWNTO 0);
signal fwd_redy : STD_LOGIC;

signal policy_req_agent :  STD_LOGIC;
signal policy_input_agent :  STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
signal table_is_full_agent :  STD_LOGIC;
signal add_entry_agent :  STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE-1 DOWNTO 0);
signal mask_enable_agent :  STD_LOGIC;
signal action_agent : STD_LOGIC_VECTOR (OPENFLOW_ACTION_SIZE-1 DOWNTO 0);
signal add_entry_reply_agent :  STD_LOGIC;
signal mask_agent :  STD_LOGIC_VECTOR (openflow_mask_size-1 downto 0);
signal clear_en_agent :  STD_LOGIC;
signal input_to_clear_agent :  STD_LOGIC_VECTOR(OPENFLOW_MATCH_SIZE - 1 DOWNTO 0); 
signal w_ready_agent :  STD_LOGIC;
  
  BEGIN

  -- Component Instantiation
          inst_FlowTableController : FlowTableController PORT MAP(
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
             lu_done => lu_done,
             lu_ack1 => lu_ack1,
             lu_ack2 => lu_ack2,
             lu_ack3 => lu_ack3,
             lu_ack4 => lu_ack4,
             lu_ack5 => lu_ack5,
             lu_ack6 => lu_ack6,
             action => action,
             match => match,
             fwd_redy => fwd_redy,
             
             policy_req_agent => policy_req_agent,
             policy_input_agent => policy_input_agent,
             table_is_full_agent => table_is_full_agent,
             add_entry_agent => add_entry_agent,
             mask_enable_agent => mask_enable_agent,
             action_agent => action_agent,
             add_entry_reply_agent => add_entry_reply_agent,
             mask_agent => mask_agent,
             clear_en_agent => clear_en_agent,
             input_to_clear_agent => input_to_clear_agent,
             w_ready_agent => w_ready_agent
          );
  --  Test Bench Statements
clock_process :process
  begin
       asclk <= '0';
       wait for 5 ns;
       asclk <= '1';
       wait for 5 ns;
  end process;

tb: process
  begin      
      asresetn <= '1';
      wait for 50 ns;
      asresetn <= '0';
      mask_enable_agent <= '1';
      clear_en_agent <= '0';
      wait for 50 ns;

      lu_entry1 <= X"080006040001d0df9ae8cde10a01e8bf00000000000000000000000000000000";
      lu_req1 <= '1';
      wait for 10 ns;
      lu_req1 <= '0';
      wait for 200 ns;
      
      add_entry_reply_agent <= '1';
      add_entry_agent <= X"080006040001d0df9ae8cde10a01e8bf00000000000000000000000000000000";
      action_agent <= X"080006040001d0df9ae8cde10a01e8bf00000000000000000000000000000000";
      mask_agent <= X"0000000000000000000000000000000000000000000000000000000000000fff";
      wait for 10 ns;
      add_entry_reply_agent <= '0';
      add_entry_agent <= (others => '0');
      action_agent <= (others => '0');
      mask_agent <= (others => '0');
      wait for 200 ns;
      
      lu_entry1 <= X"080006040001d0df9ae8cde10a01e8bf00000000000000000000000000000000";
      lu_req1 <= '1';         
      wait for 10 ns;
      lu_req1 <= '0';
      wait for 200 ns;
      
      lu_entry1 <= X"080006040001d0df9ae8cde10a01e8bf00000000000000000000000000000000";
      lu_req1 <= '1';         
      wait for 10 ns;
      lu_req1 <= '0';
      wait for 200 ns;
      
      lu_entry1 <= X"080006040001d0df9ae8cde10a01e8bf00000000000000000000000000000111";
      lu_req1 <= '1';         
      wait for 10 ns;
      lu_req1 <= '0';
      wait for 200 ns;
      --
      add_entry_reply_agent <= '1';
      add_entry_agent <= X"ffffffffffffd0df9ae8cde10806000100000000000000000000000000000000";
      action_agent <= X"ffffffffffffd0df9ae8cde10806000100000000000000000000000000000000";
      mask_agent <= X"0000000000000000000000000000000000000000000000000000000000000000";
      wait for 10 ns;
      add_entry_reply_agent <= '0';
      add_entry_agent <= (others => '0');
      action_agent <= (others => '0');
      mask_agent <= (others => '0');
      wait for 200 ns;
      
--      add_entry_reply_agent <= '1';
--      add_entry_agent <= X"0000000000000a01e80100000000000000000000000000000000000000000000";
--      action_agent <= X"0000000000000a01e80100000000000000000000000000000000000000000000";
--      mask_agent <= X"0000000000000000000000000000000000000000000000000000000000000000";
--      wait for 10 ns;
--      add_entry_reply_agent <= '0';
--      add_entry_agent <= (others => '0');
--      action_agent <= (others => '0');
--      mask_agent <= (others => '0');
--      wait for 200 ns;

      lu_entry2 <= X"ffffffffffffd0df9ae8cde10806000100000000000000000000000000000000";
      lu_req2 <= '1';         
      wait for 10 ns;
      lu_req2 <= '0';
      wait for 200 ns;
      
--      lu_entry3 <= X"0000000000000a01e80100000000000000000000000000000000000000000000";
--      lu_req3 <= '1';         
--      wait for 10 ns;
--      lu_req3 <= '0';
--      wait for 200 ns;
      
--      lu_entry3 <= X"0000000000000a01e80100000000000000000000000000000000000000000000";
--      lu_req3 <= '1';         
--      wait for 10 ns;
--      lu_req3 <= '0';
--      wait for 200 ns;
      
      clear_en_agent <= '1';
      input_to_clear_agent <= X"ffffffffffffd0df9ae8cde10806000100000000000000000000000000000000";
      wait for 10 ns;
      clear_en_agent <= '0';
      input_to_clear_agent <= (others => '0');
      wait for 200 ns;
      
      lu_entry2 <= X"ffffffffffffd0df9ae8cde10806000100000000000000000000000000000000";
      lu_req2 <= '1';         
      wait for 10 ns;
      lu_req2 <= '0';
      wait for 200 ns;

      lu_entry1 <= X"080006040001d0df9ae8cde10a01e8bf00000000000000000000000000000111";
      lu_req1 <= '1';         
      wait for 10 ns;
      lu_req1 <= '0';
      wait for 20000 ns;
                                                      
     end process tb;
END;