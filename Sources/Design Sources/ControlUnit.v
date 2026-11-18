
`timescale 1ns / 1ps

module ControlUnit(
    input [31:0] inst,
    output Branch,
    output MemRead,
    output MemtoReg,
    output [1:0] ALUOp,
    output MemWrite,
    output ALUSrc,
    output RegWrite,
    output Jump,
    output JalrSel,
    output Halt
);

wire [6:0] opcode;
assign opcode = inst[6:0];

wire Rtype, Itype, Load, Store, BranchType;
wire JAL, JALR, LUI, AUIPC;

assign Rtype      = (opcode == 7'b0110011);
assign Itype      = (opcode == 7'b0010011);
assign Load       = (opcode == 7'b0000011);
assign Store      = (opcode == 7'b0100011);
assign BranchType = (opcode == 7'b1100011);
assign JAL        = (opcode == 7'b1101111);
assign JALR       = (opcode == 7'b1100111);
assign LUI        = (opcode == 7'b0110111);
assign AUIPC      = (opcode == 7'b0010111);
assign SYSTEM     = (opcode == 7'b1110011);   // for ebreak 


assign Branch   = BranchType;
assign MemRead  = Load;
assign MemtoReg = Load;
assign MemWrite = Store;

assign ALUSrc = Itype | Load | Store | JALR | LUI | AUIPC;

assign RegWrite = Rtype | Itype | Load | JAL | JALR | LUI | AUIPC;

assign ALUOp = (Rtype | Itype) ? 2'b10 :
               BranchType ? 2'b01 : 2'b00;

assign Jump    = JAL | JALR;
assign JalrSel = JALR;


assign Halt = SYSTEM && (inst[14:12] == 3'b000) && (inst[31:20] == 12'b000000000001);

endmodule
