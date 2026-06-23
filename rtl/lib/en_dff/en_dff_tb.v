`timescale 1ns/1ps

module en_dff_tb();
parameter W = 1;
reg tb_clk;
reg tb_en;
reg tb_reset;
reg [W-1:0] tb_d;
wire [W-1:0] tb_q;

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk;

en_dff #(.WIDTH(W)) dut (.clk(tb_clk), .reset(tb_reset), .en(tb_en), .d(tb_d), .q(tb_q));

initial begin 
  $dumpfile("sim/en_dff/en_dff.vcd");
  $dumpvars(0, en_dff_tb);

    tb_d = 0;
    tb_en = 0;
    tb_reset = 1;
    #10;
    tb_reset = 0;

    @ (negedge tb_clk) begin 
     tb_en = 1;
     tb_d = 1;
    end 
    @ (posedge tb_clk) #1;
     if (tb_q !== 1) $display("Test case 1: failed (because tb_q should be 0 when)");

    @ (negedge tb_clk) begin 
      tb_en = 0;
      tb_d = 0;
     end
    @ (posedge tb_clk) #1;
     if (tb_q !== 1) $display ("Test Case 2: failed (because previous value of tb_q was 1 now since en is 0 tb_d = 0 should not be sampled and the tb_q should stay as 1)");
     $finish;
end

endmodule