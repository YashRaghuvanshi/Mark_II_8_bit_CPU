`timescale 1ns / 1ps

module ALU_8_bit_tb;

    logic clk_tb;
    logic rst_tb;
    logic [7:0] A_tb;
    logic [7:0] B_tb;
    logic Cin_tb;
    logic [4:0] opcode_tb;

    logic mul_start_tb;
    logic div_start_tb;

    logic [7:0] Y_tb;
    logic Carry_tb;
    logic Zero_tb;
    logic Negative_tb;
    logic Overflow_tb;

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
    ALU_8_bit uut (.clk(clk_tb), .rst(rst_tb), .A(A_tb), .B(B_tb), .Cin(Cin_tb), .opcode(opcode_tb),
                   .mul_start(mul_start_tb), .div_start(div_start_tb), .Y(Y_tb), 
                   .Carry(Carry_tb), .Zero(Zero_tb), .Negative(Negative_tb), .Overflow(Overflow_tb),
                   .mul_result(mul_result_tb), .quotient(quotient_tb), .remainder(remainder_tb),
                   .mul_busy(mul_busy_tb), .mul_done(mul_done_tb), .div_busy(div_busy_tb), .div_done(div_done_tb),
                   .div_zero(div_zero_tb),  .busy(busy_tb), .done(done_tb));

    // Clock
    always #5 clk_tb = ~clk_tb;
    
    task display_flags;
    begin
        $display("  Flags    : C=%b | Z=%b | N=%b | V=%b",
                 Carry_tb, Zero_tb, Negative_tb, Overflow_tb);
        $display("------------------------------------------------------------");
    end
    endtask

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
        mul_start_tb = 1'b0;
        div_start_tb = 1'b0;

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
            $display("TEST 1 - AND: FAIL, Y = %0d", Y_tb);

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
            $display("TEST 2A - ADD: PASS, Y = %0d, Carry = %0b", Y_tb, Carry_tb);
        else
            $display("TEST 2A - ADD: FAIL, Y = %0d, Carry = %0b", Y_tb, Carry_tb);
        
        display_flags();
        
        // ----------------------------------------------------------------------------------------
        // ADD OVERFLOW TEST
        // 127 + 1 = -128
        // ----------------------------------------------------------------------------------------
        
        A_tb = 8'd127;
        B_tb = 8'd1;
        Cin_tb = 1'b0;
        opcode_tb = 5'b00100;
        #1;
        
        if (Y_tb == 8'h80 && Overflow_tb == 1'b1)
            $display("TEST 2B - ADD OVERFLOW: PASS, Y = %0h, Overflow = %0b", Y_tb, Overflow_tb);
        else
            $display("TEST 2B - ADD OVERFLOW: FAIL, Y = %0h, Overflow = %0b", Y_tb, Overflow_tb);
        display_flags();
            
        // ----------------------------------------------------------------------------------------
        // ADD CARRY
        // 255 + 1 = 0 with Carry
        // ----------------------------------------------------------------------------------------
        
        A_tb = 8'd255;
        B_tb = 8'd1;
        Cin_tb = 1'b0;
        opcode_tb = 5'b00100;
        #1;
        
        if (Y_tb == 8'd0 && Carry_tb == 1'b1)
            $display("TEST 2C - ADD CARRY: PASS, Y = %0d, Carry = %0b", Y_tb, Carry_tb);
        else
            $display("TEST 2C - ADD CARRY: FAIL, Y = %0d, Carry = %0b", Y_tb, Carry_tb);
        display_flags();    
        
        // ----------------------------------------------------------------------------------------
        // SUB
        // ----------------------------------------------------------------------------------------

        // SUB - Positive result
        // 100 - 30 = 70
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd100;
        B_tb = 8'd30;
        opcode_tb = 5'b00101;
        #1;

        if (Y_tb == 8'd70)
            $display("TEST 3A - SUB POSITIVE: PASS, Y = %0d", Y_tb);
        else
            $display("TEST 3A - SUB POSITIVE: FAIL, Y = %0d", Y_tb);
        display_flags();

        // ----------------------------------------------------------------------------------------
        // SUB - Negative result
        // 30 - 50 = -20 = 8'hEC
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd30;
        B_tb = 8'd50;
        opcode_tb = 5'b00101;
        #1;

        if (Y_tb == 8'hEC && Negative_tb == 1'b1)
            $display("TEST 3B - SUB NEGATIVE: PASS, Y = %0h, Negative = %0b", Y_tb, Negative_tb);
        else
            $display("TEST 3B - SUB NEGATIVE: FAIL, Y = %0h, Negative = %0b", Y_tb, Negative_tb);
        display_flags();
        
        // ----------------------------------------------------------------------------------------
        // SUB OVERFLOW
        // 127 - (-1) = 128 = 8'h80
        // ----------------------------------------------------------------------------------------
        
        A_tb = 8'd127;
        B_tb = 8'hFF;   // -1 in signed 8-bit
        opcode_tb = 5'b00101;
        #1;
        
        if (Y_tb == 8'h80 && Overflow_tb == 1'b1)
            $display("TEST 3C - SUB OVERFLOW: PASS, Y = %0h, Overflow = %0b", Y_tb, Overflow_tb);
        else
            $display("TEST 3C - SUB OVERFLOW: FAIL, Y = %0h, Overflow = %0b", Y_tb, Overflow_tb);
        
        display_flags();
        
        // ----------------------------------------------------------------------------------------
        // ZERO FLAG
        // 25 - 25 = 0
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd25;
        B_tb = 8'd25;
        opcode_tb = 5'b00101;
        #1;
        
        if (Y_tb == 8'd0 && Zero_tb == 1'b1)
            $display("TEST 3D - ZERO FLAG: PASS, Y = %0d, Zero = %0b", Y_tb, Zero_tb);
        else
            $display("TEST 3D - ZERO FLAG: FAIL, Y = %0d, Zero = %0b", Y_tb, Zero_tb);
        display_flags();
        
        // ----------------------------------------------------------------------------------------
        // MUL
        // 13 * 3 = 39
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd13;
        B_tb = 8'd3;
        opcode_tb = 5'b10000;

        mul_start_tb = 1'b1;
        @(posedge clk_tb);
        @(negedge clk_tb);
        mul_start_tb = 1'b0;

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

        div_start_tb = 1'b1;
        @(posedge clk_tb);
        @(negedge clk_tb);
        div_start_tb = 1'b0;

        wait(div_done_tb);
        #1;

        if (quotient_tb == 8'd14 && remainder_tb == 8'd2)
            $display("TEST 5 - DIV: PASS, %0d / %0d = Quotient: %0d Remainder: %0d",
                     A_tb, B_tb, quotient_tb, remainder_tb);
        else
            $display("TEST 5 - DIV: FAIL, Quotient: %0d Remainder: %0d",  quotient_tb, remainder_tb);

        // ----------------------------------------------------------------------------------------
        // DIVISION BY ZERO
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd25;
        B_tb = 8'd0;
        opcode_tb = 5'b10001;

        div_start_tb = 1'b1;
        @(posedge clk_tb);
        @(negedge clk_tb);
        div_start_tb = 1'b0;
        #1;

        if (div_zero_tb == 1'b1)
            $display("TEST 6 - DIV ZERO: PASS, div_zero = %0b", div_zero_tb);
        else
            $display("TEST 6 - DIV ZERO: FAIL, div_zero = %0b", div_zero_tb);
        #10;
        
        // ----------------------------------------------------------------------------------------
        // SLL EDGE
        // 200 << 1 = 144, Carry = 1
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd200;
        opcode_tb = 5'b00110;
        #1;
        
        if (Y_tb == 8'd144 && Carry_tb == 1'b1)
            $display("TEST 7 - SLL EDGE: PASS, Y = %0d, Carry = %0b", Y_tb, Carry_tb);
        else
            $display("TEST 7 - SLL EDGE: FAIL, Y = %0d, Carry = %0b", Y_tb, Carry_tb);
        
        display_flags();
        
        // ----------------------------------------------------------------------------------------
        // SRL EDGE
        // 101 >> 1 = 50, Carry = 1
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd101;
        opcode_tb = 5'b00111;
        #1;
        
        if (Y_tb == 8'd50 && Carry_tb == 1'b1)
            $display("TEST 8 - SRL EDGE: PASS, Y = %0d, Carry = %0b", Y_tb, Carry_tb);
        else
            $display("TEST 8 - SRL EDGE: FAIL, Y = %0d, Carry = %0b", Y_tb, Carry_tb);
        
        display_flags();
        
        // ----------------------------------------------------------------------------------------
        // SRA EDGE
        // 0x90 (-112) >>> 1 = 0xC8 (-56)
        // ----------------------------------------------------------------------------------------
        A_tb = 8'h90;
        opcode_tb = 5'b10010;
        #1;
        
        if (Y_tb == 8'hC8 && Negative_tb == 1'b1)
            $display("TEST 9 - SRA EDGE: PASS, Y = %0h, Negative = %0b", Y_tb, Negative_tb);
        else
            $display("TEST 9 - SRA EDGE: FAIL, Y = %0h, Negative = %0b", Y_tb, Negative_tb);
        
        display_flags();
        
        // ----------------------------------------------------------------------------------------
        // INC OVERFLOW
        // 127 + 1 = 0x80, Overflow = 1
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd127;
        opcode_tb = 5'b01011;
        #1;
        
        if (Y_tb == 8'h80 && Overflow_tb == 1'b1)
            $display("TEST 10A - INC OVERFLOW: PASS, Y = %0h, Overflow = %0b", Y_tb, Overflow_tb);
        else
            $display("TEST 10A - INC OVERFLOW: FAIL, Y = %0h, Overflow = %0b", Y_tb, Overflow_tb);
        
        display_flags();
        
        // ----------------------------------------------------------------------------------------
        // INC CARRY
        // 255 + 1 = 0, Carry = 1, Zero = 1
        // ----------------------------------------------------------------------------------------
        A_tb = 8'd255;
        opcode_tb = 5'b01011;
        #1;
        
        if (Y_tb == 8'd0 && Carry_tb == 1'b1 && Zero_tb == 1'b1)
            $display("TEST 10B - INC CARRY: PASS, Y = %0d, C = %0b, Z = %0b", Y_tb, Carry_tb, Zero_tb);
        else
            $display("TEST 10B - INC CARRY: FAIL, Y = %0d, C = %0b, Z = %0b", Y_tb, Carry_tb, Zero_tb);
        
        display_flags();
        
        $display("--------------------------------");
        $display("         ALU tests done");
        $display("--------------------------------");
        $finish;
    end
endmodule