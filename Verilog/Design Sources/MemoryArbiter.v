`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2026 04:48:02 AM
// Design Name: 
// Module Name: MemoryArbiter
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


module MemoryArbiter(
input IF_Request, 
input [31:0] IF_Address,
input MEM_Request,
input [31:0] MEM_Address,

// what it decides 
output reg [31:0] Memory_Address,
output reg        Grant_IF,
output reg        Grant_MEM,
output reg        Stall_IF
    );
    
always @(*) begin 
Memory_Address= 32'b0; 
Grant_IF= 1'b0;
Grant_MEM= 1'b0; 
Stall_IF=1'b0;  

 if (MEM_Request) begin
        //give priority to data memory access 
        Memory_Address = MEM_Address;
        Grant_MEM = 1'b1;

        // Instruction fetch must wait if requested
if (IF_Request)
            Stall_IF = 1'b1;
    end
else if (IF_Request) begin
        // No data access: instruction fetch can proceed
        Memory_Address = IF_Address;
        Grant_IF = 1'b1;
    end
end
endmodule
