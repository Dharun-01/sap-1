module memory_row #(parameter DATA_W = 8) (input decoder_output_line, input ram_out_sel, input ram_in_sel, input [DATA_W-1:0] data_in, output [DATA_W-1:0] mem_row_y);

wire ram_in_decoder_line_output;
wire [DATA_W-1:0] memory_cell_output;
wire [DATA_W-1:0] memory_cell_and_gate_output;

and_n #(.WIDTH(2)) ram_in_control_inst (.a({decoder_output_line, ram_in_sel}), .y(ram_in_decoder_line_output));

genvar i;
generate 
 for (i = 0; i < DATA_W; i = i + 1) begin: gen_memory_cell 
  async_resettable_dff #(.WIDTH(1)) memory_cell_inst (.clk(ram_in_decoder_line_output), .reset(1'b0), .d(data_in[i]), .q(memory_cell_output[i]));

  and_n #(.WIDTH(2)) and_inst (.a({memory_cell_output[i], decoder_output_line}), .y(memory_cell_and_gate_output[i]));

  tristate_buff_n #(.WIDTH(1)) tristate_inst (.en(ram_out_sel), .a(memory_cell_and_gate_output[i]), .y(mem_row_y[i]));

 end
endgenerate 
  
endmodule