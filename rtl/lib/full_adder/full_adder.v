module full_adder (input a, b, cin, output reg sum, cout);
reg p, g;

always @ (*) begin 
 p = a ^ b;
 g  = a & b;
 sum = p ^ cin;
 cout  = g | (p & cin);
end

endmodule 