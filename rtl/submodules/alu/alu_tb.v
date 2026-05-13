module alu_tb();
parameter W = 3;
reg [W-1:0] tb_a, tb_b;
reg tb_clk, tb_en_a, tb_en_b, tb_en_res, tb_a_out, tb_add_sub;
reg [11:0] test_vectors [0:5];
wire [W-1:0] tb_result;
wire tb_carry_flag, tb_zero_flag;
wire [W-1:0] tb_a_result; // To observe the output of a_result from the ALU, which will allow us to verify that the tri-state buffer controlling the output of a is functioning correctly and that the value of a is being captured and output as expected.

reg tb_reset; // To provide a reset signal to the ALU, which can be used to initialize the internal state of the ALU and ensure that it starts from a known state for each test case. This can help to improve the reliability and consistency of the test results by ensuring that any previous state or values do not affect the current test case.

reg [W-1:0] expected_result; // To hold the expected result for each test case, which will be compared against the actual output from the ALU to verify correctness.

reg expected_carry_flag; // To hold the expected value of the carry flag for each test case, which will be compared against the actual carry flag output from the ALU to verify correctness.

reg expected_zero_flag; // To hold the expected value of the zero flag for each test case, which will be compared against the actual zero flag output from the ALU to verify correctness.

  integer i; // An integer variable to be used as a loop counter for iterating through the test cases in the test vector array.

always #5 tb_clk = ~tb_clk; // Clock generation: Toggle the clock every 5 time units to create a clock signal for the ALU.

alu #(.WIDTH(W)) dut (.clk(tb_clk), .a(tb_a), .b(tb_b), .reset_sig(tb_reset), .en_a(tb_en_a), .en_b(tb_en_b), .en_res(tb_en_res), .add_sub(tb_add_sub), .result(tb_result), .a_result(tb_a_result), .carry_flag(tb_carry_flag), .a_out(tb_a_out), .zero_flag(tb_zero_flag));

initial begin 
  $dumpfile("sim/alu/alu.vcd");
  $dumpvars(0, alu_tb);
  $readmemb("rtl/submodules/alu/alu.tv", test_vectors);
 
// 1. Initialize Everything
    tb_clk = 0;
    expected_result = 0;
    expected_carry_flag = 0;
    expected_zero_flag = 0;
    tb_reset = 1; // Start in reset
    tb_en_a = 0; tb_en_b = 0; tb_en_res = 0; tb_a_out = 0;
    tb_a = {W{1'b0}}; tb_b = {W{1'b0}}; tb_add_sub = 0;
    i = 0;
    #15;          // Hold reset for more than one clock cycle
    tb_reset = 0; // Release reset
    #10;

  // Test addition
   for (i = 0; i < 6; i = i + 1) begin 
    {tb_a, tb_b, tb_add_sub, expected_carry_flag, expected_zero_flag, expected_result} = test_vectors[i]; // Split the test vector into inputs and expected output

    tb_en_a = 1; // Enable loading of a
    tb_en_b = 1; // Enable loading of b

    @ (posedge tb_clk); // Wait for the positive edge of the clock to ensure that the inputs are registered in the ALU before checking the output

    tb_en_res = 1; // Enable output of result
    tb_a_out = 1; // Enable output of a_result to observe the value of a being captured and output by the ALU

    #2; // Wait for a short time after the clock edge to allow the outputs to stabilize before checking them
   
   if ((tb_result !== expected_result) || (tb_carry_flag !== expected_carry_flag) || (tb_zero_flag !== expected_zero_flag)) begin 
      $display("Test Case %d failed: a = %b, b = %b, add_sub = %b, tb_carry_flag = %b, tb_zero_flag = %b, expected_carry_flag = %b, expected_zero_flag = %b, Expected Result = %b, Actual Result = %b", i, tb_a, tb_b, tb_add_sub, tb_carry_flag, tb_zero_flag, expected_carry_flag, expected_zero_flag, expected_result, tb_result);
    end else begin 
      $display("Test Case %d passed: a = %b, b = %b, add_sub = %b, Result = %b", i, tb_a, tb_b, tb_add_sub, tb_result);
    end

    if (tb_a_result !== tb_a) begin
       $display("Test failed: a_result should match a when en_a is 1 and a_out is 1"); 
       end 
       else begin 
        $display("a_result correctly matches a: %b", tb_a_result);
         end

    #3; // Wait for a short time to test register "holding" power
    tb_en_a = 0; // Disable loading of a for the next test case
    tb_en_b = 0; // Disable loading of b for the next test case
    tb_en_res = 0; // Disable output of result for the next test case
    tb_a_out = 0; // Disable output of a_result for the next test case
   end
    $display("All test cases completed");
    $finish;
   end
 endmodule