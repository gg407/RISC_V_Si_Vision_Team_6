// Interfaces
interface data_if(input logic clk);
    logic [31:0] data_addr_o;
    logic        data_req_o;
    logic        data_gnt_i;
    logic        data_we_o;
    logic [3:0]  data_be_o;
    logic [31:0] data_wdata_o;
    logic        data_rvalid_i;
    logic [31:0] data_rdata_i;
endinterface