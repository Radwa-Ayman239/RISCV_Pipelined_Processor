`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2026 08:29:58 AM
// Design Name: 
// Module Name: MultiplierDivider
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


module MultiplierDivider(
    input  [31:0] A,
    input  [31:0] B,
    input  [2:0]  funct3,
    output reg [31:0] Result
);

    wire signed [63:0] sA = $signed(A);
    wire signed [63:0] sB = $signed(B);
    wire [63:0] uA = {32'b0, A};
    wire [63:0] uB = {32'b0, B};
    
    always @(*) begin
        case (funct3)
            // Multiplication
            3'b000: Result = (sA * sB);                       // MUL
            3'b001: Result = (sA * sB) >> 32;                 // MULH
            3'b010: Result = (sA * uB) >> 32;                 // MULHSU
            3'b011: Result = (uA * uB) >> 32;                 // MULHU
            
            // Division and Remainder (Fixed Type Coercion)
            3'b100: begin // DIV (Signed)
                if (B == 32'b0) Result = 32'hFFFFFFFF;
                else Result = $signed(A) / $signed(B);
            end
            3'b101: begin // DIVU (Unsigned)
                if (B == 32'b0) Result = 32'hFFFFFFFF;
                else Result = A / B;
            end
            3'b110: begin // REM (Signed)
                if (B == 32'b0) Result = A;
                else Result = $signed(A) % $signed(B);
            end
            3'b111: begin // REMU (Unsigned)
                if (B == 32'b0) Result = A;
                else Result = A % B;
            end
            default: Result = 32'b0;
        endcase
    end
endmodule









