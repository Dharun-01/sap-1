module decoder_n #(parameter WIDTH = 2) (input [WIDTH-1:0] in, output reg [2**WIDTH-1:0] y);

always @ (*) begin 
  y = 0; // Initialize the output to 0
  y[in] = 1; // Set the bit corresponding to the input value to 1, all other bits will be 0
end 
endmodule 