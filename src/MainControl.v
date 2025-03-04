module MainControl (op, control);
  // Inputs:
  input [3:0] op;  // 4-bit opcode from instruction field

  // Outputs:
  output reg [6:0] control; // Control signals for CPU execution

  // Control signals: reg_dst, alu_src, reg_write, alu_ctl
  always @(op) 
    case (op)
      // R-type instructions
      4'b0000: control = 7'b1_0_1_0010;  // add  | rd, rs, rt | rd = rs + rt
      4'b0001: control = 7'b1_0_1_0110;  // sub  | rd, rs, rt | rd = rs - rt
      4'b0010: control = 7'b1_0_1_0000;  // and  | rd, rs, rt | rd = rs & rt
      4'b0011: control = 7'b1_0_1_0001;  // or   | rd, rs, rt | rd = rs | rt
      4'b0100: control = 7'b1_0_1_1100;  // nor  | rd, rs, rt | rd = ~(rs | rt)
      4'b0101: control = 7'b1_0_1_1101;  // nand | rd, rs, rt | rd = ~(rs % rt)
      4'b0110: control = 7'b1_0_1_0111;  // slt  | rd, rs, rt | rd = (rs < rt) ? 1 : 0

      // I-type instructions
      4'b0111: control = 7'b0_1_1_0010;  // addi | rd, rs, const8 | rd = rs + const8
    endcase
endmodule