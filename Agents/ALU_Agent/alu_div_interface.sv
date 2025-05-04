interface alu_div_if (input logic clk); 
    logic               rst_n;
    logic               ex_ready_i; // divion only 
    logic               enable_i;   // divion only 
    alu_opcode_e        operator_i;
    logic        [31:0] operand_a_i;
    logic        [31:0] operand_b_i;

    logic        [31:0] result_o;
    logic        comparison_result_o; // for branch_decision 
    logic        ready_o;
   
endinterface : alu_div_if

