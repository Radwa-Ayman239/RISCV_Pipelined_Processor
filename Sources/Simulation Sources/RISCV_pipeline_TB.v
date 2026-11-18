
`timescale 1ns / 1ps

module RISCV_pipeline_TB();

    reg clk;
    reg rst;

    integer cycle;
    integer pass_count;
    integer fail_count;
    integer wb_checks;

    reg [31:0] expected_value;
    reg check_valid;

    // Track whether instruction groups were reached
    reg saw_branch_taken;
    reg saw_branch_not_taken;
    reg saw_jal;
    reg saw_jalr;
    reg saw_lui;
    reg saw_auipc;
    reg saw_ebreak;

    RISCV_pipeline uut (
        .clk(clk),
        .rst(rst)
    );

    // ==========================================
    // CLOCK
    // ==========================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ==========================================
    // RESET
    // ==========================================

    initial begin
        rst = 1;
        cycle = 0;
        pass_count = 0;
        fail_count = 0;
        wb_checks = 0;

        saw_branch_taken = 0;
        saw_branch_not_taken = 0;
        saw_jal = 0;
        saw_jalr = 0;
        saw_lui = 0;
        saw_auipc = 0;
        saw_ebreak = 0;

        #12;
        rst = 0;

        // Maximum simulation duration
        #5000;

        $display("");
        $display("========================================");
        $display("       FINAL CPU VERIFICATION");
        $display("========================================");

        $display("Final PC = %h", uut.PCout);
        $display("Total cycles = %0d", cycle);

        // ======================================
        // STORE CHECKS
        // ======================================

        check_memory(
            "SB",
            388,
            32'h000000FB
        );

        check_memory(
            "SH",
            389,
            32'h0000FFFB
        );

        check_memory(
            "SW negative",
            390,
            32'hFFFFFFFB
        );

        check_memory(
            "SW positive",
            391,
            32'h00000011
        );

        // ======================================
        // INSTRUCTION GROUP COVERAGE
        // ======================================

        $display("");
        $display("========== COVERAGE ==========");

        check_flag("Taken branch", saw_branch_taken);
        check_flag("Not-taken branch", saw_branch_not_taken);
        check_flag("JAL", saw_jal);
        check_flag("JALR", saw_jalr);
        check_flag("LUI", saw_lui);
        check_flag("AUIPC", saw_auipc);
        check_flag("EBREAK", saw_ebreak);

        $display("");
        $display("========== FINAL SUMMARY ==========");
        $display("Writeback checks = %0d", wb_checks);
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);

        if (fail_count == 0)
            $display("ALL IMPLEMENTED CHECKS PASSED");
        else
            $display("SOME CHECKS FAILED");

        $display("========================================");

        $finish;
    end

    // ==========================================
    // MEMORY CHECK TASK
    // ==========================================

    task check_memory;
        input [8*32-1:0] name;
        input integer index;
        input [31:0] expected;
        reg [31:0] actual;
        begin
            actual = uut.shared_memory.mem[index];

            if (actual === expected) begin
                $display("PASS: %0s = %h", name, actual);
                pass_count = pass_count + 1;
            end
            else begin
                $display(
                    "FAIL: %0s expected=%h actual=%h",
                    name, expected, actual
                );
                fail_count = fail_count + 1;
            end
        end
    endtask

    task check_flag;
        input [8*32-1:0] name;
        input observed;
        begin
            if (observed) begin
                $display("PASS: %0s reached", name);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: %0s not observed", name);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ==========================================
    // PIPELINE MONITOR
    // ==========================================

    always @(negedge clk) begin
        if (!rst) begin
            cycle = cycle + 1;

            // ----------------------------------
            // WRITEBACK VERIFICATION
            // ----------------------------------

            if (uut.MEM_WB_Ctrl[1] &&
                uut.MEM_WB_Rd != 0) begin

                wb_checks = wb_checks + 1;

                $display(
                    "WB: x%0d = %h",
                    uut.MEM_WB_Rd,
                    uut.WriteData
                );
            end

            // ----------------------------------
            // BRANCH MONITORING
            // ----------------------------------

            if (uut.and_out) begin
                saw_branch_taken = 1;

                $display(
                    "BRANCH TAKEN: target=%h",
                    uut.EX_MEM_BranchAddOut
                );
            end

            // A branch with no redirect is
            // treated as a not-taken observation.
            if (uut.IF_ID_Inst[6:0] == 7'b1100011 &&
                !uut.and_out) begin
                saw_branch_not_taken = 1;
            end

            // ----------------------------------
            // JUMP MONITORING
            // ----------------------------------

            if (uut.IF_ID_Inst[6:0] == 7'b1101111)
                saw_jal = 1;

            if (uut.IF_ID_Inst[6:0] == 7'b1100111)
                saw_jalr = 1;

            // ----------------------------------
            // U-TYPE MONITORING
            // ----------------------------------

            if (uut.IF_ID_Inst[6:0] == 7'b0110111)
                saw_lui = 1;

            if (uut.IF_ID_Inst[6:0] == 7'b0010111)
                saw_auipc = 1;

            // ----------------------------------
            // EBREAK
            // ----------------------------------

            if (uut.IF_ID_Inst == 32'h00100073 &&
                !uut.PC_Write) begin

                saw_ebreak = 1;

                $display(
                    "EBREAK detected at PC=%h",
                    uut.IF_ID_PC
                );
            end

            // ----------------------------------
            // HAZARDS
            // ----------------------------------

            if (uut.Stall_IF)
                $display("STRUCTURAL HAZARD detected");

            if (uut.stall)
                $display("LOAD-USE HAZARD detected");

        end
    end

endmodule
