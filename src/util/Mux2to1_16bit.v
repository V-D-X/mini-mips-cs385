module Mux2to1_16bit (in0, in1, sel, out);
  input [15:0] in0, in1;
  input sel;
  output [15:0] out;

  genvar i; // You can use a loop to do this cleanly
  generate
    for (i = 0; i < 16; i = i + 1) begin : mux_loop
      Mux2to1 m (in0[i], in1[i], sel, out[i]);
    end
  endgenerate
endmodule