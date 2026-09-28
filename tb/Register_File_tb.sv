`timescale 1ns / 1ps

module Register_File_tb;

    logic clk_tb, rst_tb, write_enable_tb;
    logic [1:0] write_address_tb, read_address1_tb, read_address2_tb;
    logic [7:0] write_data_tb;
    
    logic [7:0] read_data1_tb, read_data2_tb;

    Register_File uut(.clk(clk_tb), .rst(rst_tb), .write_enable(write_enable_tb), .write_address(write_address_tb),
                      .write_data(write_data_tb), .read_address1(read_address1_tb), .read_address2(read_address2_tb),
                      .read_data1(read_data1_tb), .read_data2(read_data2_tb));

    // Generates VCD waveform files for online EDA tools.
    initial begin
        $dumpfile("Register_File.vcd");
        $dumpvars(0, Register_File_tb);
    end

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

        // Reset
        #10;
        rst_tb = 0;

        // Write 10101010 to R1
        write_enable_tb = 1;
        write_address_tb = 2'b01;
        write_data_tb = 8'b10101010;
        #10;

        // Write 01100110 to R2
        write_address_tb = 2'b10;
        write_data_tb = 8'b01100110;
        #10;

        // Read R1 and R2
        write_enable_tb = 0;
        read_address1_tb = 2'b01;
        read_address2_tb = 2'b10;
        #1;

        if (read_data1_tb !== 8'b10101010)
            $display("ERROR: R1 read failed");
        else
            $display("PASS: R1 read = %b", read_data1_tb);

        if (read_data2_tb !== 8'b01100110)
            $display("ERROR: R2 read failed");
        else
            $display("PASS: R2 read = %b", read_data2_tb);

        // Writing with write_enable = 0 (should NOT update R1)
        write_enable_tb = 0;
        write_address_tb = 2'b01;
        write_data_tb = 8'b11111111;
        #10;

        read_address1_tb = 2'b01;
        #1;

        if (read_data1_tb !== 8'b10101010)
            $display("ERROR: R1 changed when write_enable = 0");
        else
            $display("PASS: R1 unchanged when write_enable = 0");

        // Reset verification
        rst_tb = 1;
        #10;
        rst_tb = 0;

        // Verify R1 and R2 are cleared after reset
        read_address1_tb = 2'b01;
        read_address2_tb = 2'b10;
        #1;

        if (read_data1_tb !== 8'b00000000)
            $display("ERROR: R1 not cleared after reset");
        else
            $display("PASS: R1 cleared after reset");

        if (read_data2_tb !== 8'b00000000)
            $display("ERROR: R2 not cleared after reset");
        else
            $display("PASS: R2 cleared after reset");

        $finish;
    end

endmodule
