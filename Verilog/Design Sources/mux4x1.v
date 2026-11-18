`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:04:38 PM
// Design Name: 
// Module Name: mux4x1
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

module mux4x1 #(parameter N = 32)(
    input [N-1:0] A,
    input [N-1:0] B,
    input [N-1:0] C,
    input [N-1:0] D,
    input [1:0] sel,
    output reg [N-1:0] out
);

always @(*) begin
    case (sel)
        2'b00: out = A;
        2'b01: out = B;
        2'b10: out = C;
        2'b11: out = D;
        default: out = {N{1'b0}};
    endcase
end

endmodule 
