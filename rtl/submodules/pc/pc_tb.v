`timescale 1ns/1ps

module pc_tb();
parameter W = 4;

// hardcoded b to 1
parameter [0:0] b0 = 1'b1;
parameter [0:0] b1 = 1'b0;
parameter [0:0] b2 = 1'b0;
parameter [0:0] b3 = 1'b0;

reg [W-1:0] tb_a;
reg tb_clk, tb_reset, tb_add_sub, tb_en_pc_in, tb_en_pc_reg, tb_en_pc_out;
wire [W-1:0] tb_pc_q;

reg [8:0] test_vectors [0:3];
reg [W-1:0] expected_q;

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk;

pc #(.WIDTH(W)) dut (.a(tb_a), .b({b3, b2, b1, b0}), .clk(tb_clk), .reset_sig(tb_reset), .add_sub(tb_add_sub), .en_pc_in(tb_en_pc_in), .en_pc_reg(tb_en_pc_reg), .en_pc_out(tb_en_pc_out), .pc_q(tb_pc_q));

integer i;
initial begin 
  $dumpfile("sim/pc/pc.vcd");
  $dumpvars(0, pc_tb);
  $readmemb("rtl/submodules/pc/pc.tv", test_vectors);

   i = 0;
   tb_a = {W{1'b0}};
   expected_q ={W{1'b0}};
   tb_add_sub = 0;
   tb_en_pc_in = 0;
   tb_en_pc_reg = 0;
   tb_en_pc_out = 0;
   tb_reset = 1;
   repeat (2) @ (posedge tb_clk);
   #1; tb_reset = 0;

   for (i = 0; i < 4; i = i + 1) begin 
       {tb_a, tb_en_pc_in, expected_q} = test_vectors[i];
          
        #1;
         tb_en_pc_reg = 1;
         tb_en_pc_out = 1;

         @ (posedge tb_clk);
         #1;

         if (tb_pc_q !== expected_q) begin 
          $display("Test %0d failed: tb_a = %b Expected q = %b Actual q = %b", i, tb_a, expected_q, tb_pc_q);  
         end else begin
         $display("Test %0d passed: tb_a = %b Expected q = %b Actual q = %b", i, tb_a, expected_q, tb_pc_q);
         end

         tb_en_pc_reg = 0;
         tb_en_pc_out = 0;
         @ (posedge tb_clk);
   end

  $display("All test completed");
  $finish;
end

endmodule