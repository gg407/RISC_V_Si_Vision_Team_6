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
      @(posedge vif.clk);
      
      if (vif.data_req_o && vif.data_gnt_i) begin
        data_item.data_we_o = vif.data_we_o;
        data_item.data_be_o = vif.data_be_o;
        data_item.data_addr_o = vif.data_addr_o;
        data_item.data_wdata_o = vif.data_wdata_o;
        data_item_queue.push_back(data_item);
      end
      
      if (vif.data_rvalid_i) begin 
         data_item = data_item_queue.pop_front();
        if (!data_item.data_we_o)
          data_item.data_rdata_i = vif.data_rdata_i;
      `uvm_info("Data Monitor: ", {"Collect new data item: ", data_item.convert2string()}, UVM_HIGH)   
       data_mon_port.write(data_item);     
      end 
       
    end 
  endtask
 
endclass
