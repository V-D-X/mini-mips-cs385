module ALU16 (op, a, b, result, zero);
    input [3:0] op;
    input [15:0] a, b;
    output [15:0] result;
    output zero;

    wire [15:0] carry;
    wire set;
    
    // Instantiate 15 one-bit ALUs (bit positions 0-14)
    ALU1 alu0  (a[0],  b[0],  op[3], op[2], op[1:0], set, op[2], carry[0],  result[0]);
    ALU1 alu1  (a[1],  b[1],  op[3], op[2], op[1:0], 1'b0, carry[0], carry[1], result[1]);
    ALU1 alu2  (a[2],  b[2],  op[3], op[2], op[1:0], 1'b0, carry[1], carry[2], result[2]);
    ALU1 alu3  (a[3],  b[3],  op[3], op[2], op[1:0], 1'b0, carry[2], carry[3], result[3]);
    ALU1 alu4  (a[4],  b[4],  op[3], op[2], op[1:0], 1'b0, carry[3], carry[4], result[4]);
    ALU1 alu5  (a[5],  b[5],  op[3], op[2], op[1:0], 1'b0, carry[4], carry[5], result[5]);
    ALU1 alu6  (a[6],  b[6],  op[3], op[2], op[1:0], 1'b0, carry[5], carry[6], result[6]);
    ALU1 alu7  (a[7],  b[7],  op[3], op[2], op[1:0], 1'b0, carry[6], carry[7], result[7]);
    ALU1 alu8  (a[8],  b[8],  op[3], op[2], op[1:0], 1'b0, carry[7], carry[8], result[8]);
    ALU1 alu9  (a[9],  b[9],  op[3], op[2], op[1:0], 1'b0, carry[8], carry[9], result[9]);
    ALU1 alu10 (a[10], b[10], op[3], op[2], op[1:0], 1'b0, carry[9], carry[10], result[10]);
    ALU1 alu11 (a[11], b[11], op[3], op[2], op[1:0], 1'b0, carry[10], carry[11], result[11]);
    ALU1 alu12 (a[12], b[12], op[3], op[2], op[1:0], 1'b0, carry[11], carry[12], result[12]);
    ALU1 alu13 (a[13], b[13], op[3], op[2], op[1:0], 1'b0, carry[12], carry[13], result[13]);
    ALU1 alu14 (a[14], b[14], op[3], op[2], op[1:0], 1'b0, carry[13], carry[14], result[14]);
    
    // MSB ALU handles SLT and final carry bit
    ALUmsb alu15 (a[15], b[15], op[3], op[2], op[1:0], 1'b0, carry[14], carry[15], result[15], set);
    
    // NOR gate to check if result is zero
    assign zero = ~(result[0] | result[1] | result[2] | result[3] | 
                    result[4] | result[5] | result[6] | result[7] | 
                    result[8] | result[9] | result[10] | result[11] | 
                    result[12] | result[13] | result[14] | result[15]);

endmodule

module testALU16;
    reg signed [15:0] a, b;
    reg [3:0] op;
    wire signed [15:0] result;
    wire zero;

    ALU16 alu (op, a, b, result, zero);

    initial begin
        $display("op   a               b               result          zero");
        $monitor("%b %b(%d) %b(%d) %b(%d) %b", op, a, a, b, b, result, result, zero);

        op = 4'b0000; a = 16'b0000000000000111; b = 16'b0000000000000001;  // AND
        #1 op = 4'b0001; a = 16'b0000000000000101; b = 16'b0000000000000010;  // OR
        #1 op = 4'b0010; a = 16'b0000000000000100; b = 16'b0000000000000010;  // ADD
        #1 op = 4'b0110; a = 16'b0000000000000101; b = 16'b0000000000000011;  // SUB
        #1 op = 4'b0111; a = 16'b0000000000000101; b = 16'b0000000000000001;  // SLT
        #1 op = 4'b1100; a = 16'b0000000000000101; b = 16'b0000000000000010;  // NOR
        #1 op = 4'b1101; a = 16'b0000000000000101; b = 16'b0000000000000010;  // NAND
    end
endmodule

module InstructionMemory (PC, Instruction);
    input [15:0] PC;
    output [15:0] Instruction;

    reg [15:0] IMemory[0:255];  // 256 words of 16-bit instruction memory

    initial begin
        // Test program with ADDI, ADD, AND, OR, SUB, NOR, NAND, SLT
        IMemory[0] = 16'b0111_0000_0000_1111; // addi $1, $0, 15  ($1 = 15)
        IMemory[1] = 16'b0111_0000_0010_0111; // addi $2, $0, 7   ($2 = 7)
        IMemory[2] = 16'b0010_0001_0011_0000; // and  $3, $1, $2  ($3 = 7)
        IMemory[3] = 16'b0011_0001_0100_0000; // or   $4, $1, $3  ($4 = 15)
        IMemory[4] = 16'b0000_0010_0101_0000; // add  $5, $2, $4  ($5 = 22)
        IMemory[5] = 16'b0001_0001_0010_0000; // sub  $2, $1, $3  ($2 = 8)
        IMemory[6] = 16'b0100_0100_0110_0000; // nor  $6, $4, $5  ($6 = -32)
        IMemory[7] = 16'b0110_0101_0111_0000; // slt  $7, $5, $4  ($7 = 0)
    end

    assign Instruction = IMemory[PC[7:0]];  // Word-addressed 16-bit instruction
endmodule

module RegisterFile (RR1, RR2, WR, WD, RegWrite, RD1, RD2, clock);
    input [1:0] RR1, RR2, WR;
    input [15:0] WD;
    input RegWrite, clock;
    output [15:0] RD1, RD2;

    reg [15:0] Regs[0:3];  // 4 registers: $0, $1, $2, $3

    assign RD1 = Regs[RR1];
    assign RD2 = Regs[RR2];

    initial Regs[0] = 0;  // Register $0 is always 0

    always @(negedge clock)
        if (RegWrite && WR != 0) 
            Regs[WR] <= WD;
endmodule

module CPU (clock, PC, ALUOut, IR);
    input clock;
    output [15:0] ALUOut, IR, PC;
    reg [15:0] PC;
    wire [15:0] NextPC, A, B, RD2, SignExtend;
    wire [3:0] ALUctl;
    wire [1:0] ALUOp, WR;
    
    InstructionMemory IM (PC, IR);
    RegisterFile RF (IR[11:10], IR[9:8], WR, ALUOut, 1'b1, A, RD2, clock);
    ALU16 ALU (ALUctl, A, B, ALUOut, Unused);

    assign WR = (IR[15:12] == 4'b0111) ? IR[11:10] : IR[9:8];  // WR for addi
    assign B = (IR[15:12] == 4'b0111) ? SignExtend : RD2;  // Immediate or Register
    assign SignExtend = {{8{IR[7]}}, IR[7:0]};  // Sign Extend

    always @(negedge clock) PC <= PC + 2;
endmodule
