`timescale 1ns / 1ps

module Control_Unit(

    input clk,
    input rst,
    input [12:0] instruction,

    // ALU status
    input alu_busy,
    input alu_done,
    input alu_div_zero,

    // ALU flags
    input alu_zero,
    input alu_carry,
    input alu_negative,

    // Register File control
    output reg reg_write_enable,
    output reg [1:0] reg_write_address,
    output reg [1:0] reg_read_address1,
    output reg [1:0] reg_read_address2,

    // Data Memory control
    output reg data_mem_write_enable,
    output reg [3:0] data_mem_address,

    // Program Counter control
    output reg pc_enable,
    output reg jump,
    output reg [3:0] jump_target,

    // Writeback control
    output reg [1:0] writeback_select,
    output reg mul_high_select,
    output reg mul_start,
    output reg div_start,
    
    // CPU flags
    output reg flag_write_enable,
    
    // CPU halt
    output reg halt);

    // FSM States
    localparam FETCH          = 3'b000;
    localparam DECODE         = 3'b001;
    localparam EXECUTE        = 3'b010;
    localparam WAIT_MULDIV    = 3'b011;
    localparam WRITEBACK      = 3'b100;
    localparam HALTED         = 3'b101;
    localparam MUL_HIGH_WRITE = 3'b110;    // Write higher 8 bits of MUL result
    
    reg [2:0] current_state;
    reg [2:0] next_state;
    reg [1:0] mul_rd;
    
    // Instruction format
    wire [4:0] opcode = instruction[12:8];
    wire [1:0] rd     = instruction[7:6];
    wire [1:0] rs     = instruction[5:4];
    wire [3:0] field  = instruction[3:0];
    
    // State register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= FETCH;
            mul_rd <= 2'b00;
        end
        else begin
            current_state <= next_state;
    
            if (current_state == EXECUTE && opcode == 5'b10000)
                mul_rd <= rd;   // To save the destination when MUL enters EXECUTE
        end
    end
    
    // Combinational next-state logic
    always @(*) begin
        next_state = current_state;

        case (current_state)
            FETCH: begin
                next_state = DECODE;
            end

            DECODE: begin
                next_state = EXECUTE;
            end

            EXECUTE: begin
                case (opcode)
                    // ALU operations
                    5'b00000, // AND
                    5'b00001, // OR
                    5'b00010, // NOT
                    5'b00011, // XOR
                    5'b00100, // ADD
                    5'b00101, // SUB
                    5'b00110, // SLL
                    5'b00111, // SRL
                    5'b01000, // SEQ
                    5'b01001, // SLT
                    5'b01010, // SGT
                    5'b01011, // INC
                    5'b10010: // SRA
                        next_state = WRITEBACK;
            
                    // LOAD
                    5'b01100:
                        next_state = WRITEBACK;
            
                    // STORE
                    5'b01101:
                        next_state = FETCH;
            
                    // JUMP
                    5'b01110:
                        next_state = FETCH;
            
                    // HALT
                    5'b01111:
                        next_state = HALTED;
            
                    // MUL
                    5'b10000: begin
                              if (rd != 2'b11)
                                next_state = WAIT_MULDIV;
                              else
                                next_state = FETCH;  // Prevents MUL R3 from using R0 as the high-byte destination
                              end
                              
                    // DIV
                    5'b10001:
                        next_state = WAIT_MULDIV;
            
                    // Conditional branches
                    5'b10011, // BEQ
                    5'b10100, // BNE
                    5'b10101, // BC
                    5'b10110: // BN
                        next_state = FETCH;
            
                    default:
                        next_state = FETCH;
                endcase
            end

            WAIT_MULDIV: begin
                         if (opcode == 5'b10001 && alu_div_zero)
                            next_state = FETCH;
                         else if (alu_done)
                            next_state = WRITEBACK;
                         end

            WRITEBACK: begin
                if (opcode == 5'b10000)
                    next_state = MUL_HIGH_WRITE;
                else
                    next_state = FETCH;
            end

            MUL_HIGH_WRITE: begin
                next_state = FETCH;
            end

            HALTED: begin
                next_state = HALTED;
            end

            default: begin
                next_state = FETCH;
            end

        endcase
    end
    
    // Output combinational logic
    always @(*) begin
        // Default values
        {pc_enable, jump, halt, reg_write_enable, data_mem_write_enable} = 5'b00000;
        reg_write_address = 2'b00;
        reg_read_address1 = rd;
        reg_read_address2 = rs;
        data_mem_address = field;
        jump_target = 4'b0000;
        writeback_select = 2'b00;
        mul_high_select = 1'b0;
        mul_start = 1'b0;
        div_start = 1'b0;
        flag_write_enable = 1'b0;
        
        case(current_state)
        
        // FETCH itself doesn't increment PC.
        FETCH: begin
            // No active control signals required
        end
        
        DECODE: begin
            // No active control signals required
        end
        
        EXECUTE: begin
            case (opcode)
                // ALU operations
                5'b00000, // AND
                5'b00001, // OR
                5'b00010, // NOT
                5'b00011, // XOR
                5'b00100, // ADD
                5'b00101, // SUB
                5'b00110, // SLL
                5'b00111, // SRL
                5'b01000, // SEQ
                5'b01001, // SLT
                5'b01010, // SGT
                5'b01011, // INC
                5'b10010: begin // SRA
                    flag_write_enable = 1'b1;
                end
                
                // MUL
                5'b10000: begin
                    mul_start = 1'b1;
                end
                
                // DIV
                5'b10001: begin
                    div_start = 1'b1;
                end
                
                // LOAD
                5'b01100:
                    data_mem_address = field;
        
                // STORE
                5'b01101: begin
                    data_mem_address = field;
                    data_mem_write_enable = 1'b1;
                    pc_enable = 1'b1;
                end
        
                // JUMP
                5'b01110: begin
                    jump = 1'b1;
                    jump_target = field;
                end
        
                // HALT
                5'b01111:
                    halt = 1'b1;
                
                // BEQ - Branch if Zero flag is set
                5'b10011: begin
                    if (alu_zero) begin
                        jump = 1'b1;
                        jump_target = field;
                    end
                    else begin
                        pc_enable = 1'b1;
                    end
                end
        
                // BNE - Branch if Zero flag is clear
                5'b10100: begin
                    if (!alu_zero) begin
                        jump = 1'b1;
                        jump_target = field;
                    end
                    else begin
                        pc_enable = 1'b1;
                    end
                end
        
                // BC - Branch if Carry flag is set
                5'b10101: begin
                    if (alu_carry) begin
                        jump = 1'b1;
                        jump_target = field;
                    end
                    else begin
                        pc_enable = 1'b1;
                    end
                end
        
                // BN - Branch if Negative flag is set
                5'b10110: begin
                    if (alu_negative) begin
                        jump = 1'b1;
                        jump_target = field;
                    end
                    else begin
                        pc_enable = 1'b1;
                    end
                end
            endcase
        end
        
        WAIT_MULDIV: begin
            if (alu_div_zero)
                pc_enable = 1'b1;
        end
        
        WRITEBACK: begin
            reg_write_enable = 1'b1;
            reg_write_address = rd;
            pc_enable = 1'b1;
        
            case (opcode)
                5'b01100: writeback_select = 2'b01; // LOAD
                5'b10000: writeback_select = 2'b10; // MUL (same select used for lower and higher 8 bits in 2 clock cycles)
                5'b10001: writeback_select = 2'b11; // DIV
                default:  writeback_select = 2'b00; // ALU
            endcase
        end

        MUL_HIGH_WRITE: begin
            reg_write_enable = 1'b1;
            reg_write_address = mul_rd + 1'b1;
            writeback_select = 2'b10; // MUL
            mul_high_select = 1'b1;
        end
        
        HALTED: begin
            halt = 1'b1;
        end
        
        default: begin
            // Defaults declared above
        end
        endcase
    end
endmodule