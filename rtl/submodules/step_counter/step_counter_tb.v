`timescale 1ns/1ps

module step_counter_tb();
parameter W = 3;
parameter [W-1:0] tb_b = 3'b001;

reg tb_reset, tb_clk;

wire [W-1:0] tb_internal_result;

reg [2:0] test_vectors [0:6];
reg [W-1:0] expected_q;

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk;

integer i;

step_counter #(.WIDTH(W)) dut (.reset_sig(tb_reset), .clk(tb_clk), .b(tb_b), .internal_result(tb_internal_result));

initial begin 
  $dumpfile("sim/step_counter/step_counter.vcd");
  $dumpvars(0, step_counter_tb);
  $readmemb("rtl/submodules/step_counter/step_counter.tv", test_vectors);
  
   i = 0; 
   expected_q = {W{1'b0}};
   tb_reset = 1;
   repeat (2) @ (posedge tb_clk);
   #1;  
   tb_reset = 0;

   for (i = 0; i < 7; i = i + 1) begin 
    {expected_q} = test_vectors[i];
     
     // Wait for the active falling edge where the DUT actually changes
        @(negedge tb_clk);
        
        // Allow 1ns for the gate outputs to settle down cleanly
        #1;
        
     if (tb_internal_result !== expected_q) begin 
      $display("Test %0d FAILED: Expected q = %b, Actual result = %b", i, expected_q, tb_internal_result);
     end else begin 
      $display("Test %0d PASSED: Expected q = %b, Actual result = %b", i, expected_q, tb_internal_result);
     end
   end
   $display("All tests completed");
   $finish;
end
endmodule