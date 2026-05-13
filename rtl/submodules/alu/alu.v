module alu #(parameter WIDTH = 8) (input [WIDTH-1:0] a, b, input clk, input reset_sig, input en_a, input en_b, input en_res, input a_out, input add_sub, output [WIDTH-1:0] result, output reg carry_flag, output [WIDTH-1:0] a_result, output reg zero_flag);

wire [WIDTH-1:0] intern_a, xor_intern_b, intern_b;
wire [WIDTH-1:0] internal_sum;
wire [WIDTH:0] carry;
assign carry[0] = add_sub;

genvar i;
generate 
  for (i = 0; i < WIDTH; i = i +1) begin: en_flip_flop
     // Register A
      en_dff #(.WIDTH(1)) a_input (.clk(clk), .en(en_a), .reset(reset_sig), .d(a[i]), .q(intern_a[i]));

      tristate_buff_n #(.WIDTH(1)) a_output (.en(a_out), .a(intern_a[i]), .y(a_result[i])); // Use a tri-state buffer to control when the value of a (intern_a) is output to a_result. The buffer will only drive a_result when a_out is high, allowing for better control over when the value of a is visible to other parts of the system.

     // Register B
      en_dff #(.WIDTH(1)) b_input (.clk(clk), .en(en_b), .reset(reset_sig), .d(b[i]), .q(xor_intern_b[i]));

        assign intern_b[i] = xor_intern_b[i] ^ add_sub; // XOR the registered value of b (xor_intern_b) with the add_sub signal to determine whether we are performing addition or subtraction. If add_sub is 0, intern_b will be the same as xor_intern_b (which is the registered value of b). If add_sub is 1, intern_b will be the bitwise complement of xor_intern_b, which is necessary for performing subtraction using two's complement representation.

      // Full Adder
      full_adder fa (.a(intern_a[i]), .b(intern_b[i]), .cin(carry[i]), .sum(internal_sum[i]), .cout(carry[i + 1]));

      tristate_buff_n #(.WIDTH(1)) res_output (.en(en_res), .a(internal_sum[i]), .y(result[i])); // Use a tri-state buffer to control when the result of the addition or subtraction is output to the result bus. The buffer will only drive the result bus when en_res is high, allowing for better control over when the ALU's output is visible to other parts of the system.
   end
endgenerate

always @ (*) begin 

   zero_flag = ~(|internal_sum); // The zero_flag is set to 1 if all bits of the sum are 0, indicating that the result of the addition or subtraction is zero. This can be useful for conditional operations or for signaling certain conditions in a larger system.

   carry_flag = carry[WIDTH]; // Output the final carry-out from the most significant bit of the addition or subtraction operation. This indicates whether there was an overflow in the case of addition or a borrow in the case of subtraction, which can be important for certain applications or for further processing in a larger system.

end
 endmodule