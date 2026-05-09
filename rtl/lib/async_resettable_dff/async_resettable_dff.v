module async_resettable_dff #(parameter WIDTH = 1) (input clk, input reset, input [WIDTH-1:0] d, output reg [WIDTH-1:0] q);

always @ (posedge clk, posedge reset) begin 
   if (reset) begin 
      q <= 0; // If the reset signal is asserted (active high), set the output q to 0. This is a common behavior for flip-flops, where the reset signal initializes the output to a known state.
   end else begin 
    q <= d; // on the rising edge of the clock, assign the value of d to q. The non-blocking assignment (<=) is used to ensure that the value of q is updated at the end of the current time step, allowing for proper synchronization with the clock signal.
   end
end

endmodule 