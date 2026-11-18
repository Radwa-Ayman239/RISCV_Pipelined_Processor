`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:12:49 PM
// Design Name: 
// Module Name: ForwardingUnit
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


module ForwardingUnit(
    input [4:0] ID_EX_Rs1,
    input [4:0] ID_EX_Rs2,
    input EX_MEM_regwrite,
    input MEM_WB_regwrite,
    input [4:0] EX_MEM_Rd,
    input [4:0] MEM_WB_Rd,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

    always @(*) begin
       
        forwardA = 2'b00;
        forwardB = 2'b00;

       
        if (EX_MEM_regwrite &&
            (EX_MEM_Rd != 5'd0) &&
            (EX_MEM_Rd == ID_EX_Rs1))
            forwardA = 2'b10;

        else if (MEM_WB_regwrite &&
                 (MEM_WB_Rd != 5'd0) &&
                 (MEM_WB_Rd == ID_EX_Rs1))
            forwardA = 2'b01;

       
        if (EX_MEM_regwrite &&
            (EX_MEM_Rd != 5'd0) &&
            (EX_MEM_Rd == ID_EX_Rs2))
            forwardB = 2'b10;

        else if (MEM_WB_regwrite &&
                 (MEM_WB_Rd != 5'd0) &&
                 (MEM_WB_Rd == ID_EX_Rs2))
            forwardB = 2'b01;
    end
endmodule
