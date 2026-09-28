`timescale 1ns / 1ps

module Register_File(
    input clk,
    input rst,
    
    input write_enable, // Allows data to be written only when asserted
    input [1:0] write_address, // Destination register address
    input [7:0] write_data,
    
    input [1:0] read_address1, // Operand A register address
    input [1:0] read_address2, // Operand B register address
   
    output [7:0] read_data1, // Operand A data
    output [7:0] read_data2  // Operand B data
    );
    
    // Register file storage: R0, R1, R2, R3
    reg [7:0] registers [0:3];
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1)
                registers[i] <= 8'b0;  // To reset all registers to 0
            end
        
        else if (write_enable)
            registers[write_address] <= write_data;
    end  
    
    // Combinational read as the output updates as soon as address changes
    assign read_data1 = registers[read_address1];
    assign read_data2 = registers[read_address2];
    
endmodule