`timescale 1ns/1ps

module execution_phase_tb();
parameter OPCODE_WIDTH = 4;
parameter STEP_WIDTH   = 3;
parameter FLAG_WIDTH   = 2;
parameter WORD_WIDTH   = 8;
parameter ADDR_WIDTH   = 4;

reg tb_clk;
reg tb_en_clk;
reg tb_reset_sig;
reg tb_exec_carry_out;
reg tb_exec_zero_out;
reg [OPCODE_WIDTH-1:0] tb_exec_opcode;
reg [STEP_WIDTH-1:0] tb_exec_step_out;
reg [ADDR_WIDTH-1:0] tb_exec_man_address;
reg [WORD_WIDTH-1:0] tb_exec_man_data;
reg tb_exec_man_data_mode_switch;
reg tb_exec_man_addr_mode_switch;
reg tb_exec_man_ram_in;
reg tb_exec_man_ram_in_control_line;

reg [OPCODE_WIDTH-1:0] tmp_opcode;
reg [STEP_WIDTH-1:0] tmp_step_out;
reg tmp_exec_carry_out;
reg tmp_exec_zero_out;
reg tmp_man_ram_in;

reg [50:0] test_vectors [0:49];
reg [15:0] expected_ctrl_word;
reg [7:0]  expected_out_view_bus;

wire [WORD_WIDTH-1:0] tb_exec_out_view_bus;
wire tb_exec_en_ir_out;
wire tb_exec_en_ir_in;
wire tb_exec_en_ras_in;
wire tb_exec_en_a_in;
wire tb_exec_en_ram_out;
wire tb_exec_en_a_out;
wire tb_exec_en_b_in;
wire tb_exec_en_pc_in;
wire tb_exec_en_pc_out;
wire tb_exec_en_ram_in;
wire tb_exec_en_add_sub;
wire tb_exec_en_hlt;
wire tb_exec_en_alu_out;
wire tb_exec_en_out_in;
wire tb_exec_en_pc_latcher;
wire tb_exec_en_reset_step_counter;

wire [15:0] actual_ctrl_word = {
tb_exec_en_ir_out,
tb_exec_en_ir_in,
tb_exec_en_ras_in,
tb_exec_en_a_in,
tb_exec_en_ram_out,
tb_exec_en_a_out,
tb_exec_en_b_in,
tb_exec_en_pc_in,
tb_exec_en_pc_out,
tb_exec_en_ram_in,
tb_exec_en_add_sub,
tb_exec_en_hlt,
tb_exec_en_alu_out,
tb_exec_en_out_in,
tb_exec_en_pc_latcher,
tb_exec_en_reset_step_counter
};

execution_phase #(
  .OPCODE_WIDTH(OPCODE_WIDTH),
  .FLAG_WIDTH(FLAG_WIDTH), 
  .STEP_WIDTH(STEP_WIDTH), 
  .WORD_WIDTH(WORD_WIDTH),
  .ADDRESS_WIDTH(ADDR_WIDTH)
) dut (
   .exec_carry_out(tb_exec_carry_out),
   .exec_zero_out(tb_exec_zero_out),
   .exec_opcode(tb_exec_opcode),
   .exec_step_out(tb_exec_step_out),
   .clk(tb_clk),
   .en_clk(tb_en_clk),
   .reset_sig(tb_reset_sig),
   .exec_man_address(tb_exec_man_address),
   .exec_man_data(tb_exec_man_data),
   .exec_man_data_mode_switch(tb_exec_man_data_mode_switch),
   .exec_man_addr_mode_switch(tb_exec_man_addr_mode_switch),
   .exec_man_ram_in(tb_exec_man_ram_in),
   .exec_man_ram_in_control_line(tb_exec_man_ram_in_control_line),

   .exec_out_view_bus(tb_exec_out_view_bus),
   .exec_en_ir_out(tb_exec_en_ir_out),
   .exec_en_ir_in(tb_exec_en_ir_in),
   .exec_en_ras_in(tb_exec_en_ras_in),
   .exec_en_a_in(tb_exec_en_a_in),
   .exec_en_ram_out(tb_exec_en_ram_out),
   .exec_en_a_out(tb_exec_en_a_out),
   .exec_en_b_in(tb_exec_en_b_in),
   .exec_en_pc_in(tb_exec_en_pc_in),
   .exec_en_pc_out(tb_exec_en_pc_out),
   .exec_en_ram_in(tb_exec_en_ram_in),
   .exec_en_add_sub(tb_exec_en_add_sub),
   .exec_en_hlt(tb_exec_en_hlt),
   .exec_en_alu_out(tb_exec_en_alu_out),
   .exec_en_out_in(tb_exec_en_out_in),
   .exec_en_pc_latcher(tb_exec_en_pc_latcher),
   .exec_en_reset_step_counter(tb_exec_en_reset_step_counter)
  );

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk;

integer vector_index;
integer execution_cycles;

initial begin 
  vector_index = 0;
  execution_cycles = 28;
  expected_out_view_bus = 8'h00; // Force out the 'x' state before the loop checks it!
  
  tb_reset_sig = 1'b0;
  tb_en_clk = 1'b0;
  tb_exec_man_addr_mode_switch = 1'b0;
  tb_exec_man_data_mode_switch = 1'b0;
  tb_exec_man_ram_in_control_line = 1'b0;
  tb_exec_man_ram_in = 1'b0;
  tb_exec_man_address = 4'b0000;
  tb_exec_man_data = 8'b00000000;
  tb_exec_carry_out = 1'b0;
  tb_exec_zero_out = 1'b0;

  $dumpfile("sim/execution_phase/execution_phase.vcd");
  $dumpvars(0, execution_phase_tb);
  
  $readmemb("rtl/subsystems_tests/execution_phase/execution_phase.tv", test_vectors);

  $display("START OF MANUAL PROGRAMMING PHASE");
  $display("=================================");                                
while(test_vectors[vector_index][49] === 1'b0) begin 
 @ (negedge tb_clk);

 {
  tb_reset_sig,
  tb_en_clk,
  tb_exec_man_addr_mode_switch,
  tb_exec_man_data_mode_switch,
  tmp_man_ram_in,
  tb_exec_man_ram_in_control_line,
  tmp_exec_carry_out,
  tmp_exec_zero_out,
  tb_exec_man_address,
  tb_exec_man_data,
  tmp_opcode,
  tmp_step_out,
  expected_ctrl_word,
  expected_out_view_bus
 } = test_vectors[vector_index];
 
 #1;
 tb_exec_man_ram_in = tmp_man_ram_in;
 #1;

 if (expected_out_view_bus !== tb_exec_out_view_bus) begin 
  $display("Out View Bus Test vector %d FAILED!, Expected View Bus = %b Actual View Bus = %b", vector_index, expected_out_view_bus, tb_exec_out_view_bus);
 end else begin 
  $display("Out View Bus Test Vector %d PASSED!, Expected View Bus = %b and Actual View Bus = %b matched!", vector_index, expected_out_view_bus, tb_exec_out_view_bus);
 end

 if (expected_ctrl_word !== actual_ctrl_word) begin 
     $display("Control Word Test %d FAILED!, Expected Control Word = %b, Actual Control Word = %b", vector_index, expected_ctrl_word, actual_ctrl_word);
 end else begin 
     $display("Control Word Test %d PASSED!, Expected Control Word = %b Actual Control Word = %b matched!", vector_index, expected_ctrl_word, actual_ctrl_word);
 end
 vector_index = vector_index + 1; 
end
  $display("END OF MANUAL PROGRAMMING PHASE");
  $display("================================");

  tb_exec_man_addr_mode_switch = 1'b0;
  tb_exec_man_data_mode_switch = 1'b0;
  tb_exec_man_ram_in_control_line = 1'b0;
  tb_exec_man_ram_in = 1'b0;
  tb_exec_man_address = 4'b0000;
  tb_exec_man_data = 8'b00000000;
  
  #20;

  $display("START OF EXECUTION PHASE");
  $display("========================");

 while (execution_cycles < 50) begin 
   @ (negedge tb_clk);
    {
  tb_reset_sig,
  tb_en_clk,
  tb_exec_man_addr_mode_switch,
  tb_exec_man_data_mode_switch,
  tb_exec_man_ram_in,
  tb_exec_man_ram_in_control_line,
  tb_exec_carry_out,
  tb_exec_zero_out,
  tb_exec_man_address,
  tb_exec_man_data,
  tb_exec_opcode,
  tb_exec_step_out,
  expected_ctrl_word,
  expected_out_view_bus
 } = test_vectors[execution_cycles];
         #2;

    if (expected_out_view_bus !== tb_exec_out_view_bus || expected_ctrl_word !== actual_ctrl_word)  begin 
        $display("Time %t Execution Cycle %d FAILED! Expected Out View Bus = %b Actual Out View Bus = %b Expected Control Word = %b Actual Control Word = %b", $time, execution_cycles, expected_out_view_bus, tb_exec_out_view_bus, expected_ctrl_word, actual_ctrl_word);
    end else begin 
      $display("Time %t Execution Cycle %d PASSED! Expected Out View Bus = %b Actual Out View Bus = %b Expected Control Word = %b Actual Control Word = %b", $time, execution_cycles, expected_out_view_bus, tb_exec_out_view_bus, expected_ctrl_word, actual_ctrl_word);
    end
    execution_cycles = execution_cycles + 1;
 end
 $display("END OF EXECUTION PHASE");
 $display("======================");
 $finish;
end
endmodule
 