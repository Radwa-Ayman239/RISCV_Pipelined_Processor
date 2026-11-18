
`timescale 1ns / 1ps

module UnifiedMemory_Integration_TB;

    reg clk = 0;
    always #5 clk = ~clk;

    // Instruction fetch requests
    reg IF_Request;
    reg [31:0] IF_Address;

    // Data memory requests
    reg DataReadRequest;
    reg DataWriteRequest;
    reg [31:0] MEM_Address;
    reg [31:0] WriteData;
    reg [1:0] MemSize;
    reg LoadUnsigned;

    // Arbiter outputs
    wire [31:0] Memory_Address;
    wire Grant_IF;
    wire Grant_MEM;
    wire Stall_IF;

    // Memory control signals
    wire MEM_Request;
    wire InstrFetch;
    wire MemRead;
    wire MemWrite;
    wire [31:0] Memory_Data;

    // A load or store requires the memory port
    assign MEM_Request =
        DataReadRequest | DataWriteRequest;

    // Only the granted requester can access memory
    assign InstrFetch = Grant_IF;

    assign MemRead =
        Grant_MEM & DataReadRequest;

    assign MemWrite =
        Grant_MEM & DataWriteRequest;

    // 1. Memory Arbiter
    MemoryArbiter arbiter (
        .IF_Request(IF_Request),
        .IF_Address(IF_Address),
        .MEM_Request(MEM_Request),
        .MEM_Address(MEM_Address),
        .Memory_Address(Memory_Address),
        .Grant_IF(Grant_IF),
        .Grant_MEM(Grant_MEM),
        .Stall_IF(Stall_IF)
    );

    // 2. Unified Memory
    UnifiedMemory memory (
        .clk(clk),
        .InstrFetch(InstrFetch),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemSize(MemSize),
        .LoadUnsigned(LoadUnsigned),
        .addr(Memory_Address),
        .data_in(WriteData),
        .data_out(Memory_Data)
    );

    initial begin
        // Initial values
        IF_Request = 0;
        IF_Address = 0;

        DataReadRequest = 0;
        DataWriteRequest = 0;
        MEM_Address = 128;

        WriteData = 0;
        MemSize = 2'b10;
        LoadUnsigned = 0;

        // TEST 1: Instruction fetch
        IF_Request = 1;
        IF_Address = 0;
        #2;

        if (Grant_IF === 1'b1 &&
            Memory_Data === 32'h00000033)
            $display("PASS: Instruction fetch");
        else
            $display("FAIL: Instruction fetch");

        // TEST 2: Data load only
        IF_Request = 0;
        DataReadRequest = 1;
        MEM_Address = 128;
        #2;

        if (Grant_MEM === 1'b1 &&
            Memory_Data === 32'd17)
            $display("PASS: Data load");
        else
            $display("FAIL: Data load");

        // TEST 3: Structural hazard
        // IF and MEM both request the port
        IF_Request = 1;
        IF_Address = 0;
        DataReadRequest = 1;
        MEM_Address = 132;
        #2;

        if (Grant_MEM === 1'b1 &&
            Grant_IF === 1'b0 &&
            Stall_IF === 1'b1 &&
            Memory_Address === 32'd132 &&
            Memory_Data === 32'd9)
            $display("PASS: MEM priority over IF");
        else
            $display("FAIL: MEM priority over IF");

        // TEST 4: IF resumes when MEM is idle
        DataReadRequest = 0;
        #2;

        if (Grant_IF === 1'b1 &&
            Stall_IF === 1'b0 &&
            Memory_Data === 32'h00000033)
            $display("PASS: IF resumes");
        else
            $display("FAIL: IF resumes");

        // TEST 5: Data store through arbiter
        IF_Request = 1;
        DataWriteRequest = 1;
        MEM_Address = 140;
        WriteData = 32'd35;

        // Set up the write before a rising edge
        @(posedge clk);
        #1;

        if (Grant_MEM === 1'b1 &&
            Grant_IF === 1'b0 &&
            Stall_IF === 1'b1)
            $display("PASS: Store priority");
        else
            $display("FAIL: Store priority");

        DataWriteRequest = 0;
        IF_Request = 0;
        DataReadRequest = 1;
        #2;

        if (Memory_Data === 32'd35)
            $display("PASS: Store and readback");
        else
            $display("FAIL: Store and readback");

        // TEST 6: Fetch after store
        DataReadRequest = 0;
        IF_Request = 1;
        IF_Address = 0;
        #2;

        if (Grant_IF === 1'b1 &&
            Memory_Data === 32'h00000033)
            $display("PASS: Fetch after store");
        else
            $display("FAIL: Fetch after store");

        $display("------------------------------");
        $display("Integration tests completed");
        $display("------------------------------");

        $finish;
    end

endmodule
