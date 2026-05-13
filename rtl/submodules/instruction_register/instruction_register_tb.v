module instruction_register_tb();
parameter W = 8;

reg [W-1:0] tb_d;
wire [W-1:0] tb_q;
reg tb_en_load;
reg tb_reset;
reg tb_clk;
reg [15:0] test_vectors [0:5];
reg [W-1:0] expected_d;
reg [W-1:0] expected_q;

initial tb_clk = 0; // Initialize the clock signal to 0
always #5 tb_clk = ~tb_clk; // Generate a clock signal with a period of 10 time units

instruction_register #(.WIDTH(W)) dut (.clk(tb_clk), .en_load(tb_en_load), .reset_sig(tb_reset), .d(tb_d), .instruction_q(tb_q));

integer i; // Declare an integer variable for use as a loop counter in the testbench
initial begin 
  $dumpfile("sim/instruction_register/instruction_register.vcd");
  $dumpvars(0, instruction_register_tb);
  $readmemb("rtl/submodules/instruction_register/instruction_register.tv", test_vectors); // Load test data from a memory file into the test_vectors array

   i = 0; // Initialize the loop counter to 0
   tb_en_load  = 0; // Initialize the enable load signal to 0
   tb_d = {W{1'b0}}; // Initialize the data input to 0
   expected_q = {W{1'b0}}; // Initialize the expected output to 0
   tb_reset = 1; // Assert the reset signal to initialize the instruction register
    #10; // Wait for 10 time units to allow the DUT to process the reset signal
   tb_reset = 0;
   #5; // Wait for 5 time units to ensure the reset signal is deasserted before starting the test

 for (i = 0; i < 6; i = i+ 1) begin 
  {tb_d, expected_q} = test_vectors[i]; // Assign the test vector values to the input signals and expected output
    tb_en_load = 1; // Assert the enable load signal to load the instruction into the register
    #1; // Wait for 1 time units to allow the DUT to process the input data and load it into the register
    @ (posedge tb_clk); // Wait for the positive edge of the clock to ensure that the instruction is loaded into the register before checking the output

   if (tb_q !== expected_q) $display("Test failed for input %b: expected %b, got %b", tb_d, expected_q, tb_q); // Check if the output matches the expected value and display an error message if it does not.
   else $display("Test passed for input %b: expected %b, got %b", tb_d, expected_q, tb_q); // Display a success message if the output matches the expected value.
    
   tb_en_load = 0; // Deassert the enable load signal to test that the instruction register holds its value when not enabled
    #10; // Wait for 10 time units to allow the DUT to process the change in the enable signal
 end
   $display("All tests completed"); // Display a message indicating that all tests have been completed
   $finish; // Terminate the simulation
end
endmodule