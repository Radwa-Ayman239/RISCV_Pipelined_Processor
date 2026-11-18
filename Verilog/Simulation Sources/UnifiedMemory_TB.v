`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2026 05:08:07 AM
// Design Name: 
// Module Name: UnifiedMemory_TB
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




module UnifiedMemory_TB;

    reg clk = 0;
    reg InstrFetch = 0;
    reg MemRead = 0;
    reg MemWrite = 0;
    reg [1:0] MemSize = 2'b10;
    reg LoadUnsigned = 0;
    reg [31:0] addr = 0;
    reg [31:0] data_in = 0;

    wire [31:0] data_out;

    always #5 clk = ~clk;

    UnifiedMemory uut (
        .clk(clk),
        .InstrFetch(InstrFetch),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemSize(MemSize),
        .LoadUnsigned(LoadUnsigned),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        // inst fetch test 1 
        InstrFetch = 1;
        addr = 0;
        #2;

        if (data_out !== 32'h00500093)
            $display("FAIL: Instruction fetch");
        else
            $display("PASS: Instruction fetch");

        // inst fetch test 2
        InstrFetch = 0;
        MemRead = 1;
        MemSize = 2'b10;
        addr = 128;
        #2;

        if (data_out !== 32'd17)
            $display("FAIL: LW");
        else
            $display("PASS: LW");

        // store word test 
        MemRead = 0;
        MemWrite = 1;
        addr = 140;
        data_in = 32'd35;

        @(posedge clk);
        #1;
        MemWrite = 0;

        // read back test 3
        MemRead = 1;
        addr = 140;
        #2;

        if (data_out !== 32'd35)
            $display("FAIL: SW");
        else
            $display("PASS: SW");
            
            
        // Test 4: SB followed by LBU
        MemRead = 0;
        MemWrite = 1;
        MemSize = 2'b00;
        addr = 144;
        data_in = 32'h000000FF;

        @(negedge clk);
        @(posedge clk);
        #1;
        MemWrite = 0;

        MemRead = 1;
        LoadUnsigned = 1;
        #2;

        if (data_out !== 32'h000000FF)
            $display("FAIL: SB / LBU");
        else
            $display("PASS: SB / LBU");

        // Test 5: LB sign extension
        LoadUnsigned = 0;
        #2;

        if (data_out !== 32'hFFFFFFFF)
            $display("FAIL: LB");
        else
            $display("PASS: LB");

        // Test 6: SH followed by LHU
        MemRead = 0;
        MemWrite = 1;
        MemSize = 2'b01;
        addr = 148;
        data_in = 32'h00008000;

        @(negedge clk);
        @(posedge clk);
        #1;
        MemWrite = 0;

        MemRead = 1;
        LoadUnsigned = 1;
        #2;

        if (data_out !== 32'h00008000)
            $display("FAIL: SH / LHU");
        else
            $display("PASS: SH / LHU");

        // Test 7: LH sign extension
        LoadUnsigned = 0;
        #2;

        if (data_out !== 32'hFFFF8000)
            $display("FAIL: LH");
        else
            $display("PASS: LH");


        $finish;
    end

endmodule
