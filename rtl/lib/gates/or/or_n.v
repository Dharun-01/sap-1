`timescale 1ns/1ps

module or_n #(parameter WIDTH = 2) (input [WIDTH-1:0] a, output y); // ports for the or_n module, we have a parameter WIDTH that determines how many inputs we have, and one output y

assign y = |a; // the output y is assigned the result of the bitwise OR operation on all the inputs. This means y will be 1 if any input is 1,  otherwise it will be 0.

endmodule