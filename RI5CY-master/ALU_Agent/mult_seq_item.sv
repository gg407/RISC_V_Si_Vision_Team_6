import cv32e40p_pkg::*;

class mult_seq_item extends  uvm_sequence_item;
  //---------------------------------------
 //data and control fields
 //---------------------------------------
    mul_opcode_e       operator_i;        // opcode we are interestered with MUL_MAC32 and MUL_H
    logic        [1:0]  short_signed_i;   /*      short_signed_i = 11  ---> mulh       
                                                  short_signed_i = 01  ---> mulhsu   
                                                  short_signed_i = 00  ---> mulhu */                                                     
    logic        [31:0] op_a_i;
    logic        [31:0] op_b_i;
    logic        [31:0] result_o;  

 //---------------------------------------
//Constructor
//---------------------------------------
  function new(string name = "mult_seq_item");
    super.new(name);
  endfunction
  


//---------------------------------------
//Utility and Field macros
//---------------------------------------
  `uvm_object_utils_begin(mult_seq_item)
    `uvm_field_enum(mul_opcode_e , operator_i , UVM_DEFAULT)
    `uvm_field_int(short_signed_i,UVM_DEFAULT)
    `uvm_field_int(op_a_i,UVM_DEFAULT)
    `uvm_field_int(op_b_i,UVM_DEFAULT)
    `uvm_field_int(result_o,UVM_DEFAULT)
  `uvm_object_utils_end

endclass : mult_seq_item

