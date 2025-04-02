module MainControl (op, control);
  // Inputs:
  input [3:0] op;  // 4-bit opcode from instruction field

  // Outputs:
  output reg [10:0] control; // Control signals for CPU execution
  // Format: reg_dst, alu_src, mem_to_reg, reg_write, mem_write, beq, bne, alu_ctl[3:0]

  always @(op)
    case (op)
      // R-type instructions
      4'b0000: control = 11'b1_0_0_1_0_0_0_0010;  // add   | rd, rs, rt     | rd = rs + rt
      4'b0001: control = 11'b1_0_0_1_0_0_0_0110;  // sub   | rd, rs, rt     | rd = rs - rt
      4'b0010: control = 11'b1_0_0_1_0_0_0_0000;  // and   | rd, rs, rt     | rd = rs & rt
      4'b0011: control = 11'b1_0_0_1_0_0_0_0001;  // or    | rd, rs, rt     | rd = rs | rt
      4'b0100: control = 11'b1_0_0_1_0_0_0_1100;  // nor   | rd, rs, rt     | rd = ~(rs | rt)
      4'b0101: control = 11'b1_0_0_1_0_0_0_1101;  // nand  | rd, rs, rt     | rd = ~(rs & rt)
      4'b0110: control = 11'b1_0_0_1_0_0_0_0111;  // slt   | rd, rs, rt     | rd = (rs < rt) ? 1 : 0

      // I-type instructions
      4'b0111: control = 11'b0_1_0_1_0_0_0_0010;  // addi  | rd, rs, const8 | rd = rs + const8
      4'b1000: control = 11'b0_1_1_1_0_0_0_0010;  // lw    | rd, off8(rs)   | rd = mem16[rs + off8]
      4'b1001: control = 11'b0_1_0_0_1_0_0_0010;  // sw    | rs, off8(rt)   | mem16[rt + off8] = rs
      4'b1010: control = 11'b0_0_0_0_0_1_0_0110;  // beq   | rs, rt, off8   | if (rs == rt) PC += off8
      4'b1011: control = 11'b0_0_0_0_0_0_1_0110;  // bne   | rs, rt, off8   | if (rs != rt) PC += off8
    endcase
endmodule