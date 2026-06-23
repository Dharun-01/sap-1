`timescale 1ns/1ps

module  and_n #(parameter WIDTH = 2) (input [WIDTH-1:0] a, output y); // ports for the and_n module, we have a parameter WIDTH that determines how many inputs we have, and one output y which will be the result of the AND operation on all the inputs.

  assign y = &a; // the output y is assigned the result of the bitwise AND operation on all the inputs. This means y will be 1 only if all inputs are 1, otherwise it will be 0.

endmodule