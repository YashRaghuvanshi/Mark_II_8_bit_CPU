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
        // Test 1: Reset Memory
        rst_tb = 1;
        #10;
        rst_tb = 0;

        address_tb = 4'b0011;
        #1;

        if (read_data_tb !== 8'b0)
            $display("ERROR: Test 1 - Memory did not reset to 0");
        else
            $display("PASS: Test 1 - Memory reset");
        
        // ----------------------------------------------------------------------------------------
        // Test 2: Write Data
        address_tb = 4'b0011;
        write_data_tb = 8'b10101010;
        write_enable_tb = 1;

        #10;
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

        #10;
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
        address_tb = 4'b0101;
        write_data_tb = 8'b11111111;
        write_enable_tb = 0;

        #10;

        if (read_data_tb !== 8'b0)
            $display("ERROR: Test 6 - Data changed with write disabled");
        else
            $display("PASS: Test 6 - Write disabled");
        
        // ----------------------------------------------------------------------------------------
        // Test 7: Reset Clears Stored Data
        rst_tb = 1;
        #10;
        rst_tb = 0;

        address_tb = 4'b0011;
        #1;

        if (read_data_tb !== 8'b0)
            $display("ERROR: Test 7 - Reset did not clear memory");
        else
            $display("PASS: Test 7 - Reset cleared memory");

        $display("Data Memory test completed.");
        $finish;

    end
endmodule