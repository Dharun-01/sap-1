module decode_phase_tb();
parameter WORD_W = 8;

reg tb_clk;
reg tb_reset;
reg tb_dec_en_ir_in;
reg tb_dec_en_ir_out;
reg [WORD_W-1:0] tb_dec_instr_d; // This is the input instruction to be loaded into the instruction register for decoding. It should be set according to the test vectors to verify the correct decoding behavior of the decode phase.
reg [17:0] test_vectors [0:5];
reg [WORD_W-1:0] expected_dec_out_view_bus;

wire [WORD_W-1:0] tb_dec_out_view_bus;

decode_phase #(.WORD_WIDTH(WORD_W)) decode_phase_inst (
  .clk(tb_clk), 
  .reset(tb_reset), 
  .dec_instr_d(tb_dec_instr_d),
  .dec_en_ir_in(tb_dec_en_ir_in), 
  .dec_en_ir_out(tb_dec_en_ir_out), 
  .dec_out_view_bus(tb_dec_out_view_bus)
);

initial tb_clk = 0;
always #5 tb_clk = ~tb_clk; // 10 time units clock period

integer vector_index = 0;
initial begin
  $dumpfile("sim/decode_phase/decode_phase.vcd");
  $dumpvars(0, decode_phase_tb);
  $readmemb("rtl/subsystems_tests/decode_phase/decode_phase.tv", test_vectors);

  // Initialize inputs
  tb_reset = 1; // Start in reset
  tb_dec_en_ir_in = 0;
  tb_dec_en_ir_out = 0;

  #15;          // Hold reset for more than one clock cycle
  tb_reset = 0; // Release reset
  #10;

  while (test_vectors[vector_index] !== 18'bx) begin
    @ (negedge tb_clk); // Wait for the negative edge of the clock to ensure that the inputs are registered in the decode phase before checking the output
    {
      tb_dec_en_ir_in, 
      tb_dec_en_ir_out, 
      tb_dec_instr_d,
       expected_dec_out_view_bus
     } = test_vectors[vector_index];
    {
      tb_dec_en_ir_in, 
      tb_dec_en_ir_out, 
      tb_dec_instr_d,
      expected_dec_out_view_bus
     } = test_vectors[vector_index];

     #2; // Wait for a short time to let the values propagate through the system before checking the output
    if (tb_dec_out_view_bus !== expected_dec_out_view_bus) begin
      $display("Test Vector %0d Failed: Expected dec_out_view_bus = %b, Actual dec_out_view_bus = %b", vector_index, expected_dec_out_view_bus, tb_dec_out_view_bus);
    end else begin
      $display("Test Vector %0d Passed: dec_out_view_bus = %b", vector_index, tb_dec_out_view_bus);
    end

    vector_index = vector_index + 1;
   end
  $display("All Test cases completed.");
  $finish;
 end
 
endmodule