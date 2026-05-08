module mux #(parameter WIDTH = 1) (input [WIDTH-1:0] d1, d0, input sel, output [WIDTH-1:0] y);
assign y = sel ? d1 : d0; // the output y is assigned the value of d1 if sel is 1, and the value of d0 if sel is 0. This is the behavior of a multiplexer, which selects one of the two inputs based on the value of sel.
endmodule 