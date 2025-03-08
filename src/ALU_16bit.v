module ALU_16bit (op, a, b, result, zero);
   input [15:0] a, b;   // 16-bit input operands
   input [3:0] op;      // 4-bit operation selector
   output [15:0] result; // 16-bit output result
   output zero;         // Zero flag (1 if result is zero)
   
   wire [15:0] carry;   // Carry wires for addition/subtraction
   wire set;            // Set-less-than signal from MSB ALU

   // Instantiate 1-bit ALUs for each bit position
   ALU_1bit alu0  (a[0], b[0], op[3], op[2], op[1:0], set, op[2], carry[0], result[0]);
   ALU_1bit alu1  (a[1], b[1], op[3], op[2], op[1:0], 1'b0, carry[0], carry[1], result[1]);
   ALU_1bit alu2  (a[2], b[2], op[3], op[2], op[1:0], 1'b0, carry[1], carry[2], result[2]);
   ALU_1bit alu3  (a[3], b[3], op[3], op[2], op[1:0], 1'b0, carry[2], carry[3], result[3]);
   ALU_1bit alu4  (a[4], b[4], op[3], op[2], op[1:0], 1'b0, carry[3], carry[4], result[4]);
   ALU_1bit alu5  (a[5], b[5], op[3], op[2], op[1:0], 1'b0, carry[4], carry[5], result[5]);
   ALU_1bit alu6  (a[6], b[6], op[3], op[2], op[1:0], 1'b0, carry[5], carry[6], result[6]);
   ALU_1bit alu7  (a[7], b[7], op[3], op[2], op[1:0], 1'b0, carry[6], carry[7], result[7]);
   ALU_1bit alu8  (a[8], b[8], op[3], op[2], op[1:0], 1'b0, carry[7], carry[8], result[8]);
   ALU_1bit alu9  (a[9], b[9], op[3], op[2], op[1:0], 1'b0, carry[8], carry[9], result[9]);
   ALU_1bit alu10 (a[10], b[10], op[3], op[2], op[1:0], 1'b0, carry[9], carry[10], result[10]);
   ALU_1bit alu11 (a[11], b[11], op[3], op[2], op[1:0], 1'b0, carry[10], carry[11], result[11]);
   ALU_1bit alu12 (a[12], b[12], op[3], op[2], op[1:0], 1'b0, carry[11], carry[12], result[12]);
   ALU_1bit alu13 (a[13], b[13], op[3], op[2], op[1:0], 1'b0, carry[12], carry[13], result[13]);
   ALU_1bit alu14 (a[14], b[14], op[3], op[2], op[1:0], 1'b0, carry[13], carry[14], result[14]);
   ALU_MSB alu15 (a[15], b[15], op[3], op[2], op[1:0], 1'b0, carry[14], carry[15], result[15], set);
   
   // NOR gate to check if result is zero
   nor zero_check(zero, result[0], result[1], result[2], result[3], 
                       result[4], result[5], result[6], result[7], 
                       result[8], result[9], result[10], result[11], 
                       result[12], result[13], result[14], result[15]);
endmodule