module pc #(parameter WIDTH = 4) (input [WIDTH-1:0] a, input [WIDTH-1:0] b, input clk, input  reset_sig, input add_sub, input en_pc_in, input en_pc_reg, input en_pc_out, output [WIDTH-1:0] pc_q);

wire [WIDTH-1:0] internal_result;
wire [WIDTH-1:0] internal_a;
wire [WIDTH-1:0] internal_b;
wire [WIDTH-1:0] internal_sum;
wire [WIDTH-1:0] next_result;
wire [WIDTH:0] carry;
assign carry[0] = add_sub; // carry[0] is assigned the value of add_sub, which is the input signal that determines whether the operation is addition or subtraction. This is because in a full adder, the carry-in (cin) for the least significant bit (LSB) is determined by whether we are performing addition (carry-in = 0) or subtraction (carry-in = 1).

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

 // tristate buffer to write into the BUS 
 tristate_buff_n #(.WIDTH(1)) buff (.en(en_pc_out), .a(internal_result[i]), .y(pc_q[i]));
   
end
endgenerate
  
endmodule