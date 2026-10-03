`timescale 1ns / 1ps

module ALU_8_bit(
    input clk,
    input rst,
    input [7:0] A,
    input [7:0] B,
    input Cin,
    input [4:0] opcode,
    input mul_start,
    input div_start,
    
    output reg [7:0] Y,
    
    // Flags
    output reg Carry,
    output reg Zero,
    output reg Negative,
    output reg Overflow,

    // For MUL/DIV
    output [15:0] mul_result,
    output [7:0] quotient,
    output [7:0] remainder,

    output mul_busy,
    output mul_done,
    output div_busy,
    output div_done,
    output div_zero,
    output busy,
    output done
);

    // Instantiation
    MUL mul (.clk(clk), .rst(rst), .A(A), .B(B), .start(mul_start), .result(mul_result), .busy(mul_busy),
             .done(mul_done));

    DIV div (.clk(clk), .rst(rst), .A(A), .B(B), .start(div_start), .R(remainder), .quotient(quotient),
             .busy(div_busy), .done(div_done), .div_zero (div_zero));

    // Combinational ALU Operations
    always @(*) begin
        Y = 8'b0;
        {Carry, Negative, Zero, Overflow} = 4'b0000;
        
        case (opcode)
            5'b00000: Y = A & B;                // AND
            5'b00001: Y = A | B;                // OR
            5'b00010: Y = ~A;                   // NOT
            5'b00011: Y = A ^ B;                // XOR
            
            5'b00100: begin
                      {Carry, Y} = A + B + Cin; // ADD
                      Overflow = (~(A[7] ^ B[7])) & (Y[7] ^ A[7]);
                      end

            5'b00101: begin
                      {Carry, Y} = A - B;       // SUB
                      Overflow = (A[7] ^ B[7]) & (Y[7] ^ A[7]);
                      end
    
            5'b00110: begin                     // SLL
                          Carry = A[7];
                          Y = A << 1;
                      end
                      
            5'b00111: begin                     // SRL
                          Carry = A[0];
                          Y = A >> 1;
                      end

            5'b01000: Y = (A == B);             // SEQ
            5'b01001: Y = (A < B);              // SLT
            5'b01010: Y = (A > B);              // SGT

            5'b01011: begin                     // INC
                      {Carry, Y} = A + 1;
                      Overflow = (~A[7]) & Y[7];
                      end
                      
            5'b10010: begin                     // SRA
                      Carry = A[0];
                      Y = $signed(A) >>> 1;
                      end

            default: begin
                Y = 8'b0;
                {Carry, Negative, Zero, Overflow} = 4'b0000;
            end
        endcase
        
        Zero = (Y == 8'b0);
        Negative = Y[7];
        
    end

    // Only the currently selected multi-cycle operation controls busy/done.
    assign done = (opcode == 5'b10000) ? mul_done : (opcode == 5'b10001) ? div_done : 1'b0;

    assign busy = (opcode == 5'b10000) ? mul_busy : (opcode == 5'b10001) ? div_busy : 1'b0;
endmodule