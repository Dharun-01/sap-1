 module sap_1 #(parameter BIT_WIDTH = 8, parameter ADDRESS_WIDTH = 4) 
(
  input clk, 
  input en_clk,
  input reset, 
  input [ADDRESS_WIDTH-1:0] man_address, 
  input [BIT_WIDTH-1:0] man_data, 
  input man_data_mode_switch, 
  input man_addr_mode_switch, 
  input man_ram_in, 
  input man_ram_in_control_line,

// || !-- 7 Segment Display Output Ports --!
// First Display
  output sap_a1, 
  output sap_b1, 
  output sap_c1, 
  output sap_d1, 
  output sap_e1, 
  output sap_f1, 
  output sap_g1,
  
// Second Display
  output sap_a2, 
  output sap_b2, 
  output sap_c2, 
  output sap_d2, 
  output sap_e2, 
  output sap_f2, 
  output sap_g2,

 // BUS and Flag Ports to inspect the internals of the system
  output [BIT_WIDTH-1:0] out_view_bus,
  output out_carry,
  output out_zero

);

// || !-- IMPORTANT NOTE --!
// NOTE: "From" Word used in comments throughout in this module represents that the particular wire belongs to the module stated in the comment. It does NOT mean that wire is always "input" to the module. It can be output wire as well.
// || !-- IMPORTANT NOTE --!

// || !-- Central Highway for propagation of data --!
wire [BIT_WIDTH-1:0] w_bus;
assign out_view_bus = w_bus; // Drive the output port with the internal bus state

// || !-- THE CLOCK --!
wire THE_CLK;
// !-- THE CLOCK --!

// || !--"Out" Wires (Wires connecting to W-Bus) to connect to the highway from submodules --!

// From ALU module
wire  carry_out;
wire  zero_out;
// Drive the flag output ports
assign out_carry = carry_out;
assign out_zero  = zero_out;

// From Instruction Register module
wire [BIT_WIDTH-1:0] ir_out;

// From RAS module
wire [ADDRESS_WIDTH-1:0] ras_out;

// From Step Counter module
wire [2:0] step_out;

// Control Word wires (coming out from the control unit) to control the submodules.
wire sap_en_ir_out,
sap_en_ir_in,
sap_en_ras_in,
sap_en_a_in,
sap_en_ram_out,
sap_en_a_out,
sap_en_b_in,
sap_en_pc_in,
sap_en_pc_out,
sap_en_ram_in,
sap_en_add_sub,
sap_en_hlt,
sap_en_alu_out,
sap_en_out_in,
sap_en_pc_latcher,
sap_en_reset_step_counter;

                        // || !-- END OF "OUT" WIRES --!

wire internal_clk;
// !-- THE CLOCK --!
 and_n #(3) clk_inst (.a({clk, en_clk, ~sap_en_hlt}), .y(internal_clk));
 assign THE_CLK = internal_clk;
// !-- THE CLOCK --!

wire [ADDRESS_WIDTH-1:0] pc_raw_out;
wire [BIT_WIDTH-1:0]     ram_raw_out;
wire [BIT_WIDTH-1:0]     alu_raw_result;
wire [BIT_WIDTH-1:0]     alu_raw_a_reg;

// Instantiating RAM Address Selector
ras #(.WIDTH(ADDRESS_WIDTH)) ras_inst (
  .addr(w_bus[ADDRESS_WIDTH-1:0]), 
  .clk(THE_CLK), 
  .reset_sig(reset), 
  .en_ras(sap_en_ras_in), 
  .ras_q(ras_out)
);

// Instantiating RAM 
ram #(.ADDR_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(BIT_WIDTH)) ram_inst (
  .clk(THE_CLK), 
  .reset_sig(reset),
  .addr(ras_out), 
  .manual_addr(man_address), 
  .data(w_bus), 
  .manual_data(man_data), 
  .en_data_mode_switcher(man_data_mode_switch), 
  .en_addr_mode_switcher(man_addr_mode_switch),
  .en_ram_in(sap_en_ram_in),
  .en_manual_ram_in(man_ram_in),
  .ram_in_control_line(man_ram_in_control_line),
  
  .ram_y(ram_raw_out)
  );

tristate_buff_n #(.WIDTH(8)) ram_bus_driver (.a(ram_raw_out), .en(sap_en_ram_out), .y(w_bus));

// Instantiating Instruction Register
instruction_register #(.WIDTH(BIT_WIDTH)) instruction_register_inst (
  .clk(THE_CLK), 
  .en_load(sap_en_ir_in), 
  .reset_sig(reset), 
  .instr_d(w_bus), 

  .instruction_q(ir_out)
  );

// Tristate Buffer connecting IR output to the W-Bus
tristate_buff_n #(.WIDTH(4)) ir_bus_driver (.a(ir_out[3:0]), .en(sap_en_ir_out), .y(w_bus[3:0]));

// Instantiating Step Counter (Ring Counter)
step_counter #(.WIDTH(3)) step_counter_inst (
  .clk(THE_CLK), 
  .b(3'b001), 
  .reset_sig(reset | sap_en_reset_step_counter), 
  .internal_result(step_out)
);

// Instantiating Control Unit 
control_unit control_unit_inst (
.reset(reset), 
.opcode(ir_out[7:4]), 
.step(step_out), 
.flag({carry_out, zero_out}), 

.en_ir_out(sap_en_ir_out),
.en_ir_in(sap_en_ir_in),
.en_ras_in(sap_en_ras_in),
.en_a_in(sap_en_a_in),
.en_ram_out(sap_en_ram_out),
.en_a_out(sap_en_a_out),
.en_b_in(sap_en_b_in),
.en_pc_in(sap_en_pc_in),
.en_pc_out(sap_en_pc_out),
.en_ram_in(sap_en_ram_in),
.en_add_sub(sap_en_add_sub),
.en_hlt(sap_en_hlt),
.en_alu_out(sap_en_alu_out),
.en_out_in(sap_en_out_in),
.en_pc_latcher(sap_en_pc_latcher),
.en_reset_step_counter(sap_en_reset_step_counter)
);

// Instantiating Program Counter 
pc #(.WIDTH(ADDRESS_WIDTH)) pc_inst (
  .a(w_bus[3:0]), 
  .b(4'b0001), 
  .clk(THE_CLK), 
  .reset_sig(reset), 
  .add_sub(sap_en_add_sub), 
  .en_pc_in(sap_en_pc_in), 
  .en_pc_reg(sap_en_pc_latcher),  

  .pc_q(pc_raw_out)
  );

 tristate_buff_n #(.WIDTH(4)) pc_bus_driver (.a(pc_raw_out), .en(sap_en_pc_out), .y(w_bus[3:0]));

// Instantiating Arithmetic/Logic Unit (ALU)
alu #(.WIDTH(BIT_WIDTH)) alu_inst (
  .a(w_bus), 
  .b(w_bus), 
  .clk(THE_CLK), 
  .reset_sig(reset), 
  .en_a(sap_en_a_in), 
  .en_b(sap_en_b_in),  
  .add_sub(sap_en_add_sub), 

  .result(alu_raw_result), 
  .carry_flag(carry_out), 
  .zero_flag(zero_out), 
  .a_result(alu_raw_a_reg)
  );

 tristate_buff_n #(.WIDTH(8)) alu_bus_driver  (.a(alu_raw_result),  .en(sap_en_alu_out), .y(w_bus));
 tristate_buff_n #(.WIDTH(8)) acc_bus_driver  (.a(alu_raw_a_reg),   .en(sap_en_a_out),   .y(w_bus));

// Instantiating Display Unit 
display_unit #(.D_WIDTH(BIT_WIDTH)) display_unit_inst (
  .data_in(w_bus), 
  .clk(THE_CLK), 
  .en_out_in(sap_en_out_in), 
  .reset_sig(reset),

  .a1(sap_a1),
  .b1(sap_b1),
  .c1(sap_c1),
  .d1(sap_d1),
  .e1(sap_e1),
  .f1(sap_f1),
  .g1(sap_g1),
  .a2(sap_a2),
  .b2(sap_b2),
  .c2(sap_c2),
  .d2(sap_d2),
  .e2(sap_e2),
  .f2(sap_f2),
  .g2(sap_g2)
);

endmodule