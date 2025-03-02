// 16-bit MIPS CPU - Single Cycle Implementation (R-Type & ADDI Instructions)
// This is a simplified version of MIPS CPU, modified from a 32-bit implementation.
// Supports R-type (e.g., ADD, SUB) and immediate arithmetic (e.g., ADDI).

//========================
// Register File Module
//========================
module reg_file (RR1, RR2, WR, WD, RegWrite, RD1, RD2, clock); // adapted for 16-bit CPU
  // Inputs:
  input [1:0] RR1, RR2;  // Register Read Addresses (2-bit, since we have only 4 registers: $0-$3)
  input [1:0] WR;        // Register Write Address
  input [15:0] WD;       // Write Data (value to store in the register)
  input RegWrite;        // Write Enable Signal (1 = Write, 0 = No Write)
  input clock;           // Clock signal (write happens on the falling edge)

  // Outputs:
  output [15:0] RD1, RD2;  // Register Data Outputs (values read from registers)

  reg [15:0] Regs[0:3];  // Four 16-bit Registers ($0 - $3)

  // Register Read Logic: RD1 and RD2 hold values from the requested registers
  assign RD1 = Regs[RR1];
  assign RD2 = Regs[RR2];

  // Initialize register $0 to 0 (convention in MIPS)
  initial Regs[0] = 0;

  // Register Write Logic: On falling edge of clock, update register WR with WD if RegWrite is enabled
  always @(negedge clock)
    if (RegWrite == 1 && WR != 0) // Do not write to $0 (fixed as zero)
      Regs[WR] <= WD;
      
endmodule

//========================
// Arithmetic Logic Unit (ALU) Module
//========================
module alu (ALUctl, A, B, ALUOut, Zero); // this needs to be gate level
  // Inputs:
  input [3:0] ALUctl;  // ALU Control Signals (determines operation: ADD, SUB, etc.)
  input [15:0] A, B;   // ALU Inputs (operands from registers or immediate values)

  // Outputs:
  output reg [15:0] ALUOut; // ALU Result
  output Zero;              // Zero Flag (1 if ALUOut == 0, otherwise 0)

  always @(ALUctl, A, B) // ALU reevaluates when control or inputs change
    case (ALUctl)
      4'b0000: ALUOut = A & B;  // AND
      4'b0001: ALUOut = A | B;  // OR
      4'b0010: ALUOut = A + B;  // ADD
      4'b0110: ALUOut = A - B;  // SUBTRACT
      4'b0111: ALUOut = (A < B) ? 1 : 0; // SET-LESS-THAN (SLT)
      4'b1100: ALUOut = ~A & ~B; // NAND
      4'b1101: ALUOut = ~A | ~B; // NOR
    endcase

  // Zero flag is set if ALU output is 0
  // Not used for now, needed for future CPU development
  assign Zero = (ALUOut == 0);
endmodule

//========================
// Main Control Unit
//========================
module MainControl (Op, Control);
  // Inputs:
  input [3:0] Op;  // 4-bit Opcode from instruction field

  // Outputs:
  output reg [6:0] Control; // Control Signals for CPU execution

  // Control Signals: RegDst_ALUSrc_RegWrite_ALUctl
  always @(Op) case (Op)
    // R-type instructions
    4'b0000: Control = 7'b1_0_1_0010;  // add  | rd, rs, rt | rd =   rs + rt
    4'b0001: Control = 7'b1_0_1_0110;  // sub  | rd, rs, rt | rd =   rs - rt
    4'b0010: Control = 7'b1_0_1_0000;  // and  | rd, rs, rt | rd =   rs & rt
    4'b0011: Control = 7'b1_0_1_0001;  // or   | rd, rs, rt | rd =   rs | rt
    4'b0100: Control = 7'b1_0_1_1100;  // nor  | rd, rs, rt | rd = ~(rs | rt)
    4'b0101: Control = 7'b1_0_1_1101;  // nand | rd, rs, rt | rd = ~(rs % rt)
    4'b0110: Control = 7'b1_0_1_0111;  // slt  | rd, rs, rt | rd =  (rs < rt) ? 1 : 0

    // I-type instructions
    4'b0111: Control = 7'b0_1_1_0010;  // addi | rd, rs, const8 | rd = rs + const8
  endcase
endmodule


module CPU (clock, PC, ALUOut, IR);
  // Inputs:
  input clock; // System Clock
  
  // Outputs:
  output [15:0] ALUOut, IR, PC; // ALU result, Instruction Register, Program Counter
  
  // Internal Registers and Wires:
  reg [15:0] PC; // Program Counter (holds current instruction address)
  reg [15:0] IMemory[0:1023]; // Instruction Memory (Holds the program instructions)
  wire [15:0] IR, NextPC, A, B, ALUOut, RD2, SignExtend;
  wire [3:0] ALUctl; // ALU Control Signals (determines ALU operation)
  wire [1:0] WR;  // Register Write Address
  
  // ===========================
  // Test Program (Stored in IMemory)
  // ===========================
  initial begin 
    // Sample Instructions (16-bit MIPS encoding)
    // R-type format: opcode_rs_rt_rd
    // I-type format: opcode_rs_rd_const8
    IMemory[0] = 16'b0111_00_01_00001111;   // addi $t1, $0,  15   ($t1=15)
    IMemory[1] = 16'b0111_00_10_00000111;   // addi $t2, $0,  7    ($t2=7) 
    IMemory[2] = 16'b0010_01_10_11_000000;  // and  $t3, $t1, $t2  ($t3=7)
    IMemory[3] = 16'b0001_01_11_10_000000;  // sub  $t2, $t1, $t3  ($t2=8)
    IMemory[4] = 16'b0011_10_11_10_000000;  // or   $t2, $t2, $t3  ($t2=15)
    IMemory[5] = 16'b0000_10_11_11_000000;  // add  $t3, $t2, $t3  ($t3=22)
    IMemory[6] = 16'b0100_10_11_01_000000;  // nor  $t1, $t2, $t3  ($t1=-32)
    IMemory[7] = 16'b0110_11_10_01_000000;  // slt  $t1, $t3, $t2  ($t1=0)
    IMemory[8] = 16'b0110_10_11_01_000000;  // slt  $t1, $t2, $t3  ($t1=1)
  end
  
  // Initialize PC to 0
  initial PC = 0;

  // ===========================
  // Instruction Fetch Stage
  // ===========================
  assign IR = IMemory[PC >> 1]; // Fetch instruction from memory (divide PC by 2 for 16-bit words instead of 4 for 32-bit words)
  
  // ===========================
  // Instruction Decode Stage
  // ===========================
  assign WR = (RegDst) ? IR[7:6] : IR[9:8]; // Select destination register (RegDst Mux)
  assign B  = (ALUSrc) ? SignExtend : RD2;  // Choose between immediate value or register (ALUSrc Mux)
  assign SignExtend = {{8{IR[7]}}, IR[7:0]}; // Sign Extension (first 8 bytes are the sign of IR[7], concatenate these together for 16-bit output to ALU)
  
  // ===========================
  // CPU Components
  // ===========================
  reg_file rf (IR[11:10], IR[9:8], WR, ALUOut, RegWrite, A, RD2, clock); // Register File
  alu fetch (4'b0010, PC, 16'd2, NextPC, Unused); // PC + 2 for next instruction fetch (our simple CPU has 2-byte words)
  alu ex (ALUctl, A, B, ALUOut, Zero); // ALU Execution Stage
  MainControl MainCtr (IR[15:12], {RegDst, ALUSrc, RegWrite, ALUctl}); // Control Unit (pull directly from ALU — no dedicated ALUControl module in mini-mips)
  
  // ===========================
  // Program Counter Update
  // ===========================
  always @(negedge clock) begin 
    PC <= NextPC; // Update PC at each clock cycle (on falling edge)
  end
endmodule

// ===========================
// Testbench Module
// ===========================
module test ();
  reg clock;
  wire signed [15:0] WD, IR, PC;
  
  // Instantiate CPU
  CPU test_cpu(clock, PC, WD, IR);
  
  // Clock Generation (Toggle every 1 time unit)
  always #1 clock = ~clock;
  
  // Test Execution
  initial begin
    $display ("Clock PC   IR                                 WD");
    $monitor ("%b     %2d   %b  %3d (%b)", clock, PC, IR, WD, WD);
    clock = 1;
    #16 $finish;
  end
endmodule

/* Output
Clock PC   IR                                 WD
1      0   00100000000010010000000000001111   15 (00000000000000000000000000001111)
0      4   00100000000010100000000000000111    7 (00000000000000000000000000000111)
1      4   00100000000010100000000000000111    7 (00000000000000000000000000000111)
0      8   00000001001010100101100000100100    7 (00000000000000000000000000000111)
1      8   00000001001010100101100000100100    7 (00000000000000000000000000000111)
0     12   00000001001010110101000000100010    8 (00000000000000000000000000001000)
1     12   00000001001010110101000000100010    8 (00000000000000000000000000001000)
0     16   00000001010010110101000000100101   15 (00000000000000000000000000001111)
1     16   00000001010010110101000000100101   15 (00000000000000000000000000001111)
0     20   00000001010010110101100000100000   22 (00000000000000000000000000010110)
1     20   00000001010010110101100000100000   22 (00000000000000000000000000010110)
0     24   00000001010010110100100000100111  -32 (11111111111111111111111111100000)
1     24   00000001010010110100100000100111  -32 (11111111111111111111111111100000)
0     28   00000001011010100100100000101010    0 (00000000000000000000000000000000)
1     28   00000001011010100100100000101010    0 (00000000000000000000000000000000)
0     32   00000001010010110100100000101010    1 (00000000000000000000000000000001)
1     32   00000001010010110100100000101010    1 (00000000000000000000000000000001)
*/