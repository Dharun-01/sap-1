`timescale 1ns/1ps

module control_unit ( 
  input reset, 
  input [3:0] opcode, // From Instruction Register
  input [2:0] step, // From Step Counter
  input [1:0] flag, // From Flag
  
  output reg en_ir_out,
  output reg en_ir_in,
  output reg en_ras_in,
  output reg en_a_in,
  output reg en_ram_out,
  output reg en_a_out,
  output reg en_b_in,
  output reg en_pc_in,
  output reg en_pc_out,
  output reg en_ram_in,
  output reg en_add_sub,
  output reg en_hlt,
  output reg en_alu_out,
  output reg en_out_in,
  output reg en_pc_latcher,
  output reg en_reset_step_counter
  );

// Opcodes
localparam OP_LDA = 4'b0000;
localparam OP_LDI = 4'b0001;
localparam OP_ADD = 4'b0010;
localparam OP_SUB = 4'b0011;
localparam OP_STA = 4'b0100;
localparam OP_JMP = 4'b0101;
localparam OP_JC  = 4'b0110;
localparam OP_JZ  = 4'b0111;
localparam OP_OUT = 4'b1000;
localparam OP_HLT = 4'b1001;

// T-States (Ring Counter Steps) 
localparam T0 = 3'd0;
localparam T1 = 3'd1;
localparam T2 = 3'd2;
localparam T3 = 3'd3;
localparam T4 = 3'd4;
localparam T5 = 3'd5;
// Task Block to clear the BUS control lines cleanly.

task clear_control_word;
begin 
en_ir_out     = 0;
en_ir_in      = 0;
en_ras_in     = 0;
en_a_in       = 0;
en_ram_out    = 0;
en_a_out      = 0;
en_b_in       = 0;
en_pc_in      = 0;
en_pc_out     = 0;
en_ram_in     = 0;
en_add_sub    = 0;
en_hlt        = 0;
en_alu_out    = 0;
en_out_in     = 0;
en_pc_latcher = 0;
en_reset_step_counter = 0;
end
endtask

always @ (*) begin 
  // Establishing safe default baseline state
  clear_control_word();

  if (!reset) begin 
     case (step)
     // --- FETCH CYCLE (Same for every instruction) ---
    T0: begin 
      en_pc_out = 1; // Move Program Counter address onto bus
      en_ras_in = 1; // Latch it into RAM Address Selector Register
    end
    T1: begin 
      en_ram_out = 1; // Assert RAM data out onto the bus
      en_ir_in   = 1; // Latch it into the Instruction Register
      en_pc_latcher = 1; // Increment PC for the next clock cycle
    end

    // --- EXECUTION CYCLE (Decided by Opcode) ---
    T2: begin 
     case (opcode) 
      OP_LDA: begin en_ir_out = 1; en_ras_in = 1;                             end // Move address to RAS
      OP_LDI: begin en_ir_out = 1; en_a_in   = 1;                             end
      OP_ADD: begin en_ir_out = 1; en_ras_in = 1;                             end
      OP_SUB: begin en_ir_out = 1; en_ras_in = 1;                             end
      OP_STA: begin en_ir_out = 1; en_ras_in = 1;                             end
      OP_JMP: begin en_ir_out = 1; en_pc_in  = 1; en_pc_latcher = 1;          end

     // --- CONDITIONAL JUMPS --- 
      OP_JC : begin 
           if (flag[1]) begin 
            en_ir_out = 1; 
            en_pc_in  = 1; 
            en_pc_latcher = 1; 
            end
       end
       
      OP_JZ : begin
        if (flag[0]) begin // Assuming flag[0] is Zero Flag (Z)
           en_ir_out = 1; 
           en_pc_in  = 1; 
           en_pc_latcher = 1; 
           end
       end
      OP_OUT: begin 
        en_a_out  = 1; en_out_in = 1;
      end

      OP_HLT: begin en_hlt    = 1;                                     end
      default: clear_control_word();
     endcase
    end
    T3: begin 
      case (opcode)
      OP_LDA: begin 
        en_ram_out = 1; en_a_in = 1; 
        end
      OP_LDI: begin en_reset_step_counter = 1;                         end
      OP_JMP: begin en_reset_step_counter = 1;                         end
      OP_JC: begin en_reset_step_counter = 1;                          end // If flag is 0, it falls through and remains a safe NOP (No Operation)
      OP_JZ: begin en_reset_step_counter = 1;                          end // If flag is 0, it falls through and remains a safe NOP (No Operation)
      OP_OUT: begin en_reset_step_counter = 1;                         end
      OP_ADD: begin en_ram_out = 1; en_b_in   = 1;                     end
      OP_SUB: begin en_ram_out = 1; en_b_in   = 1;                     end
      OP_STA: begin 
        en_a_out   = 1; en_ram_in = 1;
        end
      default: clear_control_word();
      endcase
    end
    T4: begin 
      case (opcode) 
      OP_LDA: begin en_reset_step_counter = 1;                         end
       OP_ADD: begin 
        en_alu_out = 1; en_a_in = 1;
        end
        OP_STA: begin en_reset_step_counter = 1;                         end
       OP_SUB: begin 
        en_alu_out = 1; en_a_in = 1; en_add_sub = 1; 
        end
       default: clear_control_word();
      endcase
    end
    T5: begin 
      case (opcode) 
      OP_ADD: begin en_reset_step_counter = 1;                         end
      OP_SUB: begin en_reset_step_counter = 1;                         end
      default: clear_control_word();
      endcase
    end
    default: clear_control_word();
     endcase
  end
end
endmodule