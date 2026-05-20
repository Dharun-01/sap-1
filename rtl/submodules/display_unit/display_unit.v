module display_unit #(parameter D_WIDTH = 8) 
(
  input [D_WIDTH-1:0] data_in,
  input clk,
  input en_out_in,
  input reset_sig,

// Mapping for Tens Digit 
  output reg a1,
  output reg b1,
  output reg c1, 
  output reg d1,
  output reg e1,
  output reg f1,
  output reg g1,
// Mapping for ones digit 
  output reg a2, 
  output reg b2,
  output reg c2,
  output reg d2,
  output reg e2,
  output reg f2,
  output reg g2
  );

reg [D_WIDTH-1:0] tens_digit;
reg [D_WIDTH-1:0] ones_digit;

 wire [D_WIDTH-1:0] internal_q; 
 
// Part of the brute approach to solving this problem 
 /* localparam [D_WIDTH-1:0] T0  = 0;
 localparam [D_WIDTH-1:0] T1  = 1;
 localparam [D_WIDTH-1:0] T2  = 2;
 localparam [D_WIDTH-1:0] T3  = 3;
 localparam [D_WIDTH-1:0] T4  = 4;
 localparam [D_WIDTH-1:0] T5  = 5;
 localparam [D_WIDTH-1:0] T6  = 6;
 localparam [D_WIDTH-1:0] T7  = 7;
 localparam [D_WIDTH-1:0] T8  = 8;
 localparam [D_WIDTH-1:0] T9  = 9;
 localparam [D_WIDTH-1:0] T10 = 10;
 localparam [D_WIDTH-1:0] T11 = 11;
 localparam [D_WIDTH-1:0] T12 = 12;
 localparam [D_WIDTH-1:0] T13 = 13;
 localparam [D_WIDTH-1:0] T14 = 14;
 localparam [D_WIDTH-1:0] T15 = 15;
 */

// Part of the brute force approach to solving the problem
/*  task clear_seven_segment_pins; begin 
   a1 = 0; b1 = 0; c1 = 0; d1 = 0; e1 = 0; f1 = 0; g1 = 0;  // 1'st seven_segment display
   a2 = 0; b2 = 0; c2 = 0; d2 = 0; e2 = 0; f2 = 0; g2 = 0;  // 2'nd seven_segment display 
 end
  endtask
 */
 genvar i;
 generate 
for (i = 0; i < D_WIDTH; i = i + 1) begin: gen_en_dff 
     en_dff #(.WIDTH(1)) en_dff_inst (.clk(clk), .en(en_out_in), .reset(reset_sig), .d(data_in[i]), .q(internal_q[i]));
 end
 endgenerate  

 // || !-- This is the brute force approach to solving this problem --!
/*   always @ (*) begin 
    clear_seven_segment_pins();
    if (!reset_sig) begin 
     case (internal_q) 
        T0: begin 
           a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
           a2 = 1; b2 = 1; c2 = 1; d2 = 1; e2 = 1; f2 = 1; g2 = 0;
        end

        T1: begin 
           a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
           a2 = 0; b2 = 0; c2 = 0; d2 = 0; e2 = 1; f2 = 1; g2 = 0;
        end

        T2: begin 
           a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
           a2 = 1; b2 = 1; c2 = 0; d2 = 1; e2 = 1; f2 = 0; g2 = 1;
        end

        T3: begin 
          a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 1; c2 = 1; d2 = 1; e2 = 0; f2 = 0; g2 = 1;
        end
        T4: begin 
          a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
          a2 = 0; b2 = 1; c2 = 1; d2 = 0; e2 = 0; f2 = 1; g2 = 1;
        end

        T5: begin 
          a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 0; c2 = 1; d2 = 1; e2 = 0; f2 = 1; g2 = 1;
        end

        T6: begin 
          a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 0; c2 = 1; d2 = 1; e2 = 1; f2 = 1; g2 = 1;
        end

        T7: begin 
          a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 1; c2 = 1; d2 = 0; e2 = 0; f2 = 0; g2 = 0;
        end

        T8: begin 
          a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 1; c2 = 1; d2 = 1; e2 = 1; f2 = 1; g2 = 1;
        end

        T9: begin 
          a1 = 1; b1 = 1; c1 = 1; d1 = 1; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 1; c2 = 1; d2 = 1; e2 = 0; f2 = 1; g2 = 1;
        end

        T10: begin 
          a1 = 0; b1 = 0; c1 = 0; d1 = 0; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 1; c2 = 1; d2 = 1; e2 = 1; f2 = 1; g2 = 0;
        end

        T11: begin 
          a1 = 0; b1 = 0; c1 = 0; d1 = 0; e1 = 1; f1 = 1; g1 = 0;
          a2 = 0; b2 = 0; c2 = 0; d2 = 0; e2 = 1; f2 = 1; g2 = 0;
        end

        T12: begin 
          a1 = 0; b1 = 0; c1 = 0; d1 = 0; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 1; c2 = 0; d2 = 1; e2 = 1; f2 = 0; g2 = 1;
        end

        T13: begin 
          a1 = 0; b1 = 0; c1 = 0; d1 = 0; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 1; c2 = 1; d2 = 1; e2 = 0; f2 = 0; g2 = 1;
        end

        T14: begin 
          a1 = 0; b1 = 0; c1 = 0; d1 = 0; e1 = 1; f1 = 1; g1 = 0;
          a2 = 0; b2 = 1; c2 = 1; d2 = 0; e2 = 0; f2 = 1; g2 = 1;
        end

        T15: begin 
          a1 = 0; b1 = 0; c1 = 0; d1 = 0; e1 = 1; f1 = 1; g1 = 0;
          a2 = 1; b2 = 0; c2 = 1; d2 = 1; e2 = 0; f2 = 1; g2 = 1;
        end
      default: clear_seven_segment_pins();
     endcase 
    end
  end */
  
  // || !-- Here is the modern highly efficient "functional" approach --!

function automatic [6:0] decode_digit (input [D_WIDTH-1:0] digit);
case (digit) 
  4'd0: decode_digit = 7'b1111110;
  4'd1: decode_digit = 7'b0000110;
  4'd2: decode_digit = 7'b1101101;
  4'd3: decode_digit = 7'b1111001;
  4'd4: decode_digit = 7'b0110011;
  4'd5: decode_digit = 7'b1011011;
  4'd6: decode_digit = 7'b1011111;
  4'd7: decode_digit = 7'b1110000;
  4'd8: decode_digit = 7'b1111111;
  4'd9: decode_digit = 7'b1111011;
  default: decode_digit = 7'b0000000; // Blank display for out of bounds
endcase
endfunction

always @ (*) begin 
  if (!reset_sig) begin 
    // Automatically split binary values into decimal components
    tens_digit = internal_q / 10; 
    ones_digit = internal_q % 10;
     // Assign concatenated statements using our clean lookup function
    {a1, b1,c1, d1, e1, f1, g1} = decode_digit(tens_digit);
    {a2, b2,c2, d2, e2, f2, g2} = decode_digit(ones_digit);
  end else begin 
    // Clear all segment pins for active high reset
    {a1, b1,c1, d1, e1, f1, g1} = 7'b0000000;
    {a2, b2,c2, d2, e2, f2, g2} = 7'b0000000;
    tens_digit = 0;
    ones_digit = 0;
  end
end
 endmodule