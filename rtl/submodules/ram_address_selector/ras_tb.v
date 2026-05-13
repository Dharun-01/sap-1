module ras_tb();
parameter W = 4;

reg [W-1:0] tb_addr;
reg tb_clk;
reg tb_reset;
reg tb_en_ras;
wire [W-1:0] tb_ras_q;

reg [7:0] test_vectors [0:4];
reg [W-1:0] expected_q;

ras #(.WIDTH(W)) dut (.addr(tb_addr), .clk(tb_clk), .reset_sig(tb_reset), .en_ras(tb_en_ras), .ras_q(tb_ras_q));

initial tb_clk = 0; // Initialize the clock signal to 0
always #5 tb_clk = ~tb_clk; // Generate a clock signal with a period of 10 time units
integer i; // Declare an integer variable for use as a loop counter in the testbench

initial begin 
  $dumpfile("sim/ram_address_selector/ras.vcd");
  $dumpvars(0, ras_tb);
  $readmemb("rtl/submodules/ram_address_selector/ras.tv", test_vectors); // Load test data from a memory file into the test_vectors array

   i = 0; // Initialize the loop counter to 0
   tb_en_ras = 0; // Initialize the enable signal to 0
   tb_addr = {W{1'b0}}; // Initialize the address input to 0
   expected_q = {W{1'b0}}; // Initialize the expected output to 0
   tb_reset = 1; // Assert the reset signal to initialize the RAM address selector register
    #10; // Wait for 10 time units to allow the DUT to process the reset signal
   tb_reset = 0;
   #5; // Wait for 5 time units to ensure the reset signal is deasserted before starting the test

   for (i = 0; i < 5; i = i + 1) begin 
    {tb_addr, expected_q} = test_vectors[i]; // Assign the test vector values to the input signals and expected output

     tb_en_ras = 1; // Assert the enable signal to load the address into the RAM address selector register
     #1;
    @ (posedge tb_clk); // Wait for the positive edge of the clock to ensure that the inputs are registered in the RAM address selector before checking the output
  
    if (tb_ras_q !== expected_q) $display("Test failed for input %b: expected %b, got %b", tb_addr, expected_q, tb_ras_q); // Check if the output matches the expected value and display an error message if it does not.
    else $display("Test passed for input %b: expected %b, got %b", tb_addr, expected_q, tb_ras_q); // Display a success message if the output matches the expected value.
     
     tb_en_ras = 0;
     #10; // Wait for 10 time units to allow the DUT to process the change in the enable signal and test that the RAM address selector register holds its value when not enabled
      if (tb_ras_q !== expected_q) $display("Hold test failed for input %b: expected %b, got %b", tb_addr, expected_q, tb_ras_q); // Check if the output matches the expected value and display an error message if it does not.
   end
    $display("All tests completed"); // Display a message indicating that all tests have been completed
    $finish; // Terminate the simulation
end
endmodule 