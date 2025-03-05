module CPU (clock, pc, alu_out, ir);
  // Inputs:
  input clock; // System clock
  
  // Outputs:
  output [15:0] alu_out, ir, pc; // ALU result, Instruction Register, Program Counter
  
  // Internal Registers and Wires:
  reg [15:0] pc;                // Program counter (holds current instruction address)
  reg [15:0] i_memory[0:1023];  // Instruction memory (holds test program instructions)
  wire [3:0] alu_ctl;           // ALU control signals (determines ALU operation)
  wire [1:0] wr;                // Register write address
  wire [15:0] ir, next_pc, a, b, alu_out, rd2, sign_extend;
  
  // Initialize pc to 0
  initial pc = 0;

  // Instruction Fetch Stage
  assign ir = i_memory[pc >> 1]; // Fetch instruction from memory (divide pc by 2 for 16-bit words instead of 4 for 32-bit words)
  
  // Instruction Decode Stage
  assign wr = (reg_dst) ? ir[7:6] : ir[9:8]; // Select destination register (reg_dst Mux)
  assign b  = (alu_src) ? sign_extend : rd2;  // Choose between immediate value or register (alu_src Mux)
  assign sign_extend = {{8{ir[7]}}, ir[7:0]}; // Sign extension (first 8 bits are the sign of ir[7], concatenate these together for 16-bit output to ALU)
  
  // CPU Components
  RegisterFile rf (ir[11:10], ir[9:8], wr, alu_out, reg_write, a, rd2, clock); // Register file
  ALU fetch (4'b0010, pc, 16'd2, next_pc, unused); // pc + 2 for next instruction fetch (our simple CPU has 2-byte words)
  ALU ex (alu_ctl, a, b, alu_out, zero); // ALU execution stage
  MainControl main_ctr (ir[15:12], {reg_dst, alu_src, reg_write, alu_ctl}); // Control unit (pull directly from ALU — no dedicated ALU control module in mini-MIPS)
  
  // Program Counter Update
  always @(negedge clock) begin 
    pc <= next_pc; // Update pc at each clock cycle (on falling edge)
  end
endmodule
