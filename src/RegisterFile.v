module RegisterFile (rr1, rr2, wr, wd, reg_write, rd1, rd2, clock);
  // Inputs:
  input [1:0] rr1, rr2;  // Register Read Addresses (2-bit, since we have only 4 registers: $0-$3)
  input [1:0] wr;        // Register Write Address
  input [15:0] wd;       // Write Data (value to store in the register)
  input reg_write;       // Write Enable Signal (1 = Write, 0 = No Write)
  input clock;           // Clock signal (write happens on the falling edge)

  // Outputs:
  output [15:0] rd1, rd2;  // Register Data Outputs (values read from registers)

  reg [15:0] regs[0:3];  // Four 16-bit Registers ($0 - $3)

  // Register Read Logic: rd1 and rd2 hold values from the requested registers
  assign rd1 = regs[rr1];
  assign rd2 = regs[rr2];

  // Initialize register $0 to 0 (convention in MIPS)
  initial regs[0] = 0;

  // Register Write Logic: On falling edge of clock, update register wr with wd if reg_write is enabled
  always @(negedge clock)
    if (reg_write == 1 && wr != 0) // Do not write to $0 (fixed as zero)
      regs[wr] <= wd;
endmodule