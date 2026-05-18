module nor_n #(parameter WIDTH = 2) (input [WIDTH-1:0] a, output y);
assign y = ~(|a); // the output y is assigned the result of the bitwise NOR operation on all the inputs. This means y will be 1 only if all inputs are 0, otherwise it will be 0.
endmodule