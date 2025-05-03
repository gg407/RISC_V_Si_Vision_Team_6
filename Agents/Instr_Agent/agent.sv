class instruction_agent extends uvm_agent;
  `uvm_component_utils(instruction_agent)
  // Declaring agent components
  instruction_driver    driver;
  instruction_monitor   monitor;
  instruction_sequencer sequencer;

  agent_config  cfg;  // Config object
  // Analysis ports to forward transactions from monitors
  uvm_analysis_port #(ins_seq_item) agent_item_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    // Creating analysis ports
    agent_item_port = new("agent_item_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

   // Retrieve Configuration
    if (!uvm_config_db#(agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("CONFIG", "Agent configuration not set!")
    if (cfg.is_active) begin
    driver    = instruction_driver::type_id::create("driver", this);  
    sequencer = instruction_sequencer::type_id::create("sequencer", this);
    end
    monitor   = instruction_monitor::type_id::create("monitor", this);
  endfunction : build_phase


  function void connect_phase(uvm_phase phase);
    if (cfg.is_active) begin
    driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    monitor.mon_ap.connect(agent_item_port);
  endfunction : connect_phase

endclass

