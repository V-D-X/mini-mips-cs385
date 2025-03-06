// Test module
module CPU_Testbench ();
  reg clock;
  wire signed [15:0] wd, ir, pc;

  // Instantiate CPU
  CPU test_cpu(clock, pc, wd, ir);

  // Clock pulse generation (toggle every 1 time unit)
  always #1 clock = ~clock;

  // Test execution
  initial begin
    $display ("Clock  PC  IR                                   WD");
    $monitor ("%b     %2d   %b  %3d (%b)", clock, pc, ir, wd, wd);
    clock = 1;
    #16 $finish;
  end
endmodule