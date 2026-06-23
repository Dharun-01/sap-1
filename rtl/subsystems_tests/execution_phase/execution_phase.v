`timescale 1ns/1ps

module execution_phase #(
  parameter OPCODE_WIDTH = 4, 
  parameter STEP_WIDTH = 3, 
  parameter FLAG_WIDTH = 2, 
  parameter WORD_WIDTH = 8,
  parameter ADDRESS_WIDTH = 4
) (
  input exec_carry_out, 
  input exec_zero_out,
  input [OPCODE_WIDTH-1:0] exec_opcode,
  input [STEP_WIDTH-1:0] exec_step_out,
  input clk,
  input en_clk,
  input reset_sig,
  input [ADDRESS_WIDTH-1:0] exec_man_address,
  input [WORD_WIDTH-1:0] exec_man_data,
  input exec_man_data_mode_switch,
  input exec_man_addr_mode_switch,
  input exec_man_ram_in,
  input exec_man_ram_in_control_line,

  output [WORD_WIDTH-1:0] exec_out_view_bus,
  output exec_en_ir_out,
  output exec_en_ir_in,
  output exec_en_ras_in,
  output exec_en_a_in,
  output exec_en_ram_out,
  output exec_en_a_out,
  output exec_en_b_in,
  output exec_en_pc_in,
  output exec_en_pc_out,
  output exec_en_ram_in,
  output exec_en_add_sub,
  output exec_en_hlt,
  output exec_en_alu_out,
  output exec_en_out_in,
  output exec_en_pc_latcher,
  output exec_en_reset_step_counter
  
 );
wire THE_CLK;
wire [WORD_WIDTH-1:0] w_bus;
assign exec_out_view_bus = w_bus;

wire [WORD_WIDTH-1:0]    exec_ir_out;
wire [ADDRESS_WIDTH-1:0] exec_ras_out;
wire [WORD_WIDTH-1:0]    exec_ram_raw_out;
wire [ADDRESS_WIDTH-1:0] exec_pc_raw_out;
wire [WORD_WIDTH-1:0]    exec_alu_raw_out;
wire [WORD_WIDTH-1:0]    exec_alu_raw_a_reg;
wire                     exec_carry_out;
wire                     exec_zero_out;


// Instantiating Clock gating to load thr program into the ram and enable it in the beginning of the execution phase 
and_n #(.WIDTH(2)) clock_gate_inst (.a({clk, en_clk}), .y(THE_CLK));

// Instantiating Instruction Register
instruction_register #(.WIDTH(WORD_WIDTH)) instruction_register_inst (
  .clk(THE_CLK), 
  .en_load(exec_en_ir_in), 
  .reset_sig(reset_sig), 
  .instr_d(w_bus), 

  .instruction_q(exec_ir_out)
  );

// Tristate Buffer connecting IR output to the W-Bus
tristate_buff_n #(.WIDTH(4)) ir_bus_driver (.a(exec_ir_out[3:0]), .en(exec_en_ir_out), .y(w_bus[3:0]));

// Instantiating Control Unit 
control_unit control_unit_inst (
.reset(reset_sig), 
.opcode(exec_opcode), 
.step(exec_step_out), 
.flag({exec_carry_out, exec_zero_out}), 

.en_ir_out(exec_en_ir_out),
.en_ir_in(exec_en_ir_in),
.en_ras_in(exec_en_ras_in),
.en_a_in(exec_en_a_in),
.en_ram_out(exec_en_ram_out),
.en_a_out(exec_en_a_out),
.en_b_in(exec_en_b_in),
.en_pc_in(exec_en_pc_in),
.en_pc_out(exec_en_pc_out),
.en_ram_in(exec_en_ram_in),
.en_add_sub(exec_en_add_sub),
.en_hlt(exec_en_hlt),
.en_alu_out(exec_en_alu_out),
.en_out_in(exec_en_out_in),
.en_pc_latcher(exec_en_pc_latcher),
.en_reset_step_counter(exec_en_reset_step_counter)
);

// Instantiating RAM Address Selector
ras #(.WIDTH(ADDRESS_WIDTH)) ras_inst (
  .addr(w_bus[ADDRESS_WIDTH-1:0]), 
  .clk(THE_CLK), 
  .reset_sig(reset_sig), 
  .en_ras(exec_en_ras_in), 
  .ras_q(exec_ras_out)
);

// Instantiating RAM 
ram #(.ADDR_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(WORD_WIDTH)) ram_inst (
  .clk(THE_CLK), 
  .reset_sig(reset_sig),
  .addr(exec_ras_out), 
  .manual_addr(exec_man_address), 
  .data(w_bus), 
  .manual_data(exec_man_data), 
  .en_data_mode_switcher(exec_man_data_mode_switch), 
  .en_addr_mode_switcher(exec_man_addr_mode_switch),
  .en_ram_in(exec_en_ram_in),
  .en_manual_ram_in(exec_man_ram_in),
  .ram_in_control_line(exec_man_ram_in_control_line),
  
  .ram_y(exec_ram_raw_out)
  );

tristate_buff_n #(.WIDTH(8)) ram_bus_driver (.a(exec_ram_raw_out), .en(exec_en_ram_out), .y(w_bus));

// Instantiating Program Counter 
pc #(.WIDTH(ADDRESS_WIDTH)) pc_inst (
  .a(w_bus[3:0]), 
  .b(4'b0001), 
  .clk(THE_CLK), 
  .reset_sig(reset_sig), 
  .add_sub(exec_en_add_sub), 
  .en_pc_in(exec_en_pc_in), 
  .en_pc_reg(exec_en_pc_latcher),  

  .pc_q(exec_pc_raw_out)
  );

 tristate_buff_n #(.WIDTH(4)) pc_bus_driver (.a(exec_pc_raw_out), .en(exec_en_pc_out), .y(w_bus[3:0]));

// Instantiating Arithmetic/Logic Unit (ALU)
alu #(.WIDTH(WORD_WIDTH)) alu_inst (
  .a(w_bus), 
  .b(w_bus), 
  .clk(THE_CLK), 
  .reset_sig(reset_sig), 
  .en_a(exec_en_a_in), 
  .en_b(exec_en_b_in),  
  .add_sub(exec_en_add_sub), 

  .result(exec_alu_raw_out), 
  .carry_flag(), 
  .zero_flag(), 
  .a_result(exec_alu_raw_a_reg)
  );

 tristate_buff_n #(.WIDTH(8)) alu_bus_driver  (.a(exec_alu_raw_out),  .en(exec_en_alu_out), .y(w_bus));
 tristate_buff_n #(.WIDTH(8)) acc_bus_driver  (.a(exec_alu_raw_a_reg),   .en(exec_en_a_out),   .y(w_bus));

endmodule