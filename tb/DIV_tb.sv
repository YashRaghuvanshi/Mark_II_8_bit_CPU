`timescale 1ns / 1ps

module DIV_tb;

    logic clk_tb;
    logic rst_tb;
    logic [7:0] A_tb;
    logic [7:0] B_tb;
    logic start_tb;

    logic [7:0] quotient_tb;
    logic [7:0] R_tb;
    logic busy_tb;
    logic done_tb;
    logic div_zero_tb;

    // DUT
    DIV uut (.clk(clk_tb), .rst(rst_tb), .A(A_tb), .B(B_tb), .start(start_tb), .quotient(quotient_tb), .R(R_tb), 
             .busy(busy_tb), .done(done_tb), .div_zero (div_zero_tb));

    // Clock
    always #5 clk_tb = ~clk_tb;

    // Division test task
    task automatic test_div(
        input logic [7:0] A_in_tb,
        input logic [7:0] B_in_tb
    );
        logic [7:0] expected_q_tb;
        logic [7:0] expected_r_tb;

        begin
            expected_q_tb = A_in_tb / B_in_tb;
            expected_r_tb = A_in_tb % B_in_tb;

            A_tb = A_in_tb;
            B_tb = B_in_tb;
            start_tb = 1'b1;

            // Wait for DUT to capture start
            @(posedge clk_tb);
            @(negedge clk_tb);
            start_tb = 1'b0;

            wait(done_tb == 1'b1);

            // Check result
            if (quotient_tb == expected_q_tb && R_tb == expected_r_tb)
                $display("PASS: %0d / %0d = Quotient: %0d Remainder: %0d", A_in_tb, B_in_tb, quotient_tb, R_tb);

            else
                $display("FAIL: %0d / %0d | Expected = Quotient: %0d Remainder: %0d, Got = Quotient: %0d Remainder: %0d",
                         A_in_tb, B_in_tb, expected_q_tb, expected_r_tb, quotient_tb, R_tb);

            // Wait before next test
            @(posedge clk_tb);
        end
    endtask

    initial begin

        clk_tb   = 1'b0;
        rst_tb   = 1'b1;
        start_tb = 1'b0;
        A_tb     = 8'b0;
        B_tb     = 8'b0;

        // Reset
        #20;
        rst_tb = 1'b0;

        // Normal division tests
        test_div(8'd42, 8'd13);
        test_div(8'd100, 8'd10);
        test_div(8'd25, 8'd5);
        test_div(8'd255, 8'd2);
        test_div(8'd0, 8'd25);
        test_div(8'd25, 8'd1);
        test_div(8'd255, 8'd255);
        test_div(8'd1, 8'd255);

        // Division by zero test
        A_tb = 8'd25;
        B_tb = 8'd0;
        start_tb = 1'b1;

        @(posedge clk_tb);
        #1;
        start_tb = 1'b0;

        if (div_zero_tb && !busy_tb)
            $display("PASS: Division by zero detected");
        else
            $display("FAIL: Division by zero handling");

        $display("--------------------------------");
        $display("    All division tests done");
        $display("--------------------------------");

        $finish;
    end
endmodule