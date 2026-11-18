`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2026 04:08:33 AM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile #(parameter N=32)(
    input clk, rst,
    input [4:0] readreg1, readreg2, writereg,
    input [N-1:0] writedata,
    input regwrite,
    output [N-1:0] readdata1, readdata2
);

reg [31:0] loads;
wire [N-1:0] regfile[31:0];

integer j;
//loads =0, loads[writereg] =1; if regwrite=1
always @(*) begin
    loads = 32'b0;
     if (regwrite && (writereg!=0)) begin
        loads [writereg] = 1'b1; 
    end
end 




genvar i;

generate 
for (i=0;i<N;i=i+1) begin: myegnloop  

//generate , for, instantiate 32 registers

NBitRegister_negative R1(clk, rst, loads[i], writedata, regfile[i]);
end
endgenerate



assign readdata1 = regfile[readreg1];
assign readdata2 = regfile[readreg2]; 

            
    


endmodule
