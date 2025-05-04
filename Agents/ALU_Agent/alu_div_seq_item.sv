import cv32e40p_pkg::*;

class alu_div_seq_item extends  uvm_sequence_item;
  //---------------------------------------
 //data and control fields
 //---------------------------------------
    alu_opcode_e        operator_i;
    logic        [31:0] operand_a_i;
    logic        [31:0] operand_b_i;

    logic        [31:0] result_o;
    logic        comparison_result_o; // for branch_decision 


 //---------------------------------------
//Constructor
//---------------------------------------
  function new(string name = "alu_div_seq_item");
    super.new(name);
  endfunction
  
//---------------------------------------
//Utility and Field macros
//---------------------------------------
  `uvm_object_utils_begin(alu_div_seq_item)
    `uvm_field_enum(alu_opcode_e , operator_i , UVM_DEFAULT)
    `uvm_field_int(short_signed_i,UVM_DEFAULT)
    `uvm_field_int(operand_a_i,UVM_DEFAULT)
    `uvm_field_int(operand_b_i,UVM_DEFAULT)
    `uvm_field_int(result_o,UVM_DEFAULT)
    `uvm_field_int(comparison_result_o,UVM_DEFAULT)
  `uvm_object_utils_end

endclass : alu_div_seq_item

