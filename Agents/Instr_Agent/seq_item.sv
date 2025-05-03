import risc_pkg::* ;

class seq_item;
 
 //---------------------------------------
 //data and control fields
 //---------------------------------------

      rand  bit [6:0] opcode;
      rand  bit [4:0] rs2, rs1, rd;
      rand  bit [11:0] imm12;
      rand  bit [19:0] imm20;

      rand  bit [2:0] funct3;
      rand  bit [6:0] funct7;
      bit [31:0] instruction;
      bit [31:0] instr_addr_o;     // Output - Address, word aligned
      bit        instr_req_o;      // Output - Request valid
      bit        instr_gnt_i;      // Input  - Grant
      bit        instr_rvalid_i;   // Input  - Read valid
      rand logic balance ;
      instr_type inst_type ;

// Get Instruction type function  
      function void Get_type ;
        case (opcode)  // opcode
//////////////////////////////////////  R_TYPE ///////////////////////////////////////////////////// 
          R_TYPE : begin // R_TYPE
                    if (funct7 == 7'h01) begin // R_TYPE M
                          case(funct3)   // R_TYPE M funct3 :    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7 
                                        //                       MUL,MULH,MULSU,MULU,DIV,DIVU,REM,REMU,                 
                            3'h0 : inst_type = MUL  ;
                            3'h1 : inst_type = MULH ;
                            3'h2 : inst_type = MULSU;
                            3'h3 : inst_type = MULU ; 
                            3'h4 : inst_type = DIV  ;
                            3'h5 : inst_type = DIVU ; 
                            3'h6 : inst_type = REM  ;
                            3'h7 : inst_type = REMU ;
                            endcase 
                    end // R_TYPE M
                    else begin   // R_TYPE Intger
                        case(funct3)  // R_TYPE Intger funct3 :    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7 
                                     //                            ADD, SLL, SLT, SLTU, XOR, SRX, OR, AND     
                            3'h0 : begin 
                                          if (funct7 == 7'h00) inst_type = ADD ;
                                          else inst_type = SUB ;
                                   end                                             
                            3'h1 : inst_type = SLL ;
                            3'h2 : inst_type = SLT ;
                            3'h3 : inst_type = SLTU;
                            3'h4 : inst_type = XOR ;
                            3'h5 : begin 
                                          if (funct7 == 7'h00) inst_type = SRL ;
                                          else inst_type = SRA ;
                                   end
                            3'h6 : inst_type = OR  ;  
                            3'h7 : inst_type = AND ;     
                            endcase
                    end  // R_TYPE Intger
           
               end // R_TYPE
//////////////////////////////////////  I_TYPE_0 /////////////////////////////////////////////////////            

          I_TYPE_0 : begin // I_TYPE_0
                          case(funct3)  //  I_TYPE_0: funct3 :    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7 
                                                     //           ADDI, SLLI, SLTI, SLTIU, XORI, SRXI, ORI, ANDI     
                                          3'h0 : inst_type = ADDI ;                                                  
                                          3'h1 : inst_type = SLLI ;
                                          3'h2 : inst_type = SLTI ;
                                          3'h3 : inst_type = SLTIU;
                                          3'h4 : inst_type = XORI ;
                                          3'h5 : begin 
                                                        if (imm12[11:5] == 7'h00) inst_type = SRLI ;
                                                        else inst_type = SRAI ;
                                                 end
                                          3'h6 : inst_type = ORI  ;  
                                          3'h7 : inst_type = ANDI ;     
                                          endcase
                     end // I_TYPE_0
//////////////////////////////////////  I_TYPE_1 /////////////////////////////////////////////////////  
          I_TYPE_1 : begin // I_TYPE_1
                          case(funct3)  // I_TYPE_1 funct3 :      0x0, 0x1, 0x2, 0x4, 0x5
                                                     //           LB,  LH,  LW,  LBU, LHU     
                                          3'h0 : inst_type = LB ;                                                  
                                          3'h1 : inst_type = LH ;
                                          3'h2 : inst_type = LW ;
                                          3'h4 : inst_type = LBU;
                                          3'h5 : inst_type = LHU; 
                                          endcase
                     end // I_TYPE_1
//////////////////////////////////////  I_TYPE_2 /////////////////////////////////////////////////////  
          I_TYPE_2 : inst_type = JALR ;  // I_TYPE_2: jalr ---> Jump And Link Reg

//////////////////////////////////////  S_TYPE /////////////////////////////////////////////////////  
          S_TYPE : begin // S_TYPE
                          case(funct3)  // S_TYPE  funct3 :       0x0, 0x1, 0x2
                                       //                         SB , SH , SW     
                                          3'h0 : inst_type = SB ;                                                  
                                          3'h1 : inst_type = SH ;
                                          3'h2 : inst_type = SW ;
                                          endcase
                     end // S_TYPE                           
//////////////////////////////////////  B_TYPE /////////////////////////////////////////////////////  
          B_TYPE : begin // B_TYPE
                          case(funct3)  // B_TYPE  funct3 :       0x0, 0x1, 0x4, 0x5, 0x6, 0x7
                                       //                         BEQ, BNE, BLT, BGE, BLTU, BGEU     
                                          3'h0 : inst_type = BEQ ;                                                  
                                          3'h1 : inst_type = BNE ;
                                          3'h4 : inst_type = BLT ;
                                          3'h5 : inst_type = BGE ;                                                  
                                          3'h6 : inst_type = BLTU;
                                          3'h7 : inst_type = BGEU;
                                          endcase
                     end // B_TYPE 
//////////////////////////////////////  U_TYPE_0 /////////////////////////////////////////////////////  
          U_TYPE_0 : inst_type = LUI ;   // U_TYPE_0: lui   ---> Load Upper Imm

//////////////////////////////////////  U_TYPE_1 /////////////////////////////////////////////////////  
          U_TYPE_1 : inst_type = AUIPC ;  // U_TYPE_1: auipc ---> Add Upper Imm to PC                                                                            

//////////////////////////////////////  J_TYPE /////////////////////////////////////////////////////  
          J_TYPE   : inst_type = JAL ;  // J_TYPE  : jal   ---> Jump And Link

        default : inst_type = UNKNOWN ; 
        endcase // opcode

      endfunction
  
//---------------------------------------
//Conistraints 
//---------------------------------------
// Ensure opcode is randomized to a legal value
constraint legal_opcode {
  opcode dist {R_TYPE := 25, I_TYPE_0 := 25 , I_TYPE_1 := 10, I_TYPE_2 := 5,
    S_TYPE := 10, B_TYPE := 10 , U_TYPE_0 := 5 , U_TYPE_1 := 5 , J_TYPE := 5 };
}

// Make balance for I  & M  in R_TYPE 

constraint funct7_dis_C {
                        balance dist {0 := 50 , 1 := 50} ;
}

// Randomize funct3 on the basis of the opcode field
constraint legal_funct3 {
    if (opcode == R_TYPE) {                                  // add sub    
        funct3 inside {add, sll, slt, sltu, Xor, srx, Or, And}; // 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7
    } else if (opcode == I_TYPE_0) {
        funct3 inside {addi, sllI, sltI, sltIu, xorI, srxI, orI, AndI}; // 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7 
    } else if (opcode == I_TYPE_1) {
        funct3 inside {lb, lh, lw, lbu, lhu};                  //0x0, 0x1, 0x2, 0x4, 0x5
    } else if (opcode == I_TYPE_2) {
        funct3 == 0;
    } else if (opcode == S_TYPE) {
        funct3 inside {sb, sh, sw};                                    // 0x0, 0x1, 0x2 
    } else if (opcode == B_TYPE) {
        funct3 inside {beq, bne, blt, bge, bltu, bgeu};               // 0x0, 0x1, 0x4, 0x5, 0x6, 0x7  
    }
}


// For R_TYPE, funct7 can take two separate values for ADD/SUB and SRL/SRA
constraint legal_funct7 {
    if (balance == 0) {
            if ((opcode == R_TYPE) && ((funct3 == add) || (funct3 == srx))) {
                    funct7 inside {7'h0, 7'h20};
            } else {
            funct7 == 7'h0;}
    } else {
        funct7 == 7'h01;}
   
}

// conistrain for sllI - srAI - srlI
constraint imm12_c {
                     if ((opcode == I_TYPE_0) && (funct3 == srxI)) {
                                imm12[11:5] inside {7'h0, 7'h20};
                                imm12[4:0] inside {[0:31]}; 
                        } else if ((opcode == I_TYPE_0) && (funct3 == sllI)) {
                         imm12[11:5] inside {7'h0};
                         imm12[4:0] inside {[0:31]}; 
                        } else {

                            imm12 inside {[-2048:2047]}; // 12-bit signed 
                        }
                      
}

constraint imm20_c {
                        imm20 inside {[-524288 : 524287]}; // 20-bit signed
}


// RD can't be X0 ,because x0 = 0 .and can't overwrite.
 constraint Rd_c {
                        rd inside {[1:31]} ;
}  

// Rs1 .
 constraint Rs1_c {
                        rs1 inside {[0:31]} ;
} 

// Rs1 .
 constraint Rs2_c {
                        rs2 inside {[0:31]} ;
} 
function void post_randomize();
// pass inst_type to enum object 
  Get_type();

    case (opcode)
        R_TYPE:    instruction = {funct7, rs2, rs1, funct3, rd, opcode};

        I_TYPE_0,
        I_TYPE_1,
        I_TYPE_2:    instruction = {imm12, rs1, funct3, rd, opcode};

        S_TYPE:    instruction = {imm12[11:5], rs2, rs1, funct3, imm12[4:0], opcode};
        B_TYPE:    instruction = {imm12[11], imm12[9:4], rs2, rs1, funct3, imm12[3:0], imm12[10], opcode};

        U_TYPE_0,
        U_TYPE_1:    instruction = {imm20, rd, opcode};

        J_TYPE:    instruction = {imm20[19], imm20[9:0], imm20[10], imm20[18:11], rd, opcode};
    endcase
  
  $display("\n inst_type: %0s \t Opcode: 0x%b \t RD: x%0d \t RS1: x%0d \t RS2: x%0d \t Funct3: 0x%h",
                    inst_type.name(), opcode, rd, rs1, rs2, funct3);
  if (opcode != R_TYPE ) begin
    $display(" Imm: 0x%h",((inst_type == U_TYPE_0) || (inst_type == U_TYPE_1) || (inst_type == J_TYPE)) ? imm20 : imm12);
    
  end else   $display(" Funct7: 0x%h ", funct7);
  
endfunction

// Extend Immediate function 
  function [31:0] Extend ;

      case (opcode)
        // I−type
        I_TYPE_0,
        I_TYPE_1,
        I_TYPE_2: Extend = {{20{instruction[31]}}, instruction[31:20]}; // imm12
        
        // S−type (stores)
        S_TYPE : Extend = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // imm12
        
        // B−type (branches)
        B_TYPE : Extend = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // imm12
        
        // J−type (jal)
        J_TYPE : Extend = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0}; // imm20
        
        // U-type : lui, auipc
        U_TYPE_0, 
        U_TYPE_1 : Extend = {instruction[31:12], 12'b0}; // imm20
        
        default: Extend = 32'bx; // undefined
    endcase  
  endfunction : Extend

  // // Convert to string for logging  in UVM 
  // function string convert2string();
  //   return $sformatf("inst_type: %s Opcode: 0x%h RD: x%0d RS1: x%0d RS2: x%0d Funct3: 0x%h Funct7: 0x%h Imm: 0x%h",
  //                   inst_type.name(), opcode, rd, rs1, rs2, funct3, funct7, 
  //                    ((inst_type == U_TYPE_0) || (inst_type == U_TYPE_1) || (inst_type == J_TYPE)) ? imm20 : imm12);
  // endfunction

  // Pack instruction
  // function void pack_instr();
  //   case (opcode)
  //       R_TYPE:    instruction = {funct7, rs2, rs1, funct3, rd, opcode};

  //       I_TYPE_0,
  //       I_TYPE_1,
  //       I_TYPE_2:    instruction = {imm12, rs1, funct3, rd, opcode};

  //       S_TYPE:    instruction = {imm12[11:5], rs2, rs1, funct3, imm12[4:0], opcode};
  //       B_TYPE:    instruction = {imm12[11], imm12[9:4], rs2, rs1, funct3, imm12[3:0], imm12[10], opcode};

  //       U_TYPE_0,
  //       U_TYPE_1:    instruction = {imm20, rd, opcode};

  //       J_TYPE:    instruction = {imm20[19], imm20[9:0], imm20[10], imm20[18:11], rd, opcode};
  //   endcase
  // endfunction

endclass

module rv32i_instr();
    seq_item gen;
    int rand_ok;

    initial begin
        gen = new();
      for (int i = 0; i < 1500; i++) begin
            rand_ok = gen.randomize();
            if (rand_ok != 1) $stop;
        
       // $display(" inst  = %0s , opcode = %0d , fucnt3 = %0h , funct7 = %0h",gen.inst_type.name(),gen.opcode,gen.funct3,gen.funct7);
     
        end
     
         #100;
        $finish;
    end
endmodule



   


  



            




