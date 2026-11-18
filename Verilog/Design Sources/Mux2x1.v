`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:14:58 PM
// Design Name: 
// Module Name: Mux2x1
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


module Mux2x1(
input A,
input B,
input Sel,
output Out

    );
   wire w1,w2;
   
   
   
   and  a1(w1,A,~Sel);
   and a2(w2, B,Sel);
   or o1(Out, w1,w2);
   
   
   
endmodule