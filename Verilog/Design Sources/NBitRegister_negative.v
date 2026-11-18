`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2026 12:42:39 AM
// Design Name: 
// Module Name: NBitRegister_negative
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


module NBitRegister_negative#(parameter N = 32)(

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
DFlipFlop_negative ff(clk, rst,  mux_out[i], Q[i]);
end 
endgenerate

endmodule

