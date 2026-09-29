`timescale 1ns / 1ps

module Instruction_Memory_tb;

    logic [3:0] address_tb;
    logic [12:0] instruction_tb;

    Instruction_Memory uut (.address(address_tb), .instruction(instruction_tb));

    initial begin
        // Address 0
        address_tb = 4'b0000;
        #10;
        if (instruction_tb !== 13'b0000000000001)
            $display("ERROR: Address 0");
        else
            $display("PASS: Address 0");

        // Address 1
        address_tb = 4'b0001;
        #10;
        if (instruction_tb !== 13'b0000000000010)
            $display("ERROR: Address 1");
        else
            $display("PASS: Address 1");

        // Address 2
        address_tb = 4'b0010;
        #10;
        if (instruction_tb !== 13'b0000000000011)
            $display("ERROR: Address 2");
        else
            $display("PASS: Address 2");

        // Address 15
        address_tb = 4'b1111;
        #10;
        if (instruction_tb !== 13'b1111111111111)
            $display("ERROR: Address 15");
        else
            $display("PASS: Address 15");

        $display("Instruction Memory Initialisation test completed.");
        $finish;
        
    end
endmodule