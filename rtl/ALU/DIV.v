`timescale 1ns / 1ps

module DIV(
    input clk,
    input rst,
    input [7:0] A,
    input [7:0] B,
    input start,
    
    output reg [7:0] quotient,
    output [7:0] R,
    output reg busy,
    output reg done,
    output reg div_zero
    );
    
    // Internal Registers
    reg [7:0] dividend;
    reg [7:0] divisor;
    reg [8:0] remainder; // 9 bits needed for intermediate shifted remainder
    reg [8:0] temp_remainder;
    reg [3:0] count;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dividend <= 8'b0;
            divisor <= 8'b0;
            quotient <= 8'b0;
            remainder <= 9'b0;
            count <= 4'b0;
            div_zero <= 1'b0;
            busy <= 1'b0;
            done <= 1'b0;
        end
        
        else if (start && !busy) begin
            // Load Values
            dividend <= A;
            divisor <= B;
            quotient <= 8'b0;
            remainder <= 9'b0;
            count <= 4'b0;
            done <= 1'b0;
            
            // Handle Division By Zero
            if (B == 0) begin
                div_zero <= 1'b1;
                busy <= 1'b0;
            end
            
            else begin
                div_zero <= 1'b0;
                busy <= 1'b1;
            end
        end
        
        else if (busy) begin

            // Bring down next dividend bit into remainder
            temp_remainder = {remainder[7:0], dividend[7]}; // Blocking assignment as intermediate calculation
            
            // Shift dividend to get the next bit
            dividend <= dividend << 1;
            
            // Check subtraction
            if (temp_remainder >= {1'b0, divisor}) begin
                remainder <= temp_remainder - {1'b0, divisor};
                quotient  <= {quotient[6:0], 1'b1};
            end
            
            else begin
                remainder <= temp_remainder;
                quotient  <= {quotient[6:0], 1'b0};
            end
            
            count <= count + 1'b1;
            if (count == 4'b0111) begin
                busy <= 1'b0;
                done <= 1'b1;
            end
        end
    end
    
    assign R = remainder[7:0];
    
endmodule
