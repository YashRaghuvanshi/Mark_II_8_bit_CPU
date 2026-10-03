`timescale 1ns / 1ps

module MUL_tb;

    logic clk_tb, rst_tb;
    logic [7:0] A_tb;
    logic [7:0] B_tb;
    logic start_tb;

    logic [15:0] result_tb;
    logic done_tb;
    logic busy_tb;

    MUL uut (.clk(clk_tb), .rst(rst_tb), .A(A_tb), .B(B_tb), .start(start_tb), .result(result_tb), .done(done_tb), .busy(busy_tb));

    // Clock
    always #5 clk_tb = ~clk_tb;

    // Multiplication test task
    task automatic test_mul(
        input logic [7:0] A_test,
        input logic [7:0] B_test
    );
        logic [15:0] expected_tb;
        begin
            expected_tb = A_test * B_test;
            A_tb = A_test;
            B_tb = B_test;

            start_tb = 1'b1;

            // Wait for DUT to capture start
            @(posedge clk_tb);
            @(negedge clk_tb);

            start_tb = 1'b0;

            wait(done_tb == 1'b1);

            // Check result
            if (result_tb == expected_tb)
                $display("PASS: %0d x %0d = %0d", A_test, B_test, result_tb);
            else
                $display("FAIL: %0d x %0d | Expected = %0d, Got = %0d", A_test, B_test, expected_tb, result_tb);

            wait(busy_tb == 1'b0);

            // Wait before next test
            @(posedge clk_tb);
            #1;
        end
    endtask

    initial begin
        clk_tb   = 1'b0;
        rst_tb   = 1'b1;
        start_tb = 1'b0;
        A_tb     = 8'b0;
        B_tb     = 8'b0;
        
        // ----------------------------------------------------------------------------------------
        // Reset
        #20;
        rst_tb = 1'b0;
        
        // ----------------------------------------------------------------------------------------
        // Test 1
        test_mul(8'd10, 8'd7);
        
        // ----------------------------------------------------------------------------------------
        // Test 2: Zero
        test_mul(8'd0, 8'd25);

        // ----------------------------------------------------------------------------------------
        // Test 3: Other operand zero
        test_mul(8'd25, 8'd0);
        
        // ----------------------------------------------------------------------------------------
        // Test 4: One
        test_mul(8'd1, 8'd255);
        
        // ----------------------------------------------------------------------------------------
        // Test 5: Maximum values
        test_mul(8'd255, 8'd255);
        
        // ----------------------------------------------------------------------------------------
        // Test 6: Power of two
        test_mul(8'd128, 8'd2);

        $display("--------------------------------");
        $display(" All multiplication tests done");
        $display("--------------------------------");
        $finish;
    end
endmodule