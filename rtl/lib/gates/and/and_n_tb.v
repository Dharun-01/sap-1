`timescale 1ns/1ps

module and_n_tb(); // no ports
parameter W = 3;
reg [W-1:0] tb_a;
wire tb_y; // just a wire to connect the output of the and_n module, it cannot hold values like reg.

  and_n  #(.WIDTH(W)) dut(.a(tb_a), .y(tb_y)); // instantiate the and_n module, we call it "uut" (unit under test), and connect its inputs and output to our reg and wire.

  initial begin // initial block runs once at the beginning of the simulation
  $dumpfile("sim/and/and_n.vcd"); // create a VCD file to store the waveform data for our simulation
  $dumpvars(0, and_n_tb); // dump all variables in the and_n_tb module to the VCD file, this allows us to see how the values of a, b, and y change over time in the waveform viewer

    tb_a = 3'b000; // test case 1: all inputs are 0, expect output to be 0
    #10; // wait for 10 time units
    if(tb_y !== 0) $display("000 failed" );
    tb_a = 3'b001; // test case 2: one input is 1 and the other is 0, expect output to be 0
    #10; // wait for 10 time units
    if(tb_y !== 0) $display("001 failed" );
    tb_a = 3'b010; // test case 3: one input is 1 and the other is 0, expect output to be 0
    #10; // wait for 10 time units
    if(tb_y !== 0) $display("010 failed" );  
    tb_a = 3'b111; // test case 4: all inputs are 1, expect output to be 1
    #10; // wait for 10 time units
    if(tb_y !== 1) $display("111 failed" );
    $finish; // finish the simulation after testing all combinations of a and b
  end 
endmodule