`timescale 1ns/1ps

module decoder_tb();
parameter N = 3; // Number of input bits for the decoder, which will determine the size of the output (2^N)
reg [N-1:0] tb_in;
wire [2**N-1:0] tb_y;

reg [10:0] testvectors [0:7]; // An array to hold our test vectors, each vector is 11 bits: {in[2:0], expected_y[7:0]}
reg [2**N-1:0] y_expected; // To hold the expected value of the output for each test case
integer i; // Our Page turner

decoder_n #(.WIDTH(N)) dut (.in(tb_in), .y(tb_y));

// Test all possible input combinations
initial begin 
  $dumpfile("sim/decoder/decoder.vcd");
  $dumpvars(0, decoder_tb);
  $readmemb("rtl/lib/decoder/decoder.tv", testvectors); // Load our test vectors from a file

  // Automation loop to apply test vectors
  for (i = 0; i < 8; i= i + 1) begin 
    {tb_in, y_expected} = testvectors[i]; // Split the 11-bit testvector into input and expected output
    #10; // Wait for the output to stabilize after applying inputs

    if (tb_y !== y_expected) begin 
      $display("Test Case %d failed: Input = %b, Expected Output = %b, Actual Output = %b", i, tb_in, y_expected, tb_y);
    end else begin 
      $display("Test Case %d passed: Input = %b, Output = %b", i, tb_in, tb_y);
    end
  end
  $display("All test cases completed");
  $finish;
end
endmodule