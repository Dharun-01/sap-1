`timescale 1ns/1ps
module mux_tb();
parameter W = 2;
reg [W-1:0] tb_d1, tb_d0;
reg tb_sel;
wire [W-1:0] tb_y;

mux #(.WIDTH(W)) dut (.d0(tb_d0), .d1(tb_d1), .sel(tb_sel), .y(tb_y)); // instantiate the mux module with the parameter WIDTH set to W, and connect the inputs and outputs to the testbench variables

initial begin 
  $dumpfile("sim/mux/mux.vcd");
  $dumpvars(0, mux_tb); // dump all the variables in the mux_tb module into the VCD file so we can see the waveforms for d1, d0, sel, and y in the waveform viewer
  tb_d1 = 2'b11; tb_d0 = 2'b00; tb_sel = 0; #10;
  if (tb_y !== 2'b00) $display("00 failed");
  tb_sel = 1; #10;
  if (tb_y !== 2'b11) $display("01 failed");
  tb_d1 = 2'b10; tb_d0 = 2'b01; tb_sel = 0; #10;
  if (tb_y !== 2'b01) $display("10 failed");  
  tb_sel = 1; #10;
  if (tb_y !== 2'b10) $display("11 failed");  
  $finish;
end
endmodule