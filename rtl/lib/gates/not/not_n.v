`timescale 1ns/1ps

module not_n #(parameter WIDTH = 2) (input [WIDTH-1:0] a, output [WIDTH-1:0] y); // ports for the not_n module, we have a parameter WIDTH that determines how many inputs we have, and one output y which will be the result of the NOT operation on all the inputs.
assign y = ~a; // the output y is assigned the result of the bitwise NOT operation on all the inputs. This means y will be 1 for any input that is 0, and 0 for any input that is 1.
endmodule
