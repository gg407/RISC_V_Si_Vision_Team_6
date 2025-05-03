class riscv_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(riscv_scoreboard)

  // Virtual interface to DUT
  virtual riscv_if vif;

  // Transaction type from monitor or sequence
  typedef struct packed {
    bit [31:0] instr;
    logic [4:0] rs1, rs2, rd;
    logic [31:0] alu_result;
    logic [31:0] load_data;
    logic wr_en;
    logic valid;
  } instr_info_t

regfile[32];
  // Pipeline stages
    //fetch stage
    logic [31:0] instr,pc; logic f_valid;
    // decode stage
    logic [4:0] rs1, rs2, rd; logic [31:0] rs1_data, rs2_data,pc; logic [31:0] imm;  logic D_valid;
    // execute stage alu stage
    logic [31:0] alu_result;[6:0] opcode;[4:0] funct5;logic [2:0] funct3;logic [6:0] funct7; logic E_valid;
    // memory stage load/store stage
    logic [31:0] load_data;logic [31:0] store_data;logic [31:0] store_addr;logic [31:0] load_addr;  
    // writeback stage register file stage
    logic [31:0] rf_write_data;logic [4:0] rf_write_addr;logic rf_write_en;logic [31:0] wb_data;logic [4:0] wb_addr;logic wb_en; logic W_valid;


    reg_file[rd2]=rd2_data;
    reg_file[rd1]=rd1_data;

            Fetch Decode Execute/Memory Writeback
                 1      2              3

          


    // pipeline stage info
  //instr_info_t if_stage, id_stage, ex_stage ;

  // Instruction queue for IF stage (to handle bursty traffic)
  riscv_instr_txn instr_q[$];  // Queue to hold instructions

  // Input from monitor
  uvm_analysis_imp#(riscv_instr_txn, riscv_scoreboard) instr_ap; //fetch
  data_ap //excute
  alu_ap //excute
  mul_ap //excute
  reg_file_ap //decode and writeback

task reg_file_assign();
    reg_file[reg_item.reg_addr1] = reg_item.reg_data1;
    reg_file[reg_item.reg_addr2] = reg_item.reg_data2;
    reg_file[reg_item.reg_addr3] = reg_item.reg_data3;
    if (reg_item.reg_write) begin
        reg_file[reg_item.reg_addr] = reg_item.reg_data;
    end
    if (reg_item.reg_write) begin
        reg_file[reg_item.reg_addr] = reg_item.reg_data;
    end
endtask

  // alu_div agent
  // env 
  // test
  // 



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    instr_ap = new("instr_ap", this);
    if (!uvm_config_db#(virtual riscv_if)::get(this, "", "vif", vif))
      `uvm_fatal("SB", "Can't get vif from config DB")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      advance_pipeline();
      compare_with_dut();
    end
  endtask

  // Handle incoming instruction
  function void write(riscv_instr_txn t);
    // Push incoming instruction into the queue
    instr_q.push_back(t);
  endfunction


    // Advance pipeline stages
    function void advance_pipeline();
        bit stall = 0;

        // Detect load-use hazard: EX loads, and ID depends on the load (rs1/rs2)
        if ((ex_stage.valid) &&
            (ex_stage.instr[6:0] == 7'b0000011) && // LW opcode
            (ex_stage.rd != 0) &&                   // Not a store (rd != 0)
            id_stage.valid &&
            ((id_stage.rs1 == ex_stage.rd) || (id_stage.rs2 == ex_stage.rd))) begin
            stall = 1;
            `uvm_info("SB", "Stall inserted due to load-use hazard", UVM_MEDIUM)
        end
        
        if (stall) begin
            ex_stage = '{default:0}; // Bubble
            ex_stage.valid = 0;
            // ID and IF frozen
        end else begin
            ex_stage = id_stage;
            ex_stage.valid = id_stage.valid;

            id_stage = if_stage;
            id_stage.valid = if_stage.valid;

            if_stage = '{default:0}; // Ready for next instruction
        end

        // Handle instruction fetch (IF) stage, checking if it can take a new instruction
        if (!if_stage.valid && instr_q.size() > 0) begin
            riscv_instr_txn t = instr_q.pop_front();  // Pop instruction from the queue
            if_stage.instr = t.instr;
            if_stage.rs1   = t.rs1;
            if_stage.rs2   = t.rs2;
            if_stage.rd    = t.rd;
            if_stage.wr_en = t.wr_en;
            if_stage.valid = 1;
        end

        // Forwarding logic for EX stage (handling if we have data forwarding)
        if (ex_stage.valid) begin
            // Forward data from EX to ID stage (if rs1 or rs2 matches EX rd)
            if (id_stage.valid && (id_stage.rs1 == ex_stage.rd)) begin
            id_stage.alu_result = ex_stage.alu_result;
            end
            if (id_stage.valid && (id_stage.rs2 == ex_stage.rd)) begin
            id_stage.alu_result = ex_stage.alu_result;
            end

            // Forwarding from EX to IF (just in case there’s a dependency)
            if (if_stage.valid && (if_stage.rs1 == ex_stage.rd)) begin
            if_stage.alu_result = ex_stage.alu_result;
            end
            if (if_stage.valid && (if_stage.rs2 == ex_stage.rd)) begin
            if_stage.alu_result = ex_stage.alu_result;
            end
        end
    endfunction

  // Compare expected values with DUT
  function void compare_with_dut();
    if (ex_stage.valid) begin
      logic [31:0] dut_alu = vif.ex_alu_result;

      if (ex_stage.alu_result !== dut_alu) begin
        `uvm_error("SB", $sformatf("ALU mismatch: expected %h, got %h",
                                   ex_stage.alu_result, dut_alu))
      end
    end

    if (wb_stage.valid && wb_stage.wr_en && wb_stage.rd != 0) begin
      logic [31:0] dut_rf_write = vif.rf_write_data;

      if (wb_stage.load_data !== dut_rf_write) begin
        `uvm_error("SB", $sformatf("Writeback mismatch: rd=%0d, expected=%h, got=%h",
                                   wb_stage.rd, wb_stage.load_data, dut_rf_write))
      end
    end
  endfunction

endclass
