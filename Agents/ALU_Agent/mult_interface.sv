interface mult_if (input logic clk);  // I think that we don't need clk ,because clk core and rst_n connect to all blocks
   	logic                 ex_ready_i; 		    // EX stage ready for new data
    logic                 enable_i;           // enable block 	
    mul_opcode_e          operator_i;        // opcode we are interestered with MUL_MAC32 and MUL_H
	  logic          [1:0]  short_signed_i;   /*   	 short_signed_i = 11  ---> mulh       
												                           short_signed_i = 01  ---> mulhsu 	
												                           short_signed_i = 00  ---> mulhu */														
    logic 		    [31:0] op_a_i;
    logic 		    [31:0] op_b_i;
    logic 		    [31:0] result_o;      // output  
    logic                ready_o;      //  output ready
endinterface : mult_if



mult_if intf();
assign intf.internal_signal = top.dut.submodule.signal_name;
assign intf.internal_signal = top.dut.submodule.signal_name;
assign intf.internal_signal = top.dut.submodule.signal_name;
assign intf.internal_signal = top.dut.submodule.signal_name;
assign intf.internal_signal = top.dut.submodule.signal_name;


/*
	 typedef enum logic [MUL_OP_WIDTH-1:0] {

    MUL_MAC32 = 3'b000,   // mul
    MUL_H     = 3'b110   //   

  } mul_opcode_e;
  // decoder line 939
   {6'b00_0001, 3'b000}: begin // mul   funt7 - funtc3
              alu_en          = 1'b0;
              mult_int_en     = 1'b1;
              mult_operator_o = MUL_MAC32;
              regc_mux_o      = REGC_ZERO;
            end
            {6'b00_0001, 3'b001}: begin // mulh
              alu_en             = 1'b0;
              mult_int_en        = 1'b1;
              regc_used_o        = 1'b1;
              regc_mux_o         = REGC_ZERO;
              mult_signed_mode_o = 2'b11;
              mult_operator_o    = MUL_H;
            end
            {6'b00_0001, 3'b010}: begin // mulhsu
              alu_en             = 1'b0;
              mult_int_en        = 1'b1;
              regc_used_o        = 1'b1;
              regc_mux_o         = REGC_ZERO;
              mult_signed_mode_o = 2'b01;
              mult_operator_o    = MUL_H;
            end
            {6'b00_0001, 3'b011}: begin // mulhu
              alu_en             = 1'b0;
              mult_int_en        = 1'b1;
              regc_used_o        = 1'b1;
              regc_mux_o         = REGC_ZERO;
              mult_signed_mode_o = 2'b00;
              mult_operator_o    = MUL_H;

               cv32e40p_mult mult_i (
      .clk  (clk),
      .rst_n(rst_n),

      .enable_i  (mult_en_i),
      .operator_i(mult_operator_i),

      .short_subword_i(mult_sel_subword_i),
      .short_signed_i (mult_signed_mode_i),

      .op_a_i(mult_operand_a_i),
      .op_b_i(mult_operand_b_i),
      .op_c_i(mult_operand_c_i),
      .imm_i (mult_imm_i),

      .dot_op_a_i  (mult_dot_op_a_i),
      .dot_op_b_i  (mult_dot_op_b_i),
      .dot_op_c_i  (mult_dot_op_c_i),
      .dot_signed_i(mult_dot_signed_i),
      .is_clpx_i   (mult_is_clpx_i),
      .clpx_shift_i(mult_clpx_shift_i),
      .clpx_img_i  (mult_clpx_img_i),

      .result_o(mult_result),

      .multicycle_o (mult_multicycle_o),
      .mulh_active_o(mulh_active),
      .ready_o      (mult_ready),
      .ex_ready_i   (ex_ready_o)
  );
  */