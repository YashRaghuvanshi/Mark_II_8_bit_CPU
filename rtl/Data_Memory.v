`timescale 1ns / 1ps

module Data_Memory(
    input clk,
    input rst,
    
    input write_enable,
    input [3:0] address,
    input [7:0] write_data,
    
    output [7:0] read_data
    );
    
    reg [7:0] memory [0:15];
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<16; i = i+1)
                memory[i] <= 8'b0;
        end
        
        else if (write_enable) begin
            memory[address] <= write_data;
        end
    end
    
    // Asynchronous read
    assign read_data = memory[address];
endmodule
