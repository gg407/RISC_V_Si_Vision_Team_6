class reg_file_sequence_item extends uvm_sequence_item ;
	
	`uvm_object_utils(reg_file_sequence_item)
	
	localparam ADDR_WIDTH = 5;
    localparam DATA_WIDTH = 32;
    
    logic [ADDR_WIDTH-1:0] raddr_a_i;
    logic [DATA_WIDTH-1:0] rdata_a_o;

    //Read port R2
    logic [ADDR_WIDTH-1:0] raddr_b_i;
    logic [DATA_WIDTH-1:0] rdata_b_o;


    // Write port W1
    logic [ADDR_WIDTH-1:0] waddr_a_i;
    logic [DATA_WIDTH-1:0] wdata_a_i;
    //logic                  we_a_i;

    // Write port W2
    logic [ADDR_WIDTH-1:0] waddr_b_i;
    logic [DATA_WIDTH-1:0] wdata_b_i;
    //logic                  we_b_i;
	
	function new(string name = "reg_file_sequence_item");
		super.new(name);
	endfunction
  
endclass: reg_file_sequence_item