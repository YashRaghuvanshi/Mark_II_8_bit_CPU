`timescale 1ns / 1ps

module Register_File_tb;

    reg clk_tb, rst_tb, write_enable_tb;
    reg [1:0] write_address_tb, read_address1_tb, read_address2_tb;
    reg [7:0] write_data_tb;

    wire [7:0] read_data1_tb, read_data2_tb;

    Register_File uut(.clk(clk_tb), .rst(rst_tb), .write_enable(write_enable_tb), .write_address(write_address_tb),
                      .write_data(write_data_tb), .read_address1(read_address1_tb), .read_address2(read_address2_tb),
                      .read_data1(read_data1_tb), .read_data2(read_data2_tb));


    // Clock generation
    always #5 clk_tb = ~clk_tb;

    initial begin
        clk_tb = 0;
        rst_tb = 1;
        write_enable_tb = 0;
        write_address_tb = 0;
        write_data_tb = 0;
        read_address1_tb = 0;
        read_address2_tb = 0;

        // ----------------------------------------------------------------------------------------
        // Test 1: Reset
        @(posedge clk_tb);
        @(negedge clk_tb);

        rst_tb = 0;

        read_address1_tb = 2'b00;
        read_address2_tb = 2'b11;
        #1;

        if (read_data1_tb !== 8'b00000000)
            $display("ERROR: Test 1A - R0 not cleared after reset");
        else
            $display("PASS: Test 1A - R0 cleared after reset");

        if (read_data2_tb !== 8'b00000000)
            $display("ERROR: Test 1B - R3 not cleared after reset");
        else
            $display("PASS: Test 1B - R3 cleared after reset");

        // ----------------------------------------------------------------------------------------
        // Test 2: Write Data to R1
        write_enable_tb = 1;
        write_address_tb = 2'b01;
        write_data_tb = 8'b10101010;

        @(posedge clk_tb);
        @(negedge clk_tb);

        write_enable_tb = 0;

        read_address1_tb = 2'b01;
        #1;

        if (read_data1_tb !== 8'b10101010)
            $display("ERROR: Test 2 - R1 write failed");
        else
            $display("PASS: Test 2 - R1 written correctly = %b", read_data1_tb);

        // ----------------------------------------------------------------------------------------
        // Test 3: Write Data to R2
        write_enable_tb = 1;
        write_address_tb = 2'b10;
        write_data_tb = 8'b01100110;

        @(posedge clk_tb);
        @(negedge clk_tb);

        write_enable_tb = 0;
        read_address2_tb = 2'b10;
        #1;

        if (read_data2_tb !== 8'b01100110)
            $display("ERROR: Test 3 - R2 write failed");
        else
            $display("PASS: Test 3 - R2 written correctly = %b", read_data2_tb);

        // ----------------------------------------------------------------------------------------
        // Test 4: Read R1 and R2 Simultaneously
        read_address1_tb = 2'b01;
        read_address2_tb = 2'b10;
        #1;

        if (read_data1_tb !== 8'b10101010)
            $display("ERROR: Test 4A - R1 read failed");
        else
            $display("PASS: Test 4A - R1 read = %b", read_data1_tb);

        if (read_data2_tb !== 8'b01100110)
            $display("ERROR: Test 4B - R2 read failed");
        else
            $display("PASS: Test 4B - R2 read = %b", read_data2_tb);

        // ----------------------------------------------------------------------------------------
        // Test 5: Writing with write_enable = 0

        // Attempt to overwrite R1 while write is disabled.
        write_enable_tb = 0;
        write_address_tb = 2'b01;
        write_data_tb = 8'b11111111;

        @(posedge clk_tb);
        @(negedge clk_tb);

        read_address1_tb = 2'b01;
        #1;

        if (read_data1_tb !== 8'b10101010)
            $display("ERROR: Test 5 - R1 changed when write_enable = 0");
        else
            $display("PASS: Test 5 - R1 unchanged when write_enable = 0");

        // ----------------------------------------------------------------------------------------
        // Test 6: Write to Boundary Registers
        
        // Write to R0
        write_enable_tb = 1;
        write_address_tb = 2'b00;
        write_data_tb = 8'b11001100;

        @(posedge clk_tb);
        @(negedge clk_tb);

        write_enable_tb = 0;
        read_address1_tb = 2'b00;
        #1;

        if (read_data1_tb !== 8'b11001100)
            $display("ERROR: Test 6A - R0 write failed");
        else
            $display("PASS: Test 6A - R0 written correctly = %b", read_data1_tb);

        // Write to R3
        write_enable_tb = 1;
        write_address_tb = 2'b11;
        write_data_tb = 8'b00110011;

        @(posedge clk_tb);
        @(negedge clk_tb);

        write_enable_tb = 0;
        read_address2_tb = 2'b11;
        #1;

        if (read_data2_tb !== 8'b00110011)
            $display("ERROR: Test 6B - R3 write failed");
        else
            $display("PASS: Test 6B - R3 written correctly = %b", read_data2_tb);

        // ----------------------------------------------------------------------------------------
        // Test 7: Reset Verification
        rst_tb = 1;

        @(posedge clk_tb);
        @(negedge clk_tb);

        rst_tb = 0;

        // Verify R0 and R3 are cleared after reset
        read_address1_tb = 2'b00;
        read_address2_tb = 2'b11;
        #1;

        if (read_data1_tb !== 8'b00000000)
            $display("ERROR: Test 7A - R0 not cleared after reset");
        else
            $display("PASS: Test 7A - R0 cleared after reset");

        if (read_data2_tb !== 8'b00000000)
            $display("ERROR: Test 7B - R3 not cleared after reset");
        else
            $display("PASS: Test 7B - R3 cleared after reset");
        
        $display("-----------------------------");
        $display("Register File test completed.");
        $display("-----------------------------");
        $finish;
    end
endmodule