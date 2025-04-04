module CPU (clock, pc, alu_out, ir);
  // Inputs:
  input clock; // System clock
  
  // Outputs:
  output [15:0] alu_out, ir, pc; // ALU result, Instruction Register, Program Counter
  
  // Internal Registers and Wires:
  reg [15:0] pc;                // Program counter (holds current instruction address)
  reg [15:0] i_memory[0:1023];  // Instruction memory (holds test program instructions)
  reg [15:0] d_memory[0:1023];  // Data memory (holds test program data)
  wire [3:0] alu_ctl;           // ALU control signals (determines ALU operation)
  wire [1:0] wr;                // Register write address
  wire [15:0] ir, next_pc, a, b, alu_out, rd2, sign_extend;
  wire reg_write, unused, zero, reg_dst, alu_src;

  // ===========================
  // Test Program
  // ===========================

  // Instruction Formats:
  // - R-type: opcode | rs | rt | rd | unused6
  // - I-type: opcode | rs | rd | const8

  initial begin

    // Program: Swap memory cells if needed and compute absolute value of (t1 - t2)
    i_memory[0]  = 16'b1000_00_01_0000_0000;  // lw   $t1, 0($0)       ; Load word from d_memory[0] into $t1
    i_memory[1]  = 16'b1000_00_10_0000_0010;  // lw   $t2, 2($0)       ; Load word from d_memory[1] into $t2
    i_memory[2]  = 16'b0110_01_10_11_000000;  // slt  $t3, $t1, $t2    ; $t3 = ($t1 < $t2) ? 1 : 0

    i_memory[3]  = 16'b1010_11_00_0000_0010;  // beq  $t3, $0, +2      ; If $t1 >= $t2, skip swap (branch to i_memory[6])
    // i_memory[3] = 16'b1011_11_00_0000_0010;  // bne  $t3, $0, +2      ; If $t1 < $t2, skip swap (branch to i_memory[6])

    i_memory[4]  = 16'b1001_01_00_0000_0010;  // sw   $t1, 2($0)       ; Store $t1 into d_memory[1]
    i_memory[5]  = 16'b1001_10_00_0000_0000;  // sw   $t2, 0($0)       ; Store $t2 into d_memory[0]
    i_memory[6]  = 16'b1000_00_01_0000_0000;  // lw   $t1, 0($0)       ; Reload $t1 from d_memory[0]
    i_memory[7]  = 16'b1000_00_10_0000_0010;  // lw   $t2, 2($0)       ; Reload $t2 from d_memory[1]
    i_memory[8]  = 16'b0100_10_10_10_000000;  // nor  $t2, $t2, $t2    ; Bitwise NOT of $t2 (first step of two's complement negation)
    i_memory[9]  = 16'b0111_10_10_0000_0001;  // addi $t2, $t2, 1      ; $t2 = -$t2 (complete two's complement)
    i_memory[10] = 16'b0000_01_10_11_000000;  // add  $t3, $t1, $t2    ; $t3 = $t1 - $t2 (now absolute value)

    // Test Data Variant 1
    d_memory[0] = 32'd5;  // Initial value at address 0
    d_memory[1] = 32'd7;  // Initial value at address 4

    // Test Data Variant 2
    // d_memory[0] = 32'd7;  // Use to test behavior with larger value first
    // d_memory[1] = 32'd5;

  end
  
  // Initialize pc to 0
  initial pc = 0;

  // Instruction Fetch Stage
  assign ir = i_memory[pc >> 1]; // Fetch instruction from memory (divide pc by 2 for 16-bit words instead of 4 for 32-bit words)
  
  // Instruction Decode Stage
  Mux2to1_2bit reg_dst_mux(ir[9:8], ir[7:6], reg_dst, wr); // Select destination register (reg_dst Mux)
  Mux2to1_16bit alu_src_mux(rd2, sign_extend, alu_src, b); // Choose between immediate value or register (alu_src Mux)
  assign sign_extend = {{8{ir[7]}}, ir[7:0]}; // Sign extension (first 8 bits are the sign of ir[7], concatenate these together for 16-bit output to ALU)
  
  // CPU Components
  RegisterFile rf (ir[11:10], ir[9:8], wr, alu_out, reg_write, a, rd2, clock); // Register file
  ALU_16bit fetch (4'b0010, pc, 16'd2, next_pc, unused); // pc + 2 for next instruction fetch (our simple CPU has 2-byte words)
  ALU_16bit ex (alu_ctl, a, b, alu_out, zero); // ALU execution stage
  MainControl main_ctr (ir[15:12], {reg_dst, alu_src, reg_write, alu_ctl}); // Control unit (pull directly from ALU — no dedicated ALU control module in mini-MIPS)
  
  // Program Counter Update
  always @(negedge clock) begin 
    pc <= next_pc; // Update pc at each clock cycle (on falling edge)
  end
endmodule