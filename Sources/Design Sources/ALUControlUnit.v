`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:11:29 PM
// Design Name: 
// Module Name: ALUControlUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALUControlUnit(
    input [1:0] ALUOp,
    input [2:0] func3,
    input func7bit5,
    input IsRType,
    output reg [3:0] ALUSel
);

always @(*) begin
    case (ALUOp)

        2'b00: ALUSel = 4'b0010; // ADD for loads/stores

        2'b01: ALUSel = 4'b0110; // SUB for BEQ

        2'b10: begin
            case (func3)

              3'b000: ALUSel = (IsRType && func7bit5) ? 4'b0110 : 4'b0010;

                3'b001: ALUSel = 4'b0100; // SLL

                3'b010: ALUSel = 4'b1000; // SLT

                3'b011: ALUSel = 4'b1001; // SLTU

                3'b100: ALUSel = 4'b0011; // XOR

                3'b101: ALUSel = func7bit5 ? 4'b0111 : 4'b0101; // SRA / SRL

                3'b110: ALUSel = 4'b0001; // OR

                3'b111: ALUSel = 4'b0000; // AND

                default: ALUSel = 4'b0010;
            endcase
        end

        default: ALUSel = 4'b0010;

    endcase
end

endmodule
