`timescale 1ns / 1ps

module ALU_8_bit_tb;

    logic clk_tb;
    logic rst_tb;
    logic [7:0] A_tb;
    logic [7:0] B_tb;
    logic Cin_tb;
    logic [4:0] opcode_tb;

    logic [7:0] Y_tb;
    logic Carry_tb;

    logic [15:0] mul_result_tb;
    logic [7:0] quotient_tb;
    logic [7:0] remainder_tb;

    logic mul_busy_tb;
    logic mul_done_tb;
    logic div_busy_tb;
    logic div_done_tb;
    logic div_zero_tb;
    logic busy_tb;
    logic done_tb;

    // DUT
    ALU_8_bit uut (.clk(clk_tb), .rst(rst_tb), .A(A_tb), .B(B_tb), .Cin(Cin_tb), .opcode(opcode_tb), .Y(Y_tb), 
                   .Carry(Carry_tb), .mul_result(mul_result_tb), .quotient(quotient_tb), .remainder(remainder_tb),
                   .mul_busy(mul_busy_tb), .mul_done(mul_done_tb), .div_busy(div_busy_tb), .div_done(div_done_tb),
                   .div_zero(div_zero_tb),  .busy(busy_tb), .done(done_tb));

    // Clock
    always #5 clk_tb = ~clk_tb;

    initial begin
        
        // For online tools 
        $dumpfile("ALU_8_bit_tb.vcd");
        $dumpvars(0, ALU_8_bit_tb);

        // Initial values
        clk_tb = 1'b0;
        rst_tb = 1'b1;
        A_tb = 8'b0;
        B_tb = 8'b0;
        Cin_tb = 1'b0;
        opcode_tb = 5'b00000;

        // Reset
        #10;
        rst_tb = 1'b0;

        // ----------------------------------------------------------------------------------------
        // AND
        // 12 & 10 = 8
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd12;
        B_tb = 8'd10;
        opcode_tb = 5'b00000;

        #1;

        if (Y_tb == 8'd8)
            $display("TEST 1 - AND: PASS, Y = %0d", Y_tb);
        else
            $display("TEST 2 - AND: FAIL, Y = %0d", Y_tb);

        // ----------------------------------------------------------------------------------------
        // ADD
        // 100 + 50 = 150
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd100;
        B_tb = 8'd50;
        Cin_tb = 1'b0;
        opcode_tb = 5'b00100;

        #1;

        if (Y_tb == 8'd150 && Carry_tb == 1'b0)
            $display("TEST 2 - ADD: PASS, Y = %0d, Carry = %0b", Y_tb, Carry_tb);
        else
            $display("TEST 2 - ADD: FAIL, Y = %0d, Carry = %0b", Y_tb, Carry_tb);


        /// ----------------------------------------------------------------------------------------
        // SUB
        // ----------------------------------------------------------------------------------------

        // SUB - Positive result
        // 100 - 30 = 70
        // ------------------------------------------------
        A_tb = 8'd100;
        B_tb = 8'd30;
        opcode_tb = 5'b00101;

        #1;

        if (Y_tb == 8'd70)
            $display("TEST 3A - SUB POSITIVE: PASS, Y = %0d", Y_tb);
        else
            $display("TEST 3A - SUB POSITIVE: FAIL, Y = %0d", Y_tb);

        // ------------------------------------------------
        // SUB - Negative result
        // 30 - 50 = -20 = 8'hEC
        // ------------------------------------------------
        A_tb = 8'd30;
        B_tb = 8'd50;
        opcode_tb = 5'b00101;

        #1;

        if (Y_tb == 8'hEC && Y_tb[7] == 1'b1)
            $display("TEST 3B - SUB NEGATIVE: PASS, %0d - %0d = signed -20, Y = %0h", A_tb, B_tb, Y_tb);
        else
            $display("TEST 3B - SUB NEGATIVE: FAIL, Y = %0h", Y_tb);

        // ----------------------------------------------------------------------------------------
        // MUL
        // 13 * 3 = 39
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd13;
        B_tb = 8'd3;
        opcode_tb = 5'b10000;

        wait(mul_done_tb);

        #1;

        if (mul_result_tb == 16'd39)
            $display("TEST 4 - MUL: PASS, %0d * %0d = %0d", A_tb, B_tb, mul_result_tb);
        else
            $display("TEST 4 - MUL: FAIL, result = %0d", mul_result_tb);

        // ----------------------------------------------------------------------------------------
        // DIV
        // 100 / 7 = 14 R 2
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd100;
        B_tb = 8'd7;
        opcode_tb = 5'b10001;

        wait(div_done_tb);
        #1;

        if (quotient_tb == 8'd14 && remainder_tb == 8'd2)
            $display("TEST 5 - DIV: PASS, %0d / %0d = Quotient: %0d Remainder: %0d",A_tb, B_tb, quotient_tb, remainder_tb);
        else
            $display("TEST 5 - DIV: FAIL, Quotient: %0d Remainder: %0d",  quotient_tb, remainder_tb);

        // ----------------------------------------------------------------------------------------
        // DIVISION BY ZERO
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd25;
        B_tb = 8'd0;
        opcode_tb = 5'b10001;

        @(posedge clk_tb);
        #1;

        if (div_zero_tb == 1'b1)
            $display("TEST 6 - DIV ZERO: PASS, div_zero = %0b", div_zero_tb);
        else
            $display("TEST 6 - DIV ZERO: FAIL, div_zero = %0b", div_zero_tb);
        #10;
        $finish;
    end
endmodule