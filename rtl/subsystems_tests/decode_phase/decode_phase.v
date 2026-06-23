module decode_phase #(parameter WORD_WIDTH = 8) (
  input clk, 
  input reset,
  input dec_en_ir_in,
  input dec_en_ir_out,
  input [WORD_WIDTH-1:0] dec_instr_d,

  output [WORD_WIDTH-1:0] dec_out_view_bus
);
 
 wire [WORD_WIDTH-1:0] w_bus; // Internal bus to connect the outputs of the decode phase to the next stage (e.g., execute phase) and for testing purposes.

 assign dec_out_view_bus = w_bus; // Connect the internal bus to an output for testing and  observation purposes.

 wire [WORD_WIDTH-1:0] ir_out; // Output of the instruction register, which holds the currently decoded instruction.

 // Instantiating Instruction Register
instruction_register #(.WIDTH(WORD_WIDTH)) instruction_register_inst (
  .clk(clk), 
  .en_load(dec_en_ir_in), 
  .reset_sig(reset), 
  .instr_d(dec_instr_d), 

  .instruction_q(ir_out)
  );

// Tristate Buffer connecting IR output to the W-Bus
tristate_buff_n #(.WIDTH(4)) ir_bus_driver (.a(ir_out[3:0]), .en(dec_en_ir_out), .y(w_bus[3:0]));

endmodule