class data_mon extends uvm_monitor;
  
  `uvm_component_utils(data_mon)
  
  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual data_if vif;
  
  //---------------------------------------
  // analysis port, to send the transaction to subscribers
  //---------------------------------------
  uvm_analysis_port #(data_seq_item) data_mon_port;
  
  //---------------------------------------
  //sequence_item class
  //---------------------------------------
 	//data_seq_item  data_item;
  	data_seq_item  data_item_queue[$];
  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name = "data_mon", uvm_component parent);
    super.new(name, parent); 
  endfunction
  
  //--------------------------------------- 
  // build phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual data_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    data_mon_port = new("data_mon_port",this);
  endfunction
  //---------------------------------------
  // run phase
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
       data_seq_item data_item = data_seq_item::type_id::create("data_item");
      @(posedge vif.clk_i);
      
      if (vif.req) begin
        data_item.we = vif.we;
        data_item.be = vif.be;
        data_item.addr = vif.addr;
        data_item.wdata = vif.wdata;
        data_item_queue.push_back(data_item);
      end
      
      if (vif.rvalid) begin 
         data_item = data_item_queue.pop_front();
        if (!data_item.we)
          data_item.rdata = vif.rdata;
      `uvm_info("Data Monitor: ", {"Collect new data item: ", data_item.convert2string()}, UVM_HIGH)   
       data_mon_port.write(data_item);     
      end 
       
    end 
  endtask
 
endclass
