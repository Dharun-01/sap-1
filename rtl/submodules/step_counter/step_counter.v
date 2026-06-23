`timescale 1ns/1ps

module step_counter #(parameter WIDTH = 3) (input clk, input [WIDTH-1:0] b, input reset_sig, output [WIDTH-1:0] internal_result);

wire [WIDTH-1:0] internal_sum;
wire [WIDTH-1:0] next_result;
wire [WIDTH:0] carry;
wire [WIDTH-1:0] internal_b;
parameter [WIDTH-1:0] internal_a = 3'b000;
assign carry[0] = 1'b0;

genvar i;

generate 
  for (i = 0; i < WIDTH; i = i + 1) begin: gen 
 
    assign internal_b[i] = b[i]; 

    // step_counter register
    async_resettable_dff #(.WIDTH(1)) async_reset_dff (.clk(~clk), .reset(reset_sig), .d(next_result[i]), .q(internal_result[i]));
   
   // full adder to add A and B
    full_adder fa (.a(internal_result[i]), .b(internal_b[i]), .cin(carry[i]), .cout(carry[i + 1]), .sum(internal_sum[i]));

  // select between incrementer and default 0000 of internal_a
    mux #(.WIDTH(1)) mux_inst (.d1(internal_a[i]), .d0(internal_sum[i]), .sel(internal_result[2] & internal_result[1]), .y(next_result[i]));
  end 
endgenerate 

endmodule