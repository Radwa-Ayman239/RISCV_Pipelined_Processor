`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2026 12:43:45 AM
// Design Name: 
// Module Name: DFlipFlop_negative
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


module DFlipFlop_negative(

input clk,
input rst, 
input D, 
output reg Q
);
always @ (negedge clk or posedge rst) begin // Asynchronous Reset
if (rst)
Q <= 1'b0;
else 
Q <= D;
end
endmodule
