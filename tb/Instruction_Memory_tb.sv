`timescale 1ns / 1ps

module Instruction_Memory_tb;

    logic [3:0] address_tb;
    logic [12:0] instruction_tb;

    Instruction_Memory uut (.address(address_tb), .instruction(instruction_tb));

    initial begin
        // ----------------------------------------------------------------------------------------
        // Test 1: Address 0
        address_tb = 4'b0000;
        #1;

        if (instruction_tb !== 13'b0000000000001)
            $display("ERROR: Test 1 - Address 0");
        else
            $display("PASS: Test 1 - Address 0");

        // ----------------------------------------------------------------------------------------
        // Test 2: Address 1
        address_tb = 4'b0001;
        #1;

        if (instruction_tb !== 13'b0000000000010)
            $display("ERROR: Test 2 - Address 1");
        else
            $display("PASS: Test 2 - Address 1");

        // ----------------------------------------------------------------------------------------
        // Test 3: Address 2
        address_tb = 4'b0010;
        #1;

        if (instruction_tb !== 13'b0000000000011)
            $display("ERROR: Test 3 - Address 2");
        else
            $display("PASS: Test 3 - Address 2");

        // ----------------------------------------------------------------------------------------
        // Test 4: Address 15
        address_tb = 4'b1111;
        #1;

        if (instruction_tb !== 13'b1111111111111)
            $display("ERROR: Test 4 - Address 15");
        else
            $display("PASS: Test 4 - Address 15");

        // ----------------------------------------------------------------------------------------
        // Test 5: Return to Address 0
 
        // Verify that changing the address does not affect stored instructions.
        address_tb = 4'b0000;
        #1;

        if (instruction_tb !== 13'b0000000000001)
            $display("ERROR: Test 5 - Address 0 read after address change");
        else
            $display("PASS: Test 5 - Address 0 read after address change");
        
        $display("-------------------------------------------------");
        $display("Instruction Memory Initialisation test completed.");
        $display("-------------------------------------------------");
        $finish;
        
    end
endmodule