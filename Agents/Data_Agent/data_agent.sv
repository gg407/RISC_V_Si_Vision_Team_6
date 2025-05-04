class data_agent extends uvm_agent;
  //---------------------------------------
  // factory registeration 
  //---------------------------------------
  `uvm_component_utils(data_agent)
   
  //---------------------------------------
  // analysis port, to send the transaction to subscribers
  //---------------------------------------
  uvm_analysis_port #(data_seq_item) agnt_data_mon_port;
  //---------------------------------------
  // component instances
  //---------------------------------------
  data_driver drv;
  data_seqr seqr;
  data_mon mon;
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agnt_data_mon_port = new("agnt_data_mon_port",this);
    
    
    mon = data_mon::type_id::create("mon", this);
    

    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      drv    = data_driver::type_id::create("drv", this);
      seqr = data_seqr::type_id::create("seqr", this);
    end
  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    mon.data_mon_port.connect(agnt_data_mon_port);
   
    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export); 
    end
  endfunction : connect_phase

endclass 
