`timescale 1ns / 1ps

module Data_Memory #(
    parameter DATA_FILE = "branch_data.mem"
)(
    input clk,
    input rst,
    input write_enable,
    input [3:0] address,
    input [7:0] write_data,
    
    output [7:0] read_data
    );
    reg [7:0] memory [0:15];
    
    // LOAD INITIAL DATA FROM FILE
    initial begin
        $readmemb(DATA_FILE, memory);
    end
    
    always @(posedge clk) begin
        if (write_enable) begin
            memory[address] <= write_data;
        end
    end
    
    // Asynchronous read
    assign read_data = memory[address];
endmodule

