`timescale 1ns/1ps

module fetch_phase #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 4) (
  // Program Counter (PC) inputs 
  input clk, 
  input reset_sig, 
  input fet_add_sub, 
  input fet_en_pc_in, 
  input fet_en_pc_reg, 
  input fet_en_pc_out,

  // Program Counter (PC) output
  output [ADDR_WIDTH-1:0] fet_pc_q,

  // RAS Inputs  
  input fet_en_ras,
   
  // RAS Output
  output [ADDR_WIDTH-1:0] fet_ras_q,

  // RAM Inputs 
input [ADDR_WIDTH-1:0] fet_manual_addr, 
input [DATA_WIDTH-1:0] fet_manual_data, 
input fet_en_ram_out,
input fet_en_data_mode_switcher, 
input fet_en_addr_mode_switcher, 
input fet_en_ram_in, 
input fet_en_manual_ram_in, 
input fet_ram_in_control_line,

// RAM Output
output wire [DATA_WIDTH-1:0] fet_ram_y,

output [DATA_WIDTH-1:0] fet_out_view_bus
);

wire [DATA_WIDTH-1:0] w_bus;
assign fet_out_view_bus = w_bus; // Connect the internal bus to the output view bus for testing and observation purposes.

pc #(.WIDTH(ADDR_WIDTH)) pc_inst (
  .clk(clk), 
  .reset_sig(reset_sig), 
  .a(w_bus[ADDR_WIDTH-1:0]), 
  .b(4'b0001), // Increment value for the PC (e.g., 1 to move to the next instruction)
  .add_sub(fet_add_sub), 
  .en_pc_in(fet_en_pc_in), 
  .en_pc_reg(fet_en_pc_reg), 

  .pc_q(fet_pc_q)
);

tristate_buff_n #(.WIDTH(4)) pc_bus_driver (
  .a(fet_pc_q), 
  .en(fet_en_pc_out), 
  .y(w_bus[ADDR_WIDTH-1:0])
);

ras #(.WIDTH(ADDR_WIDTH)) ras_inst (
  .addr(w_bus[ADDR_WIDTH-1:0]), 
  .clk(clk), 
  .reset_sig(reset_sig), 
  .en_ras(fet_en_ras),

  .ras_q(fet_ras_q)
);


ram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ram_inst (
  .clk(clk), 
  .reset_sig(reset_sig),
  .addr(fet_ras_q), 
  .manual_addr(fet_manual_addr), 
  .data(w_bus), 
  .manual_data(fet_manual_data), 
  .en_data_mode_switcher(fet_en_data_mode_switcher), 
  .en_addr_mode_switcher(fet_en_addr_mode_switcher),
  .en_ram_in(fet_en_ram_in),
  .en_manual_ram_in(fet_en_manual_ram_in),
  .ram_in_control_line(fet_ram_in_control_line),
  
  .ram_y(fet_ram_y)
  );

 tristate_buff_n #(.WIDTH(8)) ram_bus_driver (.a(fet_ram_y), .en(fet_en_ram_out), .y(w_bus));

endmodule