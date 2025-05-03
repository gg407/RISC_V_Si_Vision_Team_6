class instruction_monitor extends uvm_monitor;
  `uvm_component_utils(instruction_monitor)

  virtual ins_if vif;  // Connect this via uvm_config_db
  uvm_analysis_port #(ins_seq_item) mon_ap;

   ins_seq_item txn;
  function new(string name, uvm_component parent);
    super.new(name, parent);
    txn = ins_seq_item::type_id::create("txn");
    mon_ap = new("mon_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ins_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for instruction_monitor");
  endfunction

  task run_phase(uvm_phase phase);
   

    forever begin
      @(posedge vif.clk);

      if (vif.instr_req_o && vif.instr_gnt_i) begin
        txn = ins_seq_item::type_id::create("txn");
        txn.instr_addr_o   = vif.instr_addr_o;
        txn.instr_req_o   = vif.instr_req_o;
        txn.instr_gnt_i   = vif.instr_gnt_i;
        // Wait for rvalid to know when data is ready
        do @(posedge vif.clk); while (!vif.instr_rvalid_i);

        txn.instr_rdata_i  = vif.instr_rdata_i;
        txn.instr_rvalid_i  = vif.instr_rvalid_i;
        `uvm_info("INS_MON", $sformatf("Captured addr=0x%08x data=0x%08x", txn.instr_addr_o, txn.instr_rdata_i), UVM_LOW)

        mon_ap.write(txn);  // Send to scoreboard or coverage collector
      end
    end
  endtask
endclass
