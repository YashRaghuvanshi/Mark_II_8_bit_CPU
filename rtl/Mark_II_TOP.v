`timescale 1ns / 1ps

module Mark_II_TOP #(
    parameter PROGRAM_FILE = "branch_test.mem",
    parameter DATA_FILE    = "branch_data.mem"
)(
    input clk, 
    input rst,
    output halt
);
    
    // INTERNAL WIRES & SIGNALS
    // -----------------------------------------------
    // 1. Program Counter
    wire pc_enable;
    wire jump;
    wire [3:0] jump_target;
    wire [3:0] pc;
    
    // -----------------------------------------------
    // 2. Register File
    wire reg_write_enable;
    wire [1:0] reg_write_address;
    wire [1:0] reg_read_address1;
    wire [1:0] reg_read_address2;

    wire [7:0] reg_read_data1;
    wire [7:0] reg_read_data2;
    reg [7:0] reg_write_data;
    
    // -----------------------------------------------
    // 3. Instruction Memory
    wire [12:0] instruction;
    
    // -----------------------------------------------
    // 4. Data Memory
    wire data_mem_write_enable;
    wire [3:0] data_mem_address;
    wire [7:0] data_mem_write_data;
    wire [7:0] data_mem_read_data;
    
    // -----------------------------------------------
    // 5. ALU
    wire [7:0] A;
    wire [7:0] B;
    wire Cin;
    wire [4:0] opcode;

    wire [7:0] Y;

    wire Carry;
    wire Zero;
    wire Negative;
    wire Overflow;
    
    // Register to store ALU flags for operation
    reg flag_carry;
    reg flag_zero;
    reg flag_negative;
    reg flag_overflow;

    wire [15:0] mul_result;
    wire [7:0] quotient;
    wire [7:0] remainder;

    wire mul_busy;
    wire mul_done;
    wire div_busy;
    wire div_done;
    wire div_zero;

    wire busy;
    wire done;
    
    // -----------------------------------------------
    // 6. Control Unit
    wire [1:0] writeback_select;
    wire mul_high_select;
    wire mul_start;
    wire div_start;
    wire flag_write_enable;
    
    // MODULE INSTANTIATION
   
    // ---------------------------------------------------------------------------------------------------------------
    // 1. Program Counter
    Program_Counter PC (.clk(clk), .rst(rst), .jump(jump), .pc_enable(pc_enable), .jump_target(jump_target), .pc(pc));
    
    // ---------------------------------------------------------------------------------------------------------------
    // 2. Instruction Memory
    Instruction_Memory #(
        .PROGRAM_FILE(PROGRAM_FILE)
    ) IM (.address(pc), .instruction(instruction));

    // ---------------------------------------------------------------------------------------------------------------
    // 3. Register File
    Register_File RF (.clk(clk), .rst(rst), .write_enable(reg_write_enable), .write_address(reg_write_address),
                      .write_data(reg_write_data), .read_address1(reg_read_address1), .read_address2(reg_read_address2),
                      .read_data1(reg_read_data1), .read_data2(reg_read_data2));
    
    // ---------------------------------------------------------------------------------------------------------------
    // 4. ALU
    ALU_8_bit ALU (.clk(clk), .rst(rst), .A(A), .B(B), .Cin(Cin), .opcode(opcode), .mul_start(mul_start),
                   .div_start(div_start), .Y(Y), .Carry(Carry), .Zero(Zero), .Negative(Negative),
                   .Overflow(Overflow), .mul_result(mul_result), .quotient(quotient),
                   .remainder(remainder), .mul_busy(mul_busy), .mul_done(mul_done), .div_busy(div_busy),
                   .div_done(div_done), .div_zero(div_zero), .busy(busy), .done(done));
    
    // ---------------------------------------------------------------------------------------------------------------
    // 5. Data Memory
    Data_Memory #(
        .DATA_FILE(DATA_FILE)
    ) DM (.clk(clk), .rst(rst), .write_enable(data_mem_write_enable), .address(data_mem_address),
          .write_data(data_mem_write_data), .read_data(data_mem_read_data));
    
    // ---------------------------------------------------------------------------------------------------------------
    // 6. Control Unit
    Control_Unit CU (.clk(clk), .rst(rst), .instruction(instruction), .alu_busy(busy), .alu_done(done),
                     .alu_zero(flag_zero), .alu_carry(flag_carry), .alu_negative(flag_negative),
                     .reg_write_enable(reg_write_enable), .reg_write_address(reg_write_address),
                     .reg_read_address1(reg_read_address1), .reg_read_address2(reg_read_address2),
                     .data_mem_write_enable(data_mem_write_enable), .data_mem_address(data_mem_address),
                     .pc_enable(pc_enable), .jump(jump), .jump_target(jump_target), 
                     .writeback_select(writeback_select), .mul_high_select(mul_high_select), .mul_start(mul_start), 
                     .div_start(div_start), .alu_div_zero(div_zero), .flag_write_enable(flag_write_enable), .halt(halt));
                     
    // ---------------------------------------------------------------------------------------------------------------
    
    // ALU inputs
    assign A = reg_read_data1;
    assign B = reg_read_data2;
    assign opcode = instruction[12:8];
    assign Cin = 1'b0;
    
    // STORE's data path
    assign data_mem_write_data = reg_read_data1; // STORE data comes from Rd
    
    // WRITEBACK path
    always @(*) begin
        case(writeback_select)
            2'b00:
                reg_write_data = Y;                     // ALU

            2'b01:
                reg_write_data = data_mem_read_data;   // LOAD

            2'b10: begin
                if (mul_high_select)
                    reg_write_data = mul_result[15:8]; // MUL high
                else
                    reg_write_data = mul_result[7:0];  // MUL low
            end

            2'b11:
                reg_write_data = quotient;             // DIV

            default:
                reg_write_data = 8'b0;
        endcase
    end 
    
    // Flag register block
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            flag_carry    <= 1'b0;
            flag_zero     <= 1'b0;
            flag_negative <= 1'b0;
            flag_overflow <= 1'b0;
        end
        else if (flag_write_enable) begin
            flag_carry    <= Carry;
            flag_zero     <= Zero;
            flag_negative <= Negative;
            flag_overflow <= Overflow;
        end
    end
    
endmodule