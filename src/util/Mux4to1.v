module Mux4to1 (in0, in1, in2, in3, sel, out);
   input in0, in1, in2, in3;
   input [1:0] sel;
   output out;
   wire out0, out1;

   Mux2to1 mux0 (in0, in1, sel[0], out0);
   Mux2to1 mux1 (in2, in3, sel[0], out1);
   Mux2to1 mux_final (out0, out1, sel[1], out);
endmodule