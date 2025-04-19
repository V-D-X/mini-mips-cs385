// Test module
module test ();
  reg clock;
  wire signed [15:0] wd, ir, pc;
  CPU test_cpu(clock, wd, ir, pc);
  always #1 clock = ~clock;
  initial begin
    $display ("PC  IR                                WD");
    $monitor ("%2d  %b %2d (%b)",pc, ir, wd, wd);
    clock = 1;
    #20 $finish; // if extending test program, add +2 for each new line
  end
endmodule