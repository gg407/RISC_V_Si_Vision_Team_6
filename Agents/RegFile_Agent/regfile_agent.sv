class reg_file_agent extends uvm_agent;
	
	`uvm_component_utils(reg_file_agent)
  
	reg_file_monitor_in mon_in;
	reg_file_monitor_in mon_out;
  
	function new(string name = "reg_file_agent", uvm_component parent);
		super.new(name, parent);
	endfunction: new
  

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mon_in = reg_file_monitor_in::type_id::create("mon_in", this);
		mon_out = reg_file_monitor_out::type_id::create("mon_out", this);
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction: connect_phase
  
  
	task run_phase (uvm_phase phase);
		super.run_phase(phase); 
	endtask: run_phase
  
endclass: reg_file_agent