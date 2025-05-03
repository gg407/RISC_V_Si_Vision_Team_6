// Interfaces
interface ins_if(input logic clk);
    logic        instr_req_o;
    logic [31:0] instr_addr_o;
    logic        instr_gnt_i;
    logic [31:0] instr_rdata_i;
    logic        instr_rvalid_i;
endinterface