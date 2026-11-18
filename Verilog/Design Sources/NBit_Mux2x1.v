`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:05:29 PM
// Design Name: 
// Module Name: NBit_Mux2x1
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

module NBit_Mux2x1  #(parameter N = 32)(
input [N-1:0] A,
input [N-1:0] B,
input Sel,
output [N-1:0] Out
    );
   
genvar i;
generate
for(i=0; i<N; i=i+1) begin: mux  
Mux2x1 n(A[i], B[i], Sel, Out[i]);
end  
endgenerate

endmodule

