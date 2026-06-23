`timescale 1ns/1ps

module memory_row #(parameter DATA_W = 8) (
    input clk,
    input reset_sig,
    input decoder_output_line,  
    input ram_in_sel, 
    input [DATA_W-1:0] data_in, 
    
    output [DATA_W-1:0] mem_row_y
);

wire row_write_enable;
wire [DATA_W-1:0] memory_cell_output;


// Write Control Gate
and_n #(.WIDTH(2)) ram_in_control_inst (.a({decoder_output_line, ram_in_sel}), .y(row_write_enable));

genvar i;
generate 
    for (i = 0; i < DATA_W; i = i + 1) begin: gen_memory_cell 

        en_dff #(.WIDTH(1)) memory_cell_inst (
            .clk(clk), 
            .en(row_write_enable),
            .reset(reset_sig), 
            .d(data_in[i]), 
            .q(memory_cell_output[i])
        );

            // If row is selected, output the cell data. Otherwise, output 0.
        assign mem_row_y[i] = decoder_output_line ? memory_cell_output[i] : 1'b0;
    end
endgenerate 
  
endmodule