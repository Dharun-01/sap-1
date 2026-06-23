`timescale 1ns/1ps

module instruction_register #(parameter WIDTH = 8) (input clk, input en_load, input reset_sig, input [WIDTH-1:0] instr_d, output [WIDTH-1:0] instruction_q);

 genvar i; // Declare a generate variable for use in the generate block to create multiple instances of the enable D flip-flop for each bit of the instruction register.
 generate 
  for (i = 0; i < WIDTH; i = i + 1) begin: en_dff 

   en_dff #(.WIDTH(1)) dff (.clk(clk), .en(en_load), .reset(reset_sig), .d(instr_d[i]), .q(instruction_q[i])); // Use an enable D flip-flop for each bit of the instruction register. The flip-flop will only update its output (q[i]) with the input data (d[i]) when the en_load signal is high, allowing for controlled loading of instructions into the register. The reset_sig can be used to asynchronously reset the register to a known state (e.g., all zeros) when needed.
   
  end
 endgenerate
endmodule