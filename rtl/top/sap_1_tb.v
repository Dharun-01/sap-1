`timescale 1ns/1ps

module sap_1_tb();
parameter ADDR_W = 4;
parameter DATA_W = 8;

// Input Wires
reg tb_clk;
reg tb_en_clk;
reg tb_reset;
reg [ADDR_W-1:0] tb_man_address;
reg [DATA_W-1:0] tb_man_data;
reg tb_man_data_mode_switch;
reg tb_man_addr_mode_switch;
reg tb_man_ram_in;
reg tb_man_ram_in_control;

// Output Wires
wire tb_sap_a1;
wire tb_sap_b1;
wire tb_sap_c1;
wire tb_sap_d1;
wire tb_sap_e1;
wire tb_sap_f1;
wire tb_sap_g1;
wire tb_sap_a2;
wire tb_sap_b2;
wire tb_sap_c2;
wire tb_sap_d2;
wire tb_sap_e2;
wire tb_sap_f2;
wire tb_sap_g2;

// Output Wires
wire [DATA_W-1:0] tb_out_view_bus;
wire tb_out_carry;
wire tb_out_zero;

// Expected Tracking
integer vector_index;
integer execution_cycles;
reg [25:0] test_vectors [0:29];
reg [DATA_W-1:0] expected_view_bus;

sap_1 #(.ADDRESS_WIDTH(ADDR_W), .BIT_WIDTH(DATA_W)) dut (
  .clk(tb_clk), 
  .en_clk(tb_en_clk), 
  .reset(tb_reset), 
  .man_address(tb_man_address), 
  .man_data(tb_man_data), 
  .man_data_mode_switch(tb_man_data_mode_switch), 
  .man_addr_mode_switch(tb_man_addr_mode_switch), 
  .man_ram_in(tb_man_ram_in), 
  .man_ram_in_control_line(tb_man_ram_in_control),

  .sap_a1(tb_sap_a1),
  .sap_b1(tb_sap_b1),
  .sap_c1(tb_sap_c1),
  .sap_d1(tb_sap_d1),
  .sap_e1(tb_sap_e1),
  .sap_f1(tb_sap_f1),
  .sap_g1(tb_sap_g1),
  .sap_a2(tb_sap_a2),
  .sap_b2(tb_sap_b2),
  .sap_c2(tb_sap_c2),
  .sap_d2(tb_sap_d2),
  .sap_e2(tb_sap_e2),
  .sap_f2(tb_sap_f2),
  .sap_g2(tb_sap_g2),

  .out_view_bus(tb_out_view_bus),
  .out_carry(tb_out_carry),
  .out_zero(tb_out_zero)
);

// Seven_Segment_decoder_function to decode the lookup table data
 function automatic [3:0] decode_7_seg(input [6:0] segs);
 case (segs) 
   7'b1111110: decode_7_seg = 4'h0;
   7'b0000110: decode_7_seg = 4'h1;
   7'b1101101: decode_7_seg = 4'h2;
   7'b1111001: decode_7_seg = 4'h3;
   7'b0110011: decode_7_seg = 4'h4;
   7'b1011011: decode_7_seg = 4'h5;
   7'b1011111: decode_7_seg = 4'h6;
   7'b1110000: decode_7_seg = 4'h7;
   7'b1111111: decode_7_seg = 4'h8;
   7'b1111011: decode_7_seg = 4'h9;
   7'b1110111: decode_7_seg = 4'hA;
   7'b0011111: decode_7_seg = 4'hB;
   7'b1001110: decode_7_seg = 4'hC;
   7'b0111101: decode_7_seg = 4'hD;
   7'b1001111: decode_7_seg = 4'hE;
   7'b1000111: decode_7_seg = 4'hF;
   default: decode_7_seg = 4'hx;
 endcase 
 endfunction

 wire [3:0] display_digit_1 = decode_7_seg({
tb_sap_a1,
tb_sap_b1,
tb_sap_c1,
tb_sap_d1,
tb_sap_e1,
tb_sap_f1,
tb_sap_g1
 });

 wire [3:0] display_digit_2 = decode_7_seg({
tb_sap_a2,
tb_sap_b2,
tb_sap_c2,
tb_sap_d2,
tb_sap_e2,
tb_sap_f2,
tb_sap_g2
 });

// Initialize and start the clock
initial tb_clk = 0;
always #10 tb_clk = ~tb_clk;
 
initial begin 

// Initialize all the variables
  vector_index = 0;
  execution_cycles = 0;
  expected_view_bus = 8'h00; // Force out the 'x' state before the loop checks it!
  
  tb_reset = 1'b0;
  tb_en_clk = 1'b0;
  tb_man_addr_mode_switch = 1'b0;
  tb_man_data_mode_switch = 1'b0;
  tb_man_ram_in_control = 1'b0;
  tb_man_ram_in = 1'b0;
  tb_man_address = 4'b0000;
  tb_man_data = 8'b00000000;

  $dumpfile("sim/top/sap_1.vcd");
  $dumpvars(0, sap_1_tb);

  $readmemb("rtl/top/sap_1.tv", test_vectors);

 $display("---------------------------------");
 $display("START OF MANUAL PROGRAMMING PHASE");

  // || !-- MANUAL PROGRAMMING PHASE --!
  while (test_vectors[vector_index] !== 26'hx && test_vectors[vector_index][7:0] !== 8'hFF) begin 
    @ (negedge tb_clk);
    {
     tb_reset,
     tb_en_clk, 
     tb_man_addr_mode_switch, 
     tb_man_data_mode_switch, 
     tb_man_ram_in_control, 
     tb_man_ram_in, 
     tb_man_address, 
     tb_man_data, 
     expected_view_bus
     } = test_vectors[vector_index];

      #2; // Wait for a short time to let the values propagate through the system before checking the output
    if (tb_out_view_bus !== expected_view_bus) begin
      $display("Test Vector %0d Failed: Expected W-Bus = %b, Actual W-Bus = %b", vector_index, expected_view_bus, tb_out_view_bus);
    end else begin
      $display("Test Vector %0d Passed: W-Bus = %b", vector_index, tb_out_view_bus);
    end
    vector_index = vector_index + 1;
  end
 $display("END OF MANUAL PROGRAMMING PHASE");
 $display("---------------------------------");
 
  tb_man_addr_mode_switch = 1'b0; // Hand MAR back to internal W-Bus
  tb_man_data_mode_switch = 1'b0; // Hand RAM back to internal W-Bus
  tb_man_ram_in_control   = 1'b0;
  tb_man_ram_in           = 1'b0;
  tb_man_address          = 4'b0000;
  tb_man_data             = 8'b00000000;

  #20;
  // 2. Turn on the clock enable line permanently for free-run mode!
  tb_en_clk = 1'b1;

  // !-- AUTOMATIC EXECUTION PHASE --!
  $display("\n=======================================================");
  $display("[MONITOR] CPU running. Decoding 7-Segment Output Live:");
  $display("=======================================================");
  
  // Run execution loop for 6000ns (300 clock cycles) to watch multiple loop transitions
        while (execution_cycles < 300) begin
            @(posedge tb_clk);
            execution_cycles = execution_cycles + 1;
            
            // Whenever the display unit enables updates (during OUT instruction), print the decoded value
            if (dut.sap_en_out_in === 1'b1 && dut.step_out === 3'b010) begin 
                #2; // Let values propagate through the display registers
                $display("Time: %t | W-Bus: 0x%h | DISPLAY SHOWS: %h%h", $time, tb_out_view_bus, display_digit_1, display_digit_2);
            end
        end
  $finish;
end
initial begin
    // Wake up right as the manual programming ends and automatic execution starts
    #600; 
    $display("\n=================== SYSTEM TRANSITION DIAGNOSTIC ===================");
    $display("Master TB Clock (tb_clk):             %b", tb_clk);
    $display("Gated Internal Clock (THE_CLK):       %b", dut.THE_CLK);
    $display("Manual Data                           %b", tb_man_data);
    $display("Current CPU Step (step_out):          %b", dut.step_out);
    $display("Current Shared Bus (w_bus):           %b", dut.w_bus);
    $display("Control Unit HLT line:                %b", dut.sap_en_hlt);
    $display("Ram ram_raw_out:                      %b", dut.ram_raw_out);
    $display("Time %t: Control Unit PC_Out:         %b", $time, dut.sap_en_pc_out);
    $display("Time %t: Instruction Register IR_Out: %b", $time, dut.sap_en_ir_out);
    $display("Time %t: Display Unit Out_in:         %b", $time, dut.sap_en_out_in);
    $display("====================================================================\n");
end
endmodule