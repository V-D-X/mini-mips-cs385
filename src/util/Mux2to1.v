module Mux2to1 (in0, in1, sel, out);
   input in0, in1, sel;
   output out;
   wire not_sel, and0, and1;

   not (not_sel, sel);
   and (and0, in0, not_sel);
   and (and1, in1, sel);
   or  (out, and0, and1);
endmodule