class ALU_agent extends uvm_agent;
  
  `uvm_component_utils(ALU_agent)
    monitor_mult mult_mon;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction: new
  
      //////////////   BUILD PHASE   //////////////////////////////
    function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      
      mult_mon=monitor_mult::type_id::create("mult_mon",this);

    endfunction:build_phase

  
endclass : ALU_agent