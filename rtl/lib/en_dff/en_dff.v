`timescale 1ns/1ps

module en_dff #(parameter WIDTH = 1) (input en, input clk, input reset, input [WIDTH-1:0] d, output reg q);

always @ (posedge clk, posedge reset) 
  if (en) begin 
   q <= d;
  end else if (reset) begin 
    q <= 0;
  end
  
endmodule 