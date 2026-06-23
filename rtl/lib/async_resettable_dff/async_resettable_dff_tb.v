`timescale 1ns/1ps

module async_resettable_dff_tb();
parameter W = 1;
reg tb_clk;
reg tb_reset;
reg [W-1:0] tb_d;
wire [W-1:0] tb_q;

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk; // Toggle the clock every 5 time units, creating a clock period of 10 time units.

async_resettable_dff #(.WIDTH(W)) dut (.clk(tb_clk), .d(tb_d), .q(tb_q), .reset(tb_reset)); // Instantiate the D flip-flop module, connecting the testbench signals to the module's ports.

initial begin 
  $dumpfile("sim/async_resettable_dff/async_resettable_dff.vcd");
  $dumpvars(0, async_resettable_dff_tb);

  tb_d = 0;
  tb_reset = 1;
  #10; // Wait for 10 time units to allow the reset to take effect.
  tb_reset = 0; // Deassert the reset signal.

   @ (negedge tb_clk) tb_d = 1; // On the falling edge of the clock, set tb_d to 1. This will cause the D flip-flop to capture the value of 1 on the next rising edge of the clock.
   @ (posedge tb_clk) #1;
  if (tb_q !== 1) $display("Test failed: tb_q should be 1 after the rising edge of the clock when tb_d is 1");

  @ (negedge tb_clk) tb_d = 0; // On the falling edge of the clock, set tb_d to 0. This will cause the D flip-flop to capture the value of 0 on the next rising edge of the clock.
  @ (posedge tb_clk) #1;
  if (tb_q !== 0) $display("Test failed: tb_q should be 0 after the rising edge of the clock when tb_d is 0");
  $finish;
end
endmodule