module ALU_MSB (a, b, ainvert, binvert, op, less, carryin, carryout, result, sum);
   input a, b, less, carryin, ainvert, binvert;
   input [1:0] op;
   output carryout, result, sum;
   wire a1, b1, a_and_b, a_or_b;

   // Perform inversion if required
   xor (a1, a, ainvert);
   xor (b1, b, binvert);

   // Perform AND, OR operations
   and and_gate (a_and_b, a1, b1);
   or  or_gate (a_or_b, a1, b1);

   // Perform addition
   FullAdder adder (a1, b1, carryin, sum, carryout);

   // Select final result based on operation
   Mux4to1 result_mux (a_and_b, a_or_b, sum, less, op, result);
endmodule