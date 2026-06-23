`timescale 1ns / 1ps

module fetch_phase_tb();
parameter DATA_W = 8;
parameter ADDR_W = 4;

reg tb_clk;
reg tb_reset_sig;
reg tb_fet_add_sub;
reg tb_fet_en_pc_in;
reg tb_fet_en_pc_reg;
reg tb_fet_en_pc_out;

reg tb_fet_en_ras;

reg [ADDR_W-1:0] tb_fet_manual_addr;
reg [DATA_W-1:0] tb_fet_manual_data;
reg tb_fet_en_data_mode_switcher;
reg tb_fet_en_addr_mode_switcher;
reg tb_fet_en_ram_in;
reg tb_fet_en_ram_out;
reg tb_fet_en_manual_ram_in;
reg tb_fet_ram_in_control_line;

reg [29:0] test_vectors [0:32];
reg [DATA_W-1:0] expected_out_view_bus;

wire [DATA_W-1:0] tb_fet_out_view_bus;
wire [ADDR_W-1:0] tb_fet_pc_q;
wire [ADDR_W-1:0] tb_fet_ras_q;
wire [DATA_W-1:0] tb_fet_ram_y;

fetch_phase #(.DATA_WIDTH(DATA_W), .ADDR_WIDTH(ADDR_W)) fetch_phase_inst (
  .clk(tb_clk), 
  .reset_sig(tb_reset_sig), 
  .fet_add_sub(tb_fet_add_sub), 
  .fet_en_pc_in(tb_fet_en_pc_in), 
  .fet_en_pc_reg(tb_fet_en_pc_reg), 
  .fet_en_pc_out(tb_fet_en_pc_out),  
  .fet_en_ras(tb_fet_en_ras),
  .fet_manual_addr(tb_fet_manual_addr), 
  .fet_manual_data(tb_fet_manual_data), 
  .fet_en_data_mode_switcher(tb_fet_en_data_mode_switcher), 
  .fet_en_addr_mode_switcher(tb_fet_en_addr_mode_switcher), 
  .fet_en_ram_in(tb_fet_en_ram_in), 
  .fet_en_manual_ram_in(tb_fet_en_manual_ram_in), 
  .fet_ram_in_control_line(tb_fet_ram_in_control_line),
  .fet_en_ram_out(tb_fet_en_ram_out),
  .fet_pc_q(tb_fet_pc_q),
  .fet_ras_q(tb_fet_ras_q),
  .fet_ram_y(tb_fet_ram_y),
  .fet_out_view_bus(tb_fet_out_view_bus)
);

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk; // 10 time units clock period

integer vector_idx = 0;

initial begin 
  $dumpfile("sim/fetch_phase/fetch_phase.vcd");
  $dumpvars(0, fetch_phase_tb);

  $readmemb("rtl/subsystems_tests/fetch_phase/fetch_phase.tv", test_vectors);

  // Initialize inputs
  tb_reset_sig                 = 0;
  tb_fet_add_sub               = 0;
  tb_fet_en_pc_in              = 0;
  tb_fet_en_pc_reg             = 0;
  tb_fet_en_ras                = 0;
  tb_fet_manual_addr           = 0;
  tb_fet_manual_data           = 0;
  tb_fet_en_data_mode_switcher = 0;
  tb_fet_en_addr_mode_switcher = 0;
  tb_fet_en_ram_in             = 0;
  tb_fet_en_manual_ram_in      = 0;
  tb_fet_ram_in_control_line   = 0;
  tb_fet_en_pc_out             = 0;
  tb_fet_en_ram_out            = 0;

  // Run through all defined vectors until we hit undefined memory ('x')
  while (test_vectors[vector_idx] !== 30'bx) begin
    
    // Apply inputs on falling edge to avoid race conditions
    @ (negedge tb_clk);
    {
      tb_reset_sig,
      tb_fet_en_pc_in,
      tb_fet_en_pc_reg,
      tb_fet_en_pc_out,
      tb_fet_en_ras,
      tb_fet_en_ram_out,           
      tb_fet_en_addr_mode_switcher,
      tb_fet_en_data_mode_switcher,
      tb_fet_ram_in_control_line,
      tb_fet_en_manual_ram_in,
      tb_fet_manual_addr,
      tb_fet_manual_data,
      expected_out_view_bus
    } = test_vectors[vector_idx];

    // Wait for the clock to rise and outputs to stabilize
    @ (posedge tb_clk);
    // Add a tiny delay to allow combinational logic (bus drivers) to settle
    #1; 

    // Validate the output on every single step
    if (tb_fet_out_view_bus !== expected_out_view_bus) begin
      $display("FAIL at vector %0d: Expected = %b, Got = %b", vector_idx, expected_out_view_bus, tb_fet_out_view_bus);
    end else begin
      $display("PASS at vector %0d: Bus = %b", vector_idx, tb_fet_out_view_bus);
    end

    vector_idx = vector_idx + 1;
  end

  $display("Simulation complete. Executed %0d vectors.", vector_idx);
  $finish;
end
endmodule