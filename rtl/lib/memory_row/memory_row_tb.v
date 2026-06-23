`timescale 1ns/1ps

module memory_row_tb();
parameter D = 8;

reg tb_clk;
reg tb_reset_sig;
reg tb_decoder_output_line;
reg tb_ram_in_sel;
reg [D-1:0] tb_data_in;
reg [15:0] test_vectors [0:3];

reg [D-1:0] expected_y;
wire [D-1:0] tb_mem_row_y;

memory_row #(.DATA_W(D)) dut (
  .clk(tb_clk), 
  .reset_sig(tb_reset_sig), 
  .decoder_output_line(tb_decoder_output_line), 
  .ram_in_sel(tb_ram_in_sel), 
  .data_in(tb_data_in), 
  .mem_row_y(tb_mem_row_y)
);

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk; // 10ns clock period
integer i;  
initial begin 
 $dumpfile("sim/memory_row/memory_row.vcd");
 $dumpvars(0, memory_row_tb);
 $readmemb("rtl/lib/memory_row/memory_row.tv", test_vectors);

  // initial value when the simulation starts
   tb_decoder_output_line = 0;
   expected_y = {D{1'b0}};
   tb_ram_in_sel = 0;
   tb_reset_sig = 1;
    #10; // Wait for 10ns to ensure reset is applied
    tb_reset_sig = 0; // Deassert reset after 10ns
    
 for (i = 0; i < 4; i = i + 1) begin 
   
   {tb_data_in, expected_y} = test_vectors[i];
    
    #1; // Setup time 
    tb_decoder_output_line = 1;
    tb_ram_in_sel = 1;
    #9;
    
    if (expected_y !== tb_mem_row_y) begin 
      $display("Test %0d Failed: Expected y = %b, Actual y = %b", i, expected_y, tb_mem_row_y);
    end else begin 
      $display("Test %0d Passed: Expected y = %b, Actual y = %b", i, expected_y, tb_mem_row_y);
    end

    tb_decoder_output_line = 0;
    tb_ram_in_sel = 0;
    #10;
 end
 $display("All Test cases completed.");
 $finish;
end
endmodule 