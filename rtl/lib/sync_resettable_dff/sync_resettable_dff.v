module sync_resettable_dff #(parameter WIDTH = 1) (input clk, input reset, input [WIDTH-1:0] d, output reg [WIDTH-1:0] q);

initial begin 
  q = 0; // Initialize the output q to 0 at the start of the simulation. This ensures that q has a defined value before any clock edges occur.
end
always @ (posedge clk) begin 
  if (reset) begin
    q <= 0; // If the reset signal is asserted (active high), set the output y to 0. This is a common behavior for flip-flops, where the reset signal initializes the output to a known state.
   end else begin 
    q <= d; // on the rising edge of the clock, assign the value of d to y. The non-blocking assignment (<=) is used to ensure that the value of y is updated at the end of the current time step, allowing for proper synchronization with the clock signal.
   end
end

endmodule 