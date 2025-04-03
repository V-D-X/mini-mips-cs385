module Mux2to1_5bit (in0, in1, sel, out);
  input [4:0] in0, in1;
  input sel;
  output [4:0] out;

  Mux2to1 m0 (in0[0], in1[0], sel, out[0]);
  Mux2to1 m1 (in0[1], in1[1], sel, out[1]);
  Mux2to1 m2 (in0[2], in1[2], sel, out[2]);
  Mux2to1 m3 (in0[3], in1[3], sel, out[3]);
  Mux2to1 m4 (in0[4], in1[4], sel, out[4]);
endmodule
