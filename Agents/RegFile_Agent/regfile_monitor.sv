class reg_file_monitor_in extends uvm_monitor;
	`uvm_component_utils(reg_file_monitor_in)
	virtual reg_file_if mon_in_if;
	reg_file_sequence_item tr;
  
	uvm_analysis_port #(reg_file_sequence_item) mon_in_port;
  
	function new(string name = "reg_file_monitor_in", uvm_component parent);
		super.new(name, parent);
	endfunction
 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
    
		mon_in_port = new("mon_in_port", this);
    
		if(!(uvm_config_db #(virtual reg_file_if)::get(this, "", "vif", mon_in_if))) begin
			`uvm_fatal("MONITOR_IN_CLASS", "Failed to get  mon_in_if from config DB!")
		end
	endfunction: build_phase
  
	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		forever begin
			@(posedge mon_in_if.clk iff mon_in_if.rst_n) ;
			tr = reg_file_sequence_item::type_id::create("tr");
			tr.raddr_a_i = mon_in_if.raddr_a_i;
			tr.raddr_b_i = mon_in_if.raddr_b_i;
			//tr.raddr_c_i = mon_in_if.raddr_c_i;
			if (mon_in_if.we_a_i) begin
				tr.waddr_a_i = mon_in_if.waddr_a_i;
				tr.wdata_a_i = mon_in_if.wdata_a_i;
			end 
			if (mon_in_if.we_b_i) begin	
				tr.waddr_b_i = mon_in_if.waddr_b_i;
				tr.wdata_b_i = mon_in_if.wdata_b_i;
			end 
			//send the transaction to scoreboard and coverage collector
			mon_in_port.write(tr);
		end 
        
	endtask: run_phase
  
  
endclass: reg_file_monitor_in

///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

class reg_file_monitor_out extends uvm_monitor;
	`uvm_component_utils(reg_file_monitor_out)
	virtual reg_file_if mon_out_if;
	reg_file_sequence_item tr;
  
	uvm_analysis_port #(reg_file_sequence_item) mon_out_port;
  
	function new(string name = "reg_file_monitor_out", uvm_component parent);
		super.new(name, parent);
	endfunction
 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
    
		mon_in_port = new("mon_out_port", this);
    
		if(!(uvm_config_db #(virtual reg_file_if)::get(this, "", "vif", mon_out_if))) begin
			`uvm_fatal("MONITOR_IN_CLASS", "Failed to get  mon_out_if from config DB!")
		end
	endfunction: build_phase
  
 
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction: connect_phase
  
	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		forever begin
			@(posedge mon_out_if.clk iff mon_out_if.rst_n) ;
			tr = reg_file_sequence_item::type_id::create("tr");
			tr.rdata_a_o = mon_in_if.rdata_a_o;
			tr.rdata_b_o = mon_in_if.rdata_b_o,;
			//tr.rdata_c_o, = mon_in_if.rdata_c_o,;
			mon_in_port.write(tr);
		end 
        
	endtask: run_phase
  
  
endclass: reg_file_monitor_out