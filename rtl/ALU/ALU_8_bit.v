`timescale 1ns / 1ps

module ALU_8_bit(
    input clk,
    input rst,
    input [7:0] A,
    input [7:0] B,
    input Cin,
    input [4:0] opcode,

    output reg [7:0] Y,
    output reg Carry,

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

    wire mul_start;
    wire div_start;

    // Instantiation
    MUL mul (.clk(clk), .rst(rst), .A(A), .B(B), .start(mul_start), .result(mul_result), .busy(mul_busy),
             .done(mul_done));

    DIV div (.clk(clk), .rst(rst), .A(A), .B(B), .start(div_start), .R(remainder), .quotient(quotient),
             .busy(div_busy), .done(div_done), .div_zero (div_zero));

    // Combinational ALU Operations
    always @(*) begin
        Y = 8'b0;
        Carry = 1'b0;
        
        case (opcode)
            5'b00000: Y = A & B;                // AND
            5'b00001: Y = A | B;                // OR
            5'b00010: Y = ~A;                   // NOT
            5'b00011: Y = A ^ B;                // XOR
            
            5'b00100: {Carry, Y} = A + B + Cin; // ADD
            5'b00101: {Carry, Y} = A - B;       // SUB

            5'b00110: Y = A << 1;               // SLL
            5'b00111: Y = A >> 1;               // SRL

            5'b01000: Y = (A == B);             // SEQ
            5'b01001: Y = (A < B);              // SLT
            5'b01010: Y = (A > B);              // SGT

            5'b01011: Y = A + 1;                // INC

            default: begin
                Y = 8'b0;
                Carry = 1'b0;
            end
        endcase
    end

    // Start signals for MUL/DIV
    assign mul_start = (opcode == 5'b10000);
    assign div_start = (opcode == 5'b10001);

    // Only the currently selected multi-cycle operation controls busy/done.
    assign done = (opcode == 5'b10000) ? mul_done : (opcode == 5'b10001) ? div_done : 1'b0;

    assign busy = (opcode == 5'b10000) ? mul_busy : (opcode == 5'b10001) ? div_busy : 1'b0;
endmodule