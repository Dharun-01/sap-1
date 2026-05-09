module tristate_buff_tb();
parameter W = 1;
reg [W-1:0] tb_a;
reg tb_en;
wire [W-1:0] tb_y;

tristate_buff_n #(.WIDTH(W)) dut (.en(tb_en), .a(tb_a), .y(tb_y));

initial begin 
  $dumpfile("sim/tristate_buffer/tristate_buff.vcd");
  $dumpvars(0, tristate_buff_tb);
  tb_a = 0; tb_en = 0; #10;
  if (tb_y !== {W{1'bz}}) $display("tb_a_0 failed because en was 0");
  tb_a = 0; tb_en = 1; #10;
  if (tb_y !== 0) $display("tb_a_0 failed because en was 1");
  tb_a = 1; tb_en = 0; #10;
  if (tb_y !== {W{1'bz}}) $display("tb_a_1 failed because en was 0");
  tb_a = 1; tb_en = 1; #10;
  if (tb_y !== 1) $display("tb_a_1 failed because en was 1");
end 
endmodule 