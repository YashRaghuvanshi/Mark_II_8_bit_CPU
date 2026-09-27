`timescale 1ns / 1ps

module MUL(
    input clk,
    input rst,
    input [7:0] A,
    input [7:0] B,
    input start,
    
    output [15:0] result,
    output reg busy,
    output reg done
    );
    
    // Registers needed for shift + add approach for multiplying
    // 8-bit x 8-bit = 16-bit result (maximum)
    reg [15:0] multiplicand;
    reg [7:0] multiplier;
    reg [15:0] accumulator;
    reg [3:0] count;
    
    always @(posedge clk) begin
        if (rst) begin
            multiplicand <= 16'b0;
            multiplier   <= 8'b0;
            accumulator  <= 16'b0;
            count        <= 4'b0;
            done         <= 1'b0;
            busy         <= 1'b0;
        end
        
        else if (start && !busy) begin
            // Load Values
            multiplicand <= {8'b0, A};
            multiplier   <= B;
            accumulator  <= 16'b0;
            count        <= 4'b0;
            done         <= 1'b0;
            busy         <= 1'b1;
            
        end
        
        else if (busy) begin    
        
            if (multiplier[0] == 1) begin
                accumulator <= accumulator + multiplicand;
            end
            
            multiplicand <= multiplicand << 1;
            multiplier <= multiplier >> 1;
            count <= count + 1;
            
            if (count == 4'b0111) begin
                busy <= 1'b0;
                done <= 1'b1;
            end
        end
    end
    
    assign result = accumulator;
    
endmodule
