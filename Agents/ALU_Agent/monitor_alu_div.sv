class monitor_alu_div extends uvm_monitor;

  `uvm_component_utils(monitor_alu_div)
  
  virtual alu_div_if vif;
  uvm_analysis_port#(alu_div_seq_item) item_collected_port;
  alu_div_seq_item seq_collected;

//---------------------------------------
//Constructor
//---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
    item_collected_port = new("item_collected_port",this);
    seq_collected = new();
  endfunction: new

//////////////   BUILD PHASE   //////////////////////////////
    function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_div_if)::get(this,"", "vif",vif))
      `uvm_fatal("No vif found", {"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

//////////////   RUN PHASE   //////////////////////////////
    virtual task run_phase(uvm_phase phase);
      alu_div_seq_item item_collected;
      forever begin
        @(posedge vif.clk iff (vif.ex_ready_i && vif.enable_i));
        seq_collected.operator_i          = vif.operator_i;
        seq_collected.operand_a_i         = vif.operand_a_i;
        seq_collected.operand_b_i         = vif.operand_b_i;
    
        @(posedge vif.clk iff vif.ready_o);
        seq_collected.result_o                  =  vif.result_o;
        seq_collected.comparison_result_o       =  vif.comparison_result_o; 

        
        $cast(item_collected, seq_collected.clone());
        item_collected_port.write(item_collected);
       
       end
  endtask: run_phase

endclass : monitor_alu_div

