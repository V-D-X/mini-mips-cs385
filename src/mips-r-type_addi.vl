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
module MainControl (Op, Control); // this is the code representation of the table on the board; we must implement the whole thing
  // Inputs:
  input [3:0] Op;  // 4-bit Opcode from instruction field; indicated by arrow down on top of table

  // Outputs:
  output reg [6:0] Control; // Control Signals for CPU execution; indicated by arrow up on top of table

  // Control Signals: RegDst, ALUSrc, RegWrite, ALUctl (direct ALU control for our simplified CPU model)
  always @(Op) case (Op)            // write a line for each instruction in the table. TODO: how did he make the table? tied to how ALU works
    4'b0000: Control = 7'b101_0010; // ADD (R-Type, Register-Register Arithmetic)
    4'b0111: Control = 7'b011_0010; // ADDI (Immediate Arithmetic)
    // TODO: add the remaining R-types in this format
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
    // Sample Instructions (32-bit MIPS encoding)
    IMemory[0] = 32'h2009000f;  // addi $t1, $0,  15   ($t1=15)
    IMemory[1] = 32'h200a0007;  // addi $t2, $0,  7    ($t2=7)    
    IMemory[2] = 32'h012a5824;  // and  $t3, $t1, $t2  ($t3=7) 
    IMemory[3] = 32'h012b5022;  // sub  $t2, $t1, $t3  ($t2=8)
    IMemory[4] = 32'h014b5025;  // or   $t2, $t2, $t3  ($t2=15)
    IMemory[5] = 32'h014b5820;  // add  $t3, $t2, $t3  ($t3=22)
    IMemory[6] = 32'h014b4827;  // nor  $t1, $t2, $t3  ($t1=-32)
    IMemory[7] = 32'h016a482a;  // slt  $t1, $t3, $t2  ($t1=0)
    IMemory[8] = 32'h014b482a;  // slt  $t1, $t2, $t3  ($t1=1)

    // Sample Instructions (16-bit MIPS encoding)
    // IMemory[0] = 16'b111_00_01_00001111;  // addi $t1, $0,  15   ($t1=15); this is literally the addi instruction itself, in binary
    // IMemory[2] = 16'b0000_01_10_11        // and  $t3, $t1, $t2  ($t3=7) 
    // TODO: implement the rest of these

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