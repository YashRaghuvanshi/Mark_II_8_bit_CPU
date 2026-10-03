`timescale 1ns / 1ps

module Data_Memory_tb;

    logic clk_tb;
    logic rst_tb;
    logic write_enable_tb;
    logic [3:0] address_tb;
    logic [7:0] write_data_tb;
    logic [7:0] read_data_tb;

    Data_Memory uut (.clk(clk_tb), .rst(rst_tb), .write_enable(write_enable_tb), .address(address_tb), 
                     .write_data(write_data_tb), .read_data(read_data_tb));

    // Clock generation
    always #5 clk_tb = ~clk_tb;

    initial begin
        clk_tb = 0;
        rst_tb = 1;
        write_enable_tb = 0;
        address_tb = 4'b0000;
        write_data_tb = 8'b0;
        
        // ----------------------------------------------------------------------------------------
        // Test 1: Read Initial Memory
        //
        // Memory contents are initialized through the .mem file.
        // Reset does not clear the memory array.
        rst_tb = 1;
        @(posedge clk_tb);
        @(negedge clk_tb);
        rst_tb = 0;
        address_tb = 4'b0011;
        #1;

        if (read_data_tb !== 8'b0)
            $display("ERROR: Test 1 - Initial memory value is not 0");
        else
            $display("PASS: Test 1 - Initial memory read");
        
        // ----------------------------------------------------------------------------------------
        // Test 2: Write Data
        address_tb = 4'b0011;
        write_data_tb = 8'b10101010;
        write_enable_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        write_enable_tb = 0;

        if (read_data_tb !== 8'b10101010)
            $display("ERROR: Test 2 - Data was not written correctly");
        else
            $display("PASS: Test 2 - Data written correctly");
        
        // ----------------------------------------------------------------------------------------
        // Test 3: Read Data
        address_tb = 4'b0011;
        #1;

        if (read_data_tb !== 8'b10101010)
            $display("ERROR: Test 3 - Data read incorrectly");
        else
            $display("PASS: Test 3 - Data read correctly");
        
        // ----------------------------------------------------------------------------------------
        // Test 4: Write to Another Address
        address_tb = 4'b1010;
        write_data_tb = 8'b01100110;
        write_enable_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        write_enable_tb = 0;

        if (read_data_tb !== 8'b01100110)
            $display("ERROR: Test 4 - Data was not written to address 10");
        else
            $display("PASS: Test 4 - Data written to address 10");
        
        // ----------------------------------------------------------------------------------------
        // Test 5: Verify Previous Data is Preserved
        address_tb = 4'b0011;
        #1;

        if (read_data_tb !== 8'b10101010)
            $display("ERROR: Test 5 - Previous data was changed");
        else
            $display("PASS: Test 5 - Previous data preserved");

        // ----------------------------------------------------------------------------------------
        // Test 6: Write Disabled
        
        // Write a known value to address 5.
        address_tb = 4'b0101;
        write_data_tb = 8'b01010101;
        write_enable_tb = 1;
        
        @(posedge clk_tb);
        @(negedge clk_tb);
        
        write_enable_tb = 0;
        
        // Attempt to overwrite the same address with a different value.
        write_data_tb = 8'b11111111;
        
        @(posedge clk_tb);
        @(negedge clk_tb);
        
        if (read_data_tb !== 8'b01010101)
            $display("ERROR: Test 6 - Data changed with write disabled");
        else
            $display("PASS: Test 6 - Write disabled");
        
        // ----------------------------------------------------------------------------------------
        // Test 7: Boundary Addresses
        
        // Verify the first and last memory locations.
        
        // Write address 0
        address_tb = 4'b0000;
        write_data_tb = 8'b11001100;
        write_enable_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        write_enable_tb = 0;

        if (read_data_tb !== 8'b11001100)
            $display("ERROR: Test 7A - Address 0 was not written correctly");
        else
            $display("PASS: Test 7A - Address 0 written correctly");

        // Write address 15
        address_tb = 4'b1111;
        write_data_tb = 8'b00110011;
        write_enable_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        write_enable_tb = 0;

        if (read_data_tb !== 8'b00110011)
            $display("ERROR: Test 7B - Address 15 was not written correctly");
        else
            $display("PASS: Test 7B - Address 15 written correctly");

        $display("--------------------------------");
        $display("   All Data Memory tests done");
        $display("--------------------------------");
        $finish;

    end
endmodule