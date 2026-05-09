module tristate_buff_n #(parameter WIDTH = 1) (input en, input [WIDTH-1:0] a, output [WIDTH-1:0] y);
assign y = en ? a :{WIDTH{1'bz}};
endmodule 
