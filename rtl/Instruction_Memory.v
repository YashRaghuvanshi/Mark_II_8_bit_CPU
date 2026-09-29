`timescale 1ns / 1ps

module Instruction_Memory(
    input  [3:0]  address,
    output [12:0] instruction
);

    reg [12:0] memory [0:15];

    initial begin
        $readmemb("program.mem", memory);
    end
    
    assign instruction = memory[address];
endmodule