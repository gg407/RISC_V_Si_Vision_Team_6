class data_agent_cfg extends uvm_object;

  `uvm_object_utils(agent_config)

  bit is_active = 1;  // 1 = Active, 0 = Passive
  int data_mem_size=4096;
  

  function new(string name = "agent_config");
    super.new(name);
  endfunction

endclass
