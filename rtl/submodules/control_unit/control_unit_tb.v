`timescale 1ns/1ps

module control_unit_tb();

reg tb_reset;
reg [3:0] tb_opcode;
reg [2:0] tb_step;
reg [1:0] tb_flags;

reg [25:0] test_vectors [0:35];
reg [15:0] expected_ctrl_word;


 wire tb_en_ir_out;
 wire tb_en_ir_in;
 wire tb_en_ras_in;
 wire tb_en_a_in;
 wire tb_en_ram_out;
 wire tb_en_a_out;
 wire tb_en_b_in;
 wire tb_en_pc_in;
 wire tb_en_pc_out;
 wire tb_en_ram_in;
 wire tb_en_add_sub;
 wire tb_en_hlt;
 wire tb_en_alu_out;
 wire tb_en_out_in;
 wire tb_en_pc_latcher;
 wire tb_en_reset_step_counter;

wire [15:0] actual_ctrl_word = {
    tb_en_ir_out,      tb_en_ir_in,           tb_en_ras_in,     tb_en_a_in,
    tb_en_ram_out,     tb_en_a_out,           tb_en_b_in,       tb_en_pc_in,
    tb_en_pc_out,      tb_en_ram_in,          tb_en_add_sub,    tb_en_hlt,
    tb_en_alu_out,     tb_en_out_in,          tb_en_pc_latcher, tb_en_reset_step_counter
};

control_unit dut ( 
.reset(tb_reset), 
.opcode(tb_opcode),
.step(tb_step), 
.flag(tb_flags), 

.en_ir_out(tb_en_ir_out),
.en_ir_in(tb_en_ir_in),
.en_ras_in(tb_en_ras_in),
.en_a_in(tb_en_a_in),
.en_ram_out(tb_en_ram_out),
.en_a_out(tb_en_a_out),
.en_b_in(tb_en_b_in),
.en_pc_in(tb_en_pc_in),
.en_pc_out(tb_en_pc_out),
.en_ram_in(tb_en_ram_in),
.en_add_sub(tb_en_add_sub),
.en_hlt(tb_en_hlt),
.en_alu_out(tb_en_alu_out),
.en_out_in(tb_en_out_in),
.en_pc_latcher(tb_en_pc_latcher),
.en_reset_step_counter(tb_en_reset_step_counter)
);

integer i;
initial begin 
  $dumpfile("sim/control_unit/control_unit.vcd");
  $dumpvars(0, control_unit_tb);

  $readmemb("rtl/submodules/control_unit/control_unit.tv", test_vectors);

   $display("Starting SAP-1 Control Unit Verification...");
   $display("------------------------------------------------");
  

  for (i = 0; i < 36; i = i + 1) begin

    tb_opcode        = test_vectors[i][25:22];
    tb_reset         = test_vectors[i][21];
    tb_step          = test_vectors[i][20:18];
    tb_flags         = test_vectors[i][17:16];
    expected_ctrl_word = test_vectors[i][15:0];
    
    #2;

    // Perform self-checking assertion
        if (actual_ctrl_word !== expected_ctrl_word) begin
            $display("FAIL: Vector %0d | Op:%b Step:%d Flag:%b", i, tb_opcode, tb_step, tb_flags);
            $display("      Expected: %b", expected_ctrl_word);
            $display("      Got:      %b", actual_ctrl_word);
        end else begin
            $display("PASS: Vector %0d | Op:%b Step:%d Flag:%b Matrix Matched!", i, tb_opcode, tb_step, tb_flags);
        end
   end
   $display("------------------------------------------------");
   $display("Verification Complete");
   $finish;
end
endmodule