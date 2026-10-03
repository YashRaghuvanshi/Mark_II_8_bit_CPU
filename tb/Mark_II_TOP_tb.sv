`timescale 1ns / 1ps

module Mark_II_TOP_tb;

    logic clk_tb;
    logic rst_tb;
    logic halt_tb;

    integer pass_count;
    integer fail_count;
    
    reg [7:0] expected_memory [0:5];

    // ============================================================
    // TEST FILES - Change the 3 files to check different tests
    // ============================================================

    localparam PROGRAM_FILE  = "branch_test.mem";
    localparam DATA_FILE     = "branch_data.mem";
    localparam EXPECTED_FILE = "branch_expected.mem";

    // ============================================================
    // EXPECTED RESULTS:
    // [0] = R0
    // [1] = R1
    // [2] = R2
    // [3] = R3
    // [4] = PC
    // [5] = HALT
    // ============================================================

    // INSTANTIATION
    Mark_II_TOP #(
        .PROGRAM_FILE(PROGRAM_FILE),
        .DATA_FILE(DATA_FILE)
    ) uut (.clk(clk_tb), .rst(rst_tb), .halt(halt_tb));

    // CLOCK
    always #5 clk_tb = ~clk_tb;
    
    // Generates VCD waveform files for online EDA tools.
    initial begin
        $dumpfile("Mark_II_TOP_tb.vcd");
        $dumpvars(0, Mark_II_TOP_tb);
    end

    // ============================================================
    // TASKS
    // ============================================================
    
    // 1. General Test Checker
    task automatic check(
        input logic condition,
        input string test_name
    );
    begin
        if (condition) begin
            $display("PASS: %0s", test_name);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: %0s", test_name);
            fail_count = fail_count + 1;
        end
    end
    endtask
    
    // 2. Reset CPU
    task automatic reset_cpu;
    begin
        rst_tb = 1'b1;
        @(posedge clk_tb);
        @(posedge clk_tb);

        @(negedge clk_tb);

        rst_tb = 1'b0;
    end
    endtask

    // ==================================================================
    // TEST SEQUENCE
    // ==================================================================
    initial begin

        clk_tb = 1'b0;
        rst_tb = 1'b0;

        pass_count = 0;
        fail_count = 0;

        // LOAD EXPECTED RESULTS
        $readmemb(EXPECTED_FILE, expected_memory);

        // ---------------------------------------------------------------
        // RESET
        
        reset_cpu();
        check(!halt_tb, "RESET");

        // ---------------------------------------------------------------
        // RUN PROGRAM
        wait(halt_tb);

        // ---------------------------------------------------------------
        // FINAL STATE CHECKS
        
        check(uut.RF.registers[0] == expected_memory[0], "R0 FINAL VALUE");
        check(uut.RF.registers[1] == expected_memory[1], "R1 FINAL VALUE");
        check(uut.RF.registers[2] == expected_memory[2], "R2 FINAL VALUE");
        check(uut.RF.registers[3] == expected_memory[3], "R3 FINAL VALUE");

        check(uut.PC.pc == expected_memory[4][3:0], "FINAL PC");

        check(halt_tb == expected_memory[5][0], "HALT");

        // ================================================================
        // SUMMARY
        // ================================================================
        $display("");
        $display("==========================================");
        $display("          MARK II CPU TESTBENCH");
        $display("==========================================");

        $display("PROGRAM  : %0s", PROGRAM_FILE);
        $display("DATA     : %0s", DATA_FILE);
        $display("EXPECTED : %0s", EXPECTED_FILE);

        $display("");

        $display("EXPECTED:");
        $display("R0 = %0d", expected_memory[0]);
        $display("R1 = %0d", expected_memory[1]);
        $display("R2 = %0d", expected_memory[2]);
        $display("R3 = %0d", expected_memory[3]);
        $display("PC = %0d", expected_memory[4]);
        $display("HALT = %0d", expected_memory[5]);

        $display("");

        $display("ACTUAL:");
        $display("R0 = %0d", uut.RF.registers[0]);
        $display("R1 = %0d", uut.RF.registers[1]);
        $display("R2 = %0d", uut.RF.registers[2]);
        $display("R3 = %0d", uut.RF.registers[3]);
        $display("PC = %0d", uut.PC.pc);
        $display("HALT = %0d", halt_tb);

        $display("");

        $display("PASSED : %0d", pass_count);
        $display("FAILED : %0d", fail_count);

        $display("======================================");
        $finish;
    end
endmodule