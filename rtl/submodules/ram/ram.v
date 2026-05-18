module ram #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 8) (
input [ADDR_WIDTH-1:0] addr, 
input [ADDR_WIDTH-1:0] manual_addr, 
input [DATA_WIDTH-1:0] data, 
input [DATA_WIDTH-1:0] manual_data, 
input clk, 
input en_data_mode_switcher, 
input en_addr_mode_switcher, 
input en_ram_in, en_ram_out, 
input step_1, 
input en_manual_ram_in, 
input ram_in_control_line,

output wire [DATA_WIDTH-1:0] ram_y
); // step_1 is used to hard code the value for first two steps because it is the same for all 10 instructions.

wire ram_in_and_gate_output;

wire [2**ADDR_WIDTH-1:0] row_select; 
wire [ADDR_WIDTH-1:0] addr_select;
wire [DATA_WIDTH-1:0] data_select;
wire  ram_in_select;
wire  ram_out_select; 


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

  // Using your library's and_n module for consistency
  and_n #(.WIDTH(2)) ram_in (.a({clk, en_ram_in}), .y(ram_in_and_gate_output)); // ram_in

  
  mux #(.WIDTH(1)) ram_in_mux_inst (.d0(ram_in_and_gate_output), .d1(en_manual_ram_in), .sel(ram_in_control_line), .y(ram_in_select)); // select between manual ram_in and control_unit ram_in
 
  // Using your library's or_n module for consistency
  or_n #(.WIDTH(2)) ram_out_inst (.a({en_ram_out, step_1}), .y(ram_out_select)); // ram-out

// --- 4. Memory Rows ---
genvar i;
generate 
 for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin: row_gen 
    memory_row #(.DATA_W(DATA_WIDTH)) memory_row_inst (
      .decoder_output_line(row_select[i]),
      .ram_out_sel(ram_out_select), 
      .ram_in_sel(ram_in_select), 
      .data_in(data_select), 
      .mem_row_y(ram_y));
 end
endgenerate 

endmodule 