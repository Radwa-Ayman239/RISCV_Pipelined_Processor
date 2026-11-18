`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:10:08 PM
// Design Name: 
// Module Name: NBitRegister
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


module NBitRegister #(parameter N = 32) (
    input clk,
    input rst,
    input load,
    input [N-1:0] D,
    output [N-1:0] Q
);

wire [N-1:0]mux_out;
genvar i;
generate
for(i=0; i<N; i=i+1) begin: NbitRegister
Mux2x1 mux(Q[i], D[i], load, mux_out[i]);
DFlipFlop ff(clk, rst,  mux_out[i], Q[i]);
end
endgenerate

endmodule

