
`timescale 1ns / 1ps

module RISCV_JumpBranch_TB();

reg clk;
reg rst;
integer cycle;
integer errors;
integer i;

RISCV_pipeline uut (
    .clk(clk),
    .rst(rst)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Write a 32-bit instruction into byte-addressed memory.
task put_inst;
    input integer address;
    input [31:0] instruction;
    begin
        uut.shared_memory.mem[address]   = instruction[7:0];
        uut.shared_memory.mem[address+1] = instruction[15:8];
        uut.shared_memory.mem[address+2] = instruction[23:16];
        uut.shared_memory.mem[address+3] = instruction[31:24];
    end
endtask

// Encode an I-type instruction.
function [31:0] encode_i;
    input integer imm;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opcode;
    begin
        encode_i = {imm[11:0], rs1, funct3, rd, opcode};
    end
endfunction

// Encode a B-type instruction.
function [31:0] encode_b;
    input integer imm;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] funct3;
    begin
        encode_b = {
            imm[12], imm[10:5],
            rs2, rs1, funct3,
            imm[4:1], imm[11],
            7'b1100011
        };
    end
endfunction

// Encode a JAL instruction.
function [31:0] encode_j;
    input integer imm;
    input [4:0] rd;
    begin
        encode_j = {
            imm[20], imm[10:1], imm[11],
            imm[19:12], rd, 7'b1101111
        };
    end
endfunction

// Check the register file through the WB interface.
// This checks committed values without assuming
// the RegisterFile's internal array name.
reg [31:0] observed [0:31];
reg [31:0] expected [0:31];
reg [31:0] final_pc;

initial begin
    rst = 1;
    cycle = 0;
    errors = 0;

    for (i = 0; i < 32; i = i + 1) begin
        observed[i] = 0;
        expected[i] = 0;
    end

    // Wait until UnifiedMemory initialization completes.
    #1;

    // Replace the old program with our test program.
    for (i = 0; i < 128; i = i + 1)
        uut.shared_memory.mem[i] = 8'h00;

    // PC 0: x1 = 5
    put_inst(0, encode_i(5, 0, 3'b000, 1, 7'b0010011));

    // PC 4: x2 = 10
    put_inst(4, encode_i(10, 0, 3'b000, 2, 7'b0010011));

    // PC 8: BEQ x1,x2,+8 -> NOT taken
    put_inst(8, encode_b(8, 2, 1, 3'b000));

    // PC 12: x3 = 1
    put_inst(12, encode_i(1, 0, 3'b000, 3, 7'b0010011));

    // PC 16: BNE x1,x2,+8 -> taken
    put_inst(16, encode_b(8, 2, 1, 3'b001));

    // PC 20: wrong-path x4 = 99
    put_inst(20, encode_i(99, 0, 3'b000, 4, 7'b0010011));

    // PC 24: BLT x1,x2,+8 -> taken
    put_inst(24, encode_b(8, 2, 1, 3'b100));

    // PC 28: wrong-path x5 = 99
    put_inst(28, encode_i(99, 0, 3'b000, 5, 7'b0010011));

    // PC 32: BGE x2,x1,+8 -> taken
    put_inst(32, encode_b(8, 1, 2, 3'b101));

    // PC 36: wrong-path x6 = 99
    put_inst(36, encode_i(99, 0, 3'b000, 6, 7'b0010011));

    // PC 40: BLTU x1,x2,+8 -> taken
    put_inst(40, encode_b(8, 2, 1, 3'b110));

    // PC 44: wrong-path x7 = 99
    put_inst(44, encode_i(99, 0, 3'b000, 7, 7'b0010011));

    // PC 48: BGEU x2,x1,+8 -> taken
    put_inst(48, encode_b(8, 1, 2, 3'b111));

    // PC 52: wrong-path x8 = 99
    put_inst(52, encode_i(99, 0, 3'b000, 8, 7'b0010011));

    // PC 56: JAL x9,+8 -> x9=60
    put_inst(56, encode_j(8, 9));

    // PC 60: wrong-path x10 = 99
    put_inst(60, encode_i(99, 0, 3'b000, 10, 7'b0010011));

    // PC 64: x11 = 80 (JALR target)
    put_inst(64, encode_i(80, 0, 3'b000, 11, 7'b0010011));

    // PC 68: JALR x12,0(x11) -> x12=72, PC=80
    put_inst(68, encode_i(0, 11, 3'b000, 12, 7'b1100111));

    // PC 72: wrong-path x13 = 99
    put_inst(72, encode_i(99, 0, 3'b000, 13, 7'b0010011));

    // PC 76: wrong-path x14 = 99
    put_inst(76, encode_i(99, 0, 3'b000, 14, 7'b0010011));

    // PC 80: x15 = 7
    put_inst(80, encode_i(7, 0, 3'b000, 15, 7'b0010011));

    // PC 84: loop here forever (JAL x0,0)
    put_inst(84, encode_j(0, 0));

    expected[1]  = 5;
    expected[2]  = 10;
    expected[3]  = 1;
    expected[9]  = 60;
    expected[11] = 80;
    expected[12] = 72;
    expected[15] = 7;

    #11;
    rst = 0;

    // Allow pipeline to execute and settle.
    #600;

    $display("");
    $display("====================================");
    $display("     BRANCH / JUMP TEST RESULTS");
    $display("====================================");

    for (i = 1; i <= 15; i = i + 1) begin
        if (observed[i] === expected[i])
            $display("PASS x%0d = %0d", i, observed[i]);
        else begin
            $display("FAIL x%0d expected=%0d actual=%0d",
                     i, expected[i], observed[i]);
            errors = errors + 1;
        end
    end

    if (errors == 0)
        $display("ALL BRANCH/JUMP TESTS PASSED");
    else
        $display("%0d REGISTER CHECKS FAILED", errors);

    $finish;
end

// Record register writeback events.
always @(negedge clk) begin
    if (!rst) begin
        cycle = cycle + 1;

        if (uut.MEM_WB_Ctrl[1] &&
            uut.MEM_WB_Rd != 0) begin
            observed[uut.MEM_WB_Rd] = uut.WriteData;

            $display("CYCLE %0d WB x%0d = %h",
                     cycle,
                     uut.MEM_WB_Rd,
                     uut.WriteData);
        end

        if (uut.and_out)
            $display("CYCLE %0d REDIRECT target=%h jump=%b",
                     cycle,
                     uut.EX_MEM_BranchAddOut,
                     uut.EX_MEM_Jump);
    end
end

endmodule
