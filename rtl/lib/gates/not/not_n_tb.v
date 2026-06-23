`timescale 1ns/1ps

module not_n_tb();
parameter W = 2;
reg [W-1:0] tb_a;
wire [W-1:0] tb_y;

not_n #(.WIDTH(W)) dut (.a(tb_a), .y(tb_y));

initial begin 
  $dumpfile("sim/not/not_n.vcd");
  $dumpvars(0, not_n_tb); // dump all the variables in the not_n module into the VCD file so we can see the waveforms for a and y in the waveform viewer
  tb_a = 2'b00; #10;
  if (tb_y !== 2'b11) $display("00 failed");
  tb_a = 2'b01; #10;
  if (tb_y !== 2'b10) $display("01 failed");
  tb_a = 2'b10; #10;
  if (tb_y !== 2'b01) $display("10 failed");
  tb_a = 2'b11; #10;
  if (tb_y !== 2'b00) $display("11 failed");
  $finish;
end
endmodule 