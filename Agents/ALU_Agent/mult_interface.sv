import cv32e40p_pkg::*;
interface mult_if (input logic clk); 
    logic                 rst_n;
    logic                 ex_ready_i; 	       // EX stage ready for new data
    logic                 enable_i;           // enable block 	
    mul_opcode_e          operator_i;        // opcode we are interestered with MUL_MAC32 and MUL_H
    logic          [1:0]  short_signed_i;   /*   	short_signed_i = 11  ---> mulh       
							short_signed_i = 01  ---> mulhsu 	
							short_signed_i = 00  ---> mulhu */														
    logic 	   [31:0] op_a_i;
    logic 	   [31:0] op_b_i;
    logic          [31:0] result_o;      // output  
    logic                 ready_o;      //  output ready
endinterface : mult_if
