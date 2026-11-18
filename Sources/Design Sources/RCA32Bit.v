`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2026 05:25:11 AM
// Design Name: 
// Module Name: RCA32Bit
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


module RCA32Bit(
    input [31:0] A, [31:0]B, 
    input cin,
    output [31:0] sum, 
    output cout

    );
    
    




    
wire [32:0]c; 
assign c[0] = cin;


genvar i; 
generate
for(i = 0; i < 32; i = i+1)
    begin: Gen_Modules
    full_adder fa(A[i], B[i], c[i], sum[i], c[i+1]);
end 

endgenerate 
   
assign cout = c[32];
   
  
endmodule

