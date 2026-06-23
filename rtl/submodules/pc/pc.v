`timescale 1ns/1ps

module pc #(parameter WIDTH = 4) (
  input clk, 
  input  reset_sig,
  input [WIDTH-1:0] a, 
  input [WIDTH-1:0] b,  
  input add_sub, 
  input en_pc_in, 
  input en_pc_reg, 
  output [WIDTH-1:0] pc_q);

wire [WIDTH-1:0] internal_result;
wire [WIDTH-1:0] internal_a;
wire [WIDTH-1:0] internal_b;
wire [WIDTH-1:0] internal_sum;
wire [WIDTH-1:0] next_result;
wire [WIDTH:0] carry;
assign carry[0] = add_sub; // carry[0] is assigned the value of add_sub, which is the input signal that determines whether the operation is addition or subtraction. This is because in a full adder, the carry-in (cin) for the least significant bit (LSB) is determined by whether we are performing addition (carry-in = 0) or subtraction (carry-in = 1).

assign pc_q = internal_result; // The output of the program counter (PC) is assigned the value of internal_result, which is the registered value that holds the current state of the PC. This allows other parts of the system to read the current value of the PC for use in instruction fetching or other operations that require knowledge of the current program address.

genvar i;
generate 
for (i = 0; i < WIDTH; i = i + 1) begin: gen 

 assign internal_a[i] = a[i];
 assign internal_b[i] = b[i];

 // Register for the program counter (PC)
 en_dff #(.WIDTH(1)) pc_reg (.clk(clk), .en(en_pc_reg), .reset(reset_sig), .d(next_result[i]), .q(internal_result[i]));

 // Full adder to add A and B.
 full_adder fa (
  .a(internal_result[i]),
  .b(internal_b[i]),
  .cin(carry[i]),
  .sum(internal_sum[i]),
  .cout(carry[i + 1])
 );

 // MUX for selecting whether the input comes from BUS or the incremented sum from the adder.
 mux #(.WIDTH(1)) mux_inst (.d1(internal_a[i]), .d0(internal_sum[i]), .sel(en_pc_in), .y(next_result[i]));
   
end
endgenerate
  
endmodule