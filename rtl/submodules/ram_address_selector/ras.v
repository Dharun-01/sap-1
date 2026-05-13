module ras #(parameter WIDTH = 4) (input [WIDTH-1:0] addr, input clk, input reset_sig, input en_ras, output [WIDTH-1:0] ras_q);
 
 genvar i; // Declare a generate variable for use in the generate block to create multiple instances of the enable D flip-flop for each bit of the RAM address selector register.
 generate 
   for (i = 0; i < WIDTH; i = i + 1) begin: en_dff 
       
       en_dff #(.WIDTH(1)) dff (.en(en_ras), .clk(clk),.d(addr[i]), .reset(reset_sig), .q(ras_q[i])); // Use an enable D flip-flop for each bit of the RAM address selector register. The flip-flop will only update its output (ras_q[i]) with the input data (addr[i]) when the en_ras signal is high, allowing for controlled loading of the RAM address into the register. This design allows the RAM address selector to hold its value when not enabled, which can be useful for maintaining a stable address for RAM access in a larger system.
   end
 endgenerate
  
endmodule 