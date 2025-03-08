module FullAdder (a, b, cin, sum, cout);
   input a, b, cin;
   output sum, cout;
   wire axb, and1, and2;
   
   // Sum calculation
   xor (axb, a, b);
   xor (sum, axb, cin);

   // Carry-out calculation
   and (and1, axb, cin);
   and (and2, a, b);
   or  (cout, and1, and2);
endmodule