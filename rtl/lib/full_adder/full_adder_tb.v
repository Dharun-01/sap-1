module full_adder_tb();
reg tb_a, tb_b, tb_cin;
wire tb_sum, tb_cout;

reg [4:0] testvectors [0:7]; // A array to hold our test vectors, each vector is 5 bits: {a, b, cin, expected_sum, expected_cout}
reg sum_expected, cout_expected; // To hold the expected values of sum and cout for each test case
integer i; // Our Page turner

full_adder dut (.a(tb_a), .b(tb_b), .cin(tb_cin), .sum(tb_sum), .cout(tb_cout));

initial begin 
  $dumpfile("sim/full_adder/full_adder.vcd");
  $dumpvars(0, full_adder_tb);
 
  $readmemb("rtl/lib/full_adder/full_adder.tv", testvectors); // Load our test vectors from a file

  // Automation loop to apply test vectors
  for (i = 0; i < 8; i = i + 1) begin 
    {tb_a, tb_b, tb_cin, sum_expected, cout_expected} = testvectors[i]; //Split the 5-bit testvector into inputs and expected outputs
    #10; // Wait for the outputs to stabilize after applying inputs

    if (tb_sum !== sum_expected || tb_cout !== cout_expected) begin 
      $display("Test Case %d failed", i);
    end else begin 
      $display("Test Case %d passed", i);
    end
    end
    $display("All test cases completed");
    $finish;
end

endmodule