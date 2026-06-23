`timescale 1ns/1ps

module ram #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 8) (
input [ADDR_WIDTH-1:0] addr, 
input [ADDR_WIDTH-1:0] manual_addr, 
input [DATA_WIDTH-1:0] data, 
input [DATA_WIDTH-1:0] manual_data, 
input clk, 
input reset_sig,
input en_data_mode_switcher, 
input en_addr_mode_switcher, 
input en_ram_in, 
input en_manual_ram_in, 
input ram_in_control_line,

output wire [DATA_WIDTH-1:0] ram_y
); 

wire [2**ADDR_WIDTH-1:0] row_select; 
wire [ADDR_WIDTH-1:0] addr_select;
wire [DATA_WIDTH-1:0] data_select;
wire ram_in_select; 
wire ram_clk;

wire [DATA_WIDTH-1:0] row_outputs [2**ADDR_WIDTH-1:0]; // Array to hold outputs of all memory rows

// --- 1. Address Multiplexers ---
genvar addr_mul; // stands for addr_multiplexer
  generate
    for (addr_mul = 0; addr_mul < ADDR_WIDTH; addr_mul = addr_mul + 1) begin: addr_mux 
      mux #(.WIDTH(1)) mux_addr_inst (.d1(manual_addr[addr_mul]), .d0(addr[addr_mul]), .sel(en_addr_mode_switcher), .y(addr_select[addr_mul]));
    end

   endgenerate
  
  // --- 2. Data Multiplexers ---
  genvar data_mul; // stands for data_multiplexer
  generate 
    for (data_mul = 0; data_mul < DATA_WIDTH; data_mul = data_mul + 1) begin: data_mux 
      mux #(.WIDTH(1)) mux_data_inst (.d1(manual_data[data_mul]), .d0(data[data_mul]), .sel(en_data_mode_switcher), .y(data_select[data_mul]));
    end
  endgenerate

  // --- 3. Control and Address Decoding Units ---
  decoder_n #(.WIDTH(ADDR_WIDTH)) decoder_inst (.in(addr_select), .y(row_select)); // to decode the address

  
  mux #(.WIDTH(1)) ram_in_mux_inst (.d0(en_ram_in), .d1(1'b1), .sel(ram_in_control_line), .y(ram_in_select)); // select between manual ram_in and control_unit ram_in
 
   mux #(.WIDTH(1)) ram_clk_mux (
   .d0(clk),                  // Master system clock
    .d1(en_manual_ram_in),     
    .sel(ram_in_control_line), // Mode selector
    .y(ram_clk)
);

// --- 4. Memory Rows ---
genvar r;
generate 
 for (r = 0; r < 2**ADDR_WIDTH; r = r + 1) begin: row_gen 
    memory_row #(.DATA_W(DATA_WIDTH)) memory_row_inst (
      .clk(ram_clk),
      .reset_sig(1'b0),
      .decoder_output_line(row_select[r]), 
      .ram_in_sel(ram_in_select), 
      .data_in(data_select), 
      
      .mem_row_y(row_outputs[r]) // Connect each row's output to the corresponding index in the row_outputs array
    );
 end        
endgenerate

genvar bit_idx, row_idx;
generate 
  // Loop through each of the 8 bits
    for (bit_idx = 0; bit_idx < DATA_WIDTH; bit_idx = bit_idx + 1) begin: bit_slice
        wire [2**ADDR_WIDTH-1:0] bit_pool;
        
        // Gather the specific bit from all 16 rows
        for (row_idx = 0; row_idx < 2**ADDR_WIDTH; row_idx = row_idx + 1) begin: gather_bits
            assign bit_pool[row_idx] = row_outputs[row_idx][bit_idx];
        end
        
        // OR all 16 wires together and assign to the final output
        assign ram_y[bit_idx] = |bit_pool; 
    end
endgenerate
endmodule
