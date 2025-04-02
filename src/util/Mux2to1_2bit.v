module Mux2to1_2bit (in0, in1, sel, out);
  input [1:0] in0, in1;
  input sel;
  output [1:0] out;

  Mux2to1 m0 (in0[0], in1[0], sel, out[0]);
  Mux2to1 m1 (in0[1], in1[1], sel, out[1]);
endmodule