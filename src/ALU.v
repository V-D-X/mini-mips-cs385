module ALU (alu_ctl, a, b, alu_out, zero); // TODO: this needs to be gate level
  // Inputs:
  input [3:0] alu_ctl;  // ALU control signals (determines operation: ADD, SUB, etc.)
  input [15:0] a, b;    // ALU inputs (operands from registers or immediate values)

  // Outputs:
  output reg [15:0] alu_out; // ALU result
  output zero;               // Zero flag (1 if alu_out == 0, otherwise 0)

  always @(alu_ctl, a, b) // ALU reevaluates when control or inputs change
    case (alu_ctl)
      4'b0000: alu_out = a & b;  // AND
      4'b0001: alu_out = a | b;  // OR
      4'b0010: alu_out = a + b;  // ADD
      4'b0110: alu_out = a - b;  // SUBTRACT
      4'b0111: alu_out = (a < b) ? 1 : 0; // SET-LESS-THAN (SLT)
      4'b1100: alu_out = ~a & ~b; // NAND
      4'b1101: alu_out = ~a | ~b; // NOR
    endcase

  // Zero flag is set if ALU output is 0
  assign zero = (alu_out == 0);
endmodule