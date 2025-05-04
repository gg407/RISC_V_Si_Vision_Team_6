import risc_pkg::* ;
class riscv_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(riscv_scoreboard)

  // Virtual interface to DUT
  virtual riscv_if vif;
  ins_seq_item inst_seq;


  // Handle incoming instruction
  function void inst_write(instr_item inst);
    // Push incoming instruction into the queue
    inst_seq<=inst;
  endfunction
    
    logic [31:0] instr; instr_type ins_type; logic f_valid;
    // decode stage
    logic [4:0] rs1, rs2, rd_d; logic [31:0] rs1_data, rs2_data,pc; logic [31:0] imm_d;  logic D_valid;
    // execute stage alu stage
    logic [4:0]rd_e;logic [31:0] alu_result,imm_e ;[6:0] opcode;[4:0] funct5;logic [2:0] funct3;logic [6:0] funct7; logic E_valid; int x,y;
    // memory stage load/store stage
    logic [31:0] load_data;logic [31:0] store_data;logic [31:0] store_addr;logic [31:0] load_addr;  
    // writeback stage register file stage
    logic [31:0] rf_write_data;logic [4:0] rf_write_addr;logic rf_write_en;logic [31:0] wb_data;logic [4:0] wb_addr;logic wb_en; logic W_valid;


// task fetch(ins_seq_item seq)
//   seq.Get_type();
//   instr=seq.instr_rdata_i;
//   pc= seq.instr_addr_o;
//   inst_type=seq.inst_type
// endtask

task decode()
  //inst.Get_type();
  opcode<=inst.instr[6:0];
  pc<=inst.instr_addr_o;
  case(inst.opcode)
    R_TYPE:
      begin
        rs1<=instr[19:15]; //not sure in all of the cases
        rs2<=instr[24:20]; //not sure in all of the cases
        rs1_data<=reg_file[instr[19:15]];
        rs2_data<=reg_file[instr[24:20]];
        rd_e<=instr[11:7];
        funct3<=instr[14:12];
        funct7<=instr[31:25];
        imm_d<=0;
      end
    I_TYPE_0:
      begin
        rs1<=instr[19:15];
        rs1_data<=reg_file[instr[19:15]];
        rd_e<=instr[11:7];
        funct3<=instr[14:12];
        funct7<=0;
        imm_d<={{20{instr[31]}},instr[31:20]} ;
      end
    I_TYPE_1:
      begin
        rs1<=instr[19:15];
        rs1_data<=reg_file[instr[19:15]];
        rd_e<=instr[11:7];
        funct3<=instr[14:12];
        funct7<=0;
        imm_d<={{20{instr[31]}} ,instr[31:20]} ;
      end
    I_TYPE_2:
      begin
        rs1<=instr[19:15];
        rs1_data<=reg_file[instr[19:15]];
        rd_e<=instr[11:7];
        funct3<=instr[14:12];
        funct7<=0;
        imm_d<={{20{instr[31]}} ,instr[31:20]} ;
      end
    S_TYPE:
      begin
        rs1<=instr[19:15];
        rs2<=instr[24:20];
        rs1_data<=reg_file[instr[19:15]];
        rs2_data<=reg_file[instr[24:20]];
        funct3<=instr[14:12];
        funct7<=0;
        imm_d<={ {20{instr[31]}},instr[31:25], instr[11:7] };
      end
    B_TYPE:
      begin
        rs1<=instr[19:15];
        rs2<=instr[24:20];
        rs1_data<=reg_file[instr[19:15]];
        rs2_data<=reg_file[instr[24:20]];
        funct3<=instr[14:12];
        funct7<=0;
        imm_d[0]<=0;
        imm_d[11]<=instr[7];
        imm_d[4:1]<=instr[11:8];
        imm_d[10:5]<=instr[30:25];
        imm_d[12]<=instr[31];
      end
    U_TYPE_0:
      begin
        rd_e<=instr[11:7];
        funct3<=0;
        funct7<=0;
        imm_d[31:12]<={instr[31:12], 12'b0};
      end
    U_TYPE_1:
      begin
        rd_e<=instr[11:7];
        funct3<=0;
        funct7<=0;
        imm_d<={ {12{instr[31]}}, instr[31:12] };
      end
    J_TYPE:
      begin
        rd_e<=instr[11:7];
        funct3<=0;
        funct7<=0;
        imm_d<={ instr[31],instr[19:12],instr[20],instr[30:21],1'b0 };
      end
  endcase
endtask
task execute()
  rf_write_addr<=rd_e;
  rf_write_en<=1;
  case(opcode)
  7'b0010011:
             case(funct3)
                2'h00: rf_write_data<= rs1_data+imm_e;
                2'h01: rf_write_data<= rs1_data<<imm[4:0];
                2'h02: rf_write_data<= (signed'(rs1_data)<signed'(imm))? 1:0;
                2'h03: rf_write_data<= (rs1_data<imm)? 1:0;
                2'h04: rf_write_data<= rs1_data^imm;
                2'h05: 
                      if( imm[11:5]=4'h00) rf_write_addr<= rs1_data>>imm[4:0];
                      else if(imm[11:5]=4'h20) rf_write_addr<= rs1_data>>>imm[4:0];
                2'h06: rf_write_data<= rs1_data|imm;
                2'h07: rf_write_data<= rs1_data&imm;

             endcase
  7'b0110111: rf_write_data<= imm<<12;
  7'b0010111: rf_write_data<= pc+(imm<<12);

  endcase
endtask

task wb()
    if(wb_addr!=0) begin
      reg_file[wb_addr]<=rf_write_data;
    end
  
endtask


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
