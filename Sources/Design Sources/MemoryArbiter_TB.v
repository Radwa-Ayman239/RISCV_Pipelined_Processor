
`timescale 1ns / 1ps

module MemoryArbiter_TB;

    // Inputs to the Memory Arbiter
    reg IF_Request;
    reg [31:0] IF_Address;

    reg MEM_Request;
    reg [31:0] MEM_Address;

    // Outputs from the Memory Arbiter
    wire [31:0] Memory_Address;
    wire Grant_IF;
    wire Grant_MEM;
    wire Stall_IF;

    // Instantiate the Memory Arbiter
    MemoryArbiter uut (
        .IF_Request(IF_Request),
        .IF_Address(IF_Address),
        .MEM_Request(MEM_Request),
        .MEM_Address(MEM_Address),
        .Memory_Address(Memory_Address),
        .Grant_IF(Grant_IF),
        .Grant_MEM(Grant_MEM),
        .Stall_IF(Stall_IF)
    );

    initial begin

        // Initialize inputs
        IF_Request = 0;
        MEM_Request = 0;
        IF_Address = 32'd20;
        MEM_Address = 32'd128;

        #10;

        // TEST 1: No requests
        if (Grant_IF === 1'b0 &&
            Grant_MEM === 1'b0 &&
            Stall_IF === 1'b0 &&
            Memory_Address === 32'd0)
            $display("PASS: No requests");
        else
            $display("FAIL: No requests");

        // TEST 2: Only IF requests memory
        IF_Request = 1;
        MEM_Request = 0;

        #10;

        if (Grant_IF === 1'b1 &&
            Grant_MEM === 1'b0 &&
            Stall_IF === 1'b0 &&
            Memory_Address === 32'd20)
            $display("PASS: IF only");
        else
            $display("FAIL: IF only");

        // TEST 3: Only MEM requests memory
        IF_Request = 0;
        MEM_Request = 1;

        #10;

        if (Grant_IF === 1'b0 &&
            Grant_MEM === 1'b1 &&
            Stall_IF === 1'b0 &&
            Memory_Address === 32'd128)
            $display("PASS: MEM only");
        else
            $display("FAIL: MEM only");

        // TEST 4: Both IF and MEM request memory
        IF_Request = 1;
        MEM_Request = 1;

        #10;

        if (Grant_IF === 1'b0 &&
            Grant_MEM === 1'b1 &&
            Stall_IF === 1'b1 &&
            Memory_Address === 32'd128)
            $display("PASS: Structural hazard handled");
        else
            $display("FAIL: Structural hazard handling");

        // TEST 5: MEM finishes, IF resumes
        MEM_Request = 0;
        IF_Request = 1;

        #10;

        if (Grant_IF === 1'b1 &&
            Grant_MEM === 1'b0 &&
            Stall_IF === 1'b0 &&
            Memory_Address === 32'd20)
            $display("PASS: IF resumes after MEM");
        else
            $display("FAIL: IF resumes after MEM");

        $display("-----------------------------");
        $display("Memory Arbiter Tests Finished");
        $display("-----------------------------");

        $finish;

    end

endmodule
