`timescale 1ns / 1ps

module Program_Counter_tb;

    logic clk_tb;
    logic rst_tb;
    logic jump_tb;
    logic pc_enable_tb;
    logic [3:0] jump_target_tb;
    logic [3:0] pc_tb;

    Program_Counter uut (.clk(clk_tb), .rst(rst_tb), .jump(jump_tb), .pc_enable(pc_enable_tb),
                         .jump_target(jump_target_tb), .pc(pc_tb));

    // Clock generation
    always #5 clk_tb = ~clk_tb;

    initial begin
        clk_tb = 0;
        rst_tb = 1;
        jump_tb = 0;
        pc_enable_tb = 0;
        jump_target_tb = 4'b0000;

        // ----------------------------------------------------------------------------------------
        // Test 1: Reset
        @(posedge clk_tb);
        @(negedge clk_tb);

        rst_tb = 0;

        if (pc_tb !== 4'b0000)
            $display("ERROR: Test 1 - PC did not reset to 0");
        else
            $display("PASS: Test 1 - PC reset to 0");

        // ----------------------------------------------------------------------------------------
        // Test 2: Normal Counting
        pc_enable_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        if (pc_tb !== 4'b0001)
            $display("ERROR: Test 2A - PC did not increment to 1");
        else
            $display("PASS: Test 2A - PC incremented to 1");

        @(posedge clk_tb);
        @(negedge clk_tb);

        if (pc_tb !== 4'b0010)
            $display("ERROR: Test 2B - PC did not increment to 2");
        else
            $display("PASS: Test 2B - PC incremented to 2");

        // ----------------------------------------------------------------------------------------
        // Test 3: PC Hold
        pc_enable_tb = 0;

        @(posedge clk_tb);
        @(negedge clk_tb);

        if (pc_tb !== 4'b0010)
            $display("ERROR: Test 3 - PC changed when PC enable was disabled");
        else
            $display("PASS: Test 3 - PC held when PC enable was disabled");

        // ----------------------------------------------------------------------------------------
        // Test 4: Jump to Instruction-Memory Location 9
        jump_tb = 1;
        jump_target_tb = 4'b1001;

        @(posedge clk_tb);
        @(negedge clk_tb);

        jump_tb = 0;

        if (pc_tb !== 4'b1001)
            $display("ERROR: Test 4 - PC did not jump to 9");
        else
            $display("PASS: Test 4 - PC jumped to instruction-memory location 9");

        // ----------------------------------------------------------------------------------------
        // Test 5: Continue Counting After Jump
        pc_enable_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        if (pc_tb !== 4'b1010)
            $display("ERROR: Test 5 - PC did not increment to 10 after jump");
        else
            $display("PASS: Test 5 - PC continued counting after jump");

        // ----------------------------------------------------------------------------------------
        // Test 6: Jump Priority Over PC Enable
        jump_tb = 1;
        jump_target_tb = 4'b1100;
        pc_enable_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        jump_tb = 0;

        if (pc_tb !== 4'b1100)
            $display("ERROR: Test 6 - Jump did not have priority over PC increment");
        else
            $display("PASS: Test 6 - Jump has priority over PC increment");

        // ----------------------------------------------------------------------------------------
        // Test 7: PC Wraparound
        jump_tb = 1;
        jump_target_tb = 4'b1111;
        pc_enable_tb = 0;

        @(posedge clk_tb);
        @(negedge clk_tb);

        jump_tb = 0;
        pc_enable_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        if (pc_tb !== 4'b0000)
            $display("ERROR: Test 7 - PC did not wrap from 15 to 0");
        else
            $display("PASS: Test 7 - PC wrapped from 15 to 0");

        // ----------------------------------------------------------------------------------------
        // Test 8: Reset Mid-Operation
        pc_enable_tb = 0;
        rst_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        rst_tb = 0;

        if (pc_tb !== 4'b0000)
            $display("ERROR: Test 8 - PC did not reset to 0 during operation");
        else
            $display("PASS: Test 8 - PC reset correctly during operation");
        
        $display("-------------------------------");
        $display("Program Counter test completed.");
        $display("-------------------------------");
        $finish;
    end

endmodule