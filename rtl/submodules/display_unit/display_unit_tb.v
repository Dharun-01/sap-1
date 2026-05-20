module display_unit_tb();
parameter D_W = 8;

reg [D_W-1:0] tb_data_in;
reg tb_en_out_in;
reg tb_clk;
reg tb_reset;

wire tb_a1;
wire tb_b1;
wire tb_c1;
wire tb_d1;
wire tb_e1;
wire tb_f1;
wire tb_g1;

wire tb_a2;
wire tb_b2;
wire tb_c2;
wire tb_d2;
wire tb_e2;
wire tb_f2;
wire tb_g2;

wire [13:0] actual_ctrl_word = {
tb_a1,        tb_b1,        tb_c1,        tb_d1,        tb_e1,        tb_f1,        tb_g1,
tb_a2,        tb_b2,        tb_c2,        tb_d2,        tb_e2,        tb_f2,        tb_g2
};

reg [23:0] test_vectors [0:9];
reg [13:0] expected_ctrl_word;

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk;

display_unit #(.D_WIDTH(D_W)) dut (
  .clk(tb_clk), 
  .reset_sig(tb_reset), 
  .data_in(tb_data_in), 
  .en_out_in(tb_en_out_in), 
  
  .a1(tb_a1),
  .b1(tb_b1),
  .c1(tb_c1),
  .d1(tb_d1),
  .e1(tb_e1),
  .f1(tb_f1),
  .g1(tb_g1),

  .a2(tb_a2),
  .b2(tb_b2),
  .c2(tb_c2),
  .d2(tb_d2),
  .e2(tb_e2),
  .f2(tb_f2),
  .g2(tb_g2)
  );

integer i;
initial begin 
  $dumpfile("sim/display_unit/display_unit.vcd");
  $dumpvars(0, display_unit_tb);

  $readmemb("rtl/submodules/display_unit/display_unit.tv", test_vectors);
   
   $display("------------------------------------------");
   $display("Starting SAP-1 Display Unit Verification");

  // Initialize 
    i = 0;
   for (i = 0; i < 10; i = i + 1) begin 
     @ (negedge tb_clk);
     tb_reset           = test_vectors[i][23];
     tb_data_in         = test_vectors[i][22:15];
     tb_en_out_in       = test_vectors[i][14];
     expected_ctrl_word = test_vectors[i][13:0];
     
      @ (posedge tb_clk);
      #2;
      
     if (actual_ctrl_word !== expected_ctrl_word) begin 
       $display("Test %0d FAILED: reset = %b, data_in = %b, en_out_in = %b, expected_word  = %b, actual_word = %b", i, tb_reset, tb_data_in, tb_en_out_in, expected_ctrl_word, actual_ctrl_word);
     end else begin 
       $display("Test %0d PASSED: reset = %b, data_in = %b, en_out_in = %b, expected_word  = %b, actual_word = %b", i, tb_reset, tb_data_in, tb_en_out_in, expected_ctrl_word, actual_ctrl_word);
     end
   end
    $display("Verification Complete");
    $finish;
end

endmodule 