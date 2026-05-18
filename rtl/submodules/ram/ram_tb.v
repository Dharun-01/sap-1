module ram_tb();
parameter ADDR_W = 4;
parameter DATA_W = 8;

reg [ADDR_W-1:0] tb_addr;
reg [ADDR_W-1:0] tb_manual_addr;
reg [DATA_W-1:0] tb_data;
reg [DATA_W-1:0] tb_manual_data;

reg tb_clk;
reg tb_en_data_mode_switcher; 
reg tb_en_addr_mode_switcher;
reg tb_en_ram_in;
reg tb_en_ram_out;
reg tb_step_1;
reg tb_en_manual_ram_in;
reg tb_ram_in_control_line;

reg [36:0] test_vectors [0:6];
reg [DATA_W-1:0] expected_y;
wire [DATA_W-1:0] tb_ram_y;

ram #(.ADDR_WIDTH(ADDR_W), .DATA_WIDTH(DATA_W)) dut (
  .addr(tb_addr), 
  .manual_addr(tb_manual_addr), 
  .data(tb_data), 
  .manual_data(tb_manual_data), 
  .clk(tb_clk), 
  .en_data_mode_switcher(tb_en_data_mode_switcher), 
  .en_addr_mode_switcher(tb_en_addr_mode_switcher),
  .en_ram_in(tb_en_ram_in),
  .en_ram_out(tb_en_ram_out),
  .step_1(tb_step_1),
  .en_manual_ram_in(tb_en_manual_ram_in),
  .ram_in_control_line(tb_ram_in_control_line),
  .ram_y(tb_ram_y)
  );

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk;

integer i;
initial begin 
 $dumpfile("sim/ram/ram.vcd");
 $dumpvars(0, ram_tb);

 $readmemb("rtl/submodules/ram/ram.tv", test_vectors);
 
 for (i = 0; i < 7; i = i + 1) begin 
  @ (negedge tb_clk); 

 // Explicitly slicing the 37-bit vector to prevent assignment race conditions
    tb_manual_addr            = test_vectors[i][36:33];
    tb_manual_data            = test_vectors[i][32:25];
    tb_addr                   = test_vectors[i][24:21];
    tb_data                   = test_vectors[i][20:13];
    
    tb_en_addr_mode_switcher  = test_vectors[i][12];
    tb_en_data_mode_switcher  = test_vectors[i][11];
    tb_ram_in_control_line    = test_vectors[i][10];
    tb_en_manual_ram_in       = test_vectors[i][9];
    tb_en_ram_in              = test_vectors[i][8];
    
    expected_y                = test_vectors[i][7:0];
   
   // Assign read controls based on expected outputs
        if (expected_y === 8'bZZZZZZZZ) begin
            tb_en_ram_out = 1'b0;
            tb_step_1     = 1'b0;
        end else begin
            tb_en_ram_out = 1'b1; // Turn on tri-states during verification reads
            tb_step_1     = 1'b0;
        end
        // 2. Wait for the Rising Edge where values latch, then evaluate output
        @(posedge tb_clk);
        #2; // Small delay to allow combinatorial signals to settle
        
        if (tb_ram_y !== expected_y) begin
            $display("ERROR at vector %0d! Expected: %h, Got: %h", i, expected_y, tb_ram_y);
        end else begin
            $display("Vector %0d Passed successfully. Output: %h", i, tb_ram_y);
        end
    end
    $display("RAM Testing complete.");
    $finish;
end
  
endmodule 