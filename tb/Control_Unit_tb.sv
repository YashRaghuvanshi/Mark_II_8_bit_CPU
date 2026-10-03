`timescale 1ns / 1ps

module Control_Unit_tb;

    logic clk_tb;
    logic rst_tb;
    logic [12:0] instruction_tb;

    logic alu_done_tb;
    logic alu_div_zero_tb;
    logic alu_zero_tb;
    logic alu_carry_tb;
    logic alu_negative_tb;

    logic reg_write_enable_tb;
    logic [1:0] reg_write_address_tb;
    logic [1:0] reg_read_address1_tb;
    logic [1:0] reg_read_address2_tb;

    logic data_mem_write_enable_tb;
    logic [3:0] data_mem_address_tb;

    logic pc_enable_tb;
    logic jump_tb;
    logic [3:0] jump_target_tb;

    logic [1:0] writeback_select_tb;
    logic mul_high_select_tb;
    logic mul_start_tb;
    logic div_start_tb;
    logic flag_write_enable_tb;
    logic halt_tb;

    integer pass_count = 0;
    integer fail_count = 0;

    Control_Unit uut (.clk(clk_tb), .rst(rst_tb), .instruction(instruction_tb), .alu_busy(1'b0), .alu_done(alu_done_tb),
                      .alu_div_zero(alu_div_zero_tb),
                      .alu_zero(alu_zero_tb), .alu_carry(alu_carry_tb), .alu_negative(alu_negative_tb),
                      .reg_write_enable(reg_write_enable_tb), .reg_write_address(reg_write_address_tb),
                      .reg_read_address1(reg_read_address1_tb), .reg_read_address2(reg_read_address2_tb),
                      .data_mem_write_enable(data_mem_write_enable_tb), .data_mem_address(data_mem_address_tb),
                      .pc_enable(pc_enable_tb), .jump(jump_tb), .jump_target(jump_target_tb),
                      .writeback_select(writeback_select_tb), .mul_high_select(mul_high_select_tb),
                      .mul_start(mul_start_tb), .div_start(div_start_tb),
                      .flag_write_enable(flag_write_enable_tb), .halt(halt_tb));

    // Clock
    always #5 clk_tb = ~clk_tb;

    // Tasks
    // -----------------------------------------------------------------------------------------------------
    // 1. General test checker
    task automatic check(input logic condition, input string name);

        if (condition) begin
            $display("PASS: %0s", name);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: %0s", name);
            fail_count = fail_count + 1;
        end

    endtask
    
    // -----------------------------------------------------------------------------------------------------
    // 2. Reset CPU
    task automatic reset_cpu;
        rst_tb = 1'b1;

        @(posedge clk_tb);
        @(posedge clk_tb);
        @(negedge clk_tb);

        check(!reg_write_enable_tb && !pc_enable_tb && !jump_tb && !halt_tb, "1 - RESET");
        rst_tb = 1'b0;
        
    endtask
    
    // -----------------------------------------------------------------------------------------------------
    // 3. Move FETCH -> DECODE -> EXECUTE
    task automatic execute_instruction;

        @(posedge clk_tb);      // FETCH -> DECODE
        @(posedge clk_tb);      // DECODE -> EXECUTE
        @(negedge clk_tb);      // Wait for combinational outputs to settle

    endtask

    // -----------------------------------------------------------------------------------------------------
    // 4. Multicycle MUL / DIV test
    
    task automatic test_multicycle(
        input logic [4:0] op,
        input logic [1:0] rd,
        input logic [1:0] wb_sel,
        input logic is_mul,  // To check MUL_HIGH_WRITE state
        input string name
       );

        instruction_tb = {op, rd, 2'b00, 4'h0};
        alu_done_tb = 1'b0;
        alu_div_zero_tb = 1'b0;
        execute_instruction();

        @(posedge clk_tb);  // Moves from EXECUTE -> WAIT_MULDIV
        @(negedge clk_tb);
        check(!reg_write_enable_tb && !pc_enable_tb, {name, "_A - WAIT"});

        @(posedge clk_tb);  // Should be same state as alu_done = 0;
        @(negedge clk_tb);
        check(!reg_write_enable_tb && !pc_enable_tb, {name, "_B - WAIT HOLD"});

        // Finish operation
        alu_done_tb = 1'b1;

        @(posedge clk_tb);  // Should move to WRITEBACK
        @(negedge clk_tb);
        check(reg_write_enable_tb && reg_write_address_tb == rd && writeback_select_tb == wb_sel && pc_enable_tb,
             {name, "_C - WRITEBACK"});

        alu_done_tb = 1'b0;

        if (is_mul) begin

            @(posedge clk_tb);  // WRITEBACK -> MUL_HIGH_WRITE
            @(negedge clk_tb);
            check(reg_write_enable_tb && reg_write_address_tb == rd + 1'b1 &&
                  writeback_select_tb == wb_sel && mul_high_select_tb && !pc_enable_tb, {name, "_D - HIGH WRITEBACK"});

            @(posedge clk_tb);  // MUL_HIGH_WRITE -> FETCH
            @(negedge clk_tb);

        end
        
        else begin
            @(posedge clk_tb);  // WRITEBACK -> FETCH
            @(negedge clk_tb);
        end

    endtask

    // -----------------------------------------------------------------------------------------------------
    // 5. Branch test
    
    task automatic test_branch(
        input logic [4:0] op,
        input logic flag_value,
        input logic [3:0] target,
        input logic expected_jump,
        input string name
    );

        instruction_tb = {op, 2'b00, 2'b00, target};

        alu_zero_tb     = 1'b0;
        alu_carry_tb    = 1'b0;
        alu_negative_tb = 1'b0;

        case (op)
            5'b10011,
            5'b10100:
                alu_zero_tb = flag_value;

            5'b10101:
                alu_carry_tb = flag_value;

            5'b10110:
                alu_negative_tb = flag_value;
        endcase

        execute_instruction();

        check(jump_tb == expected_jump && pc_enable_tb == !expected_jump && 
             (!expected_jump || jump_target_tb == target), name);

        // Branch -> FETCH
        @(posedge clk_tb);
        @(negedge clk_tb);

    endtask

    // -----------------------------------------------------------------------------------------------------
    // Test sequence

    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b0;
        instruction_tb = 13'b0;
        alu_done_tb = 1'b0;
        alu_div_zero_tb = 1'b0;
        alu_zero_tb = 1'b0;
        alu_carry_tb = 1'b0;
        alu_negative_tb = 1'b0;

        // -------------------------------------------------------------------------------------------------
        // 1. RESET
        reset_cpu();

        // -------------------------------------------------------------------------------------------------
        // 2. REGISTER ADDRESS DECODE
        instruction_tb = {5'b00100, 2'b11, 2'b10, 4'b0000};
        #1;

        check(reg_read_address1_tb == 2'b11 && reg_read_address2_tb == 2'b10, "2 - REGISTER READ ADDRESSES");

        // -------------------------------------------------------------------------------------------------
        // 3. NORMAL ALU WRITEBACK
        instruction_tb = {5'b00100, 2'b01, 2'b10, 4'b0000};
        execute_instruction();
        check(flag_write_enable_tb, "3A - ALU FLAG WRITE");

        @(posedge clk_tb);
        @(negedge clk_tb);

        check(reg_write_enable_tb && reg_write_address_tb == 2'b01 && writeback_select_tb == 2'b00 &&
              pc_enable_tb, "3B - ALU WRITEBACK");

        @(posedge clk_tb);
        @(negedge clk_tb);

        // -------------------------------------------------------------------------------------------------
        // 4. LOAD
        instruction_tb = {5'b01100, 2'b10, 2'b00, 4'hA};
        execute_instruction();

        check(!data_mem_write_enable_tb && data_mem_address_tb == 4'hA, "4A - LOAD EXECUTE");
        @(posedge clk_tb);
        @(negedge clk_tb);

        check(reg_write_enable_tb && reg_write_address_tb == 2'b10 && writeback_select_tb == 2'b01 &&
              pc_enable_tb, "4B - LOAD WRITEBACK");

        @(posedge clk_tb);
        @(negedge clk_tb);

        // -------------------------------------------------------------------------------------------------
        // 5. STORE
        instruction_tb = {5'b01101, 2'b01, 2'b00, 4'hB};
        execute_instruction();

        check(data_mem_write_enable_tb && data_mem_address_tb == 4'hB && pc_enable_tb, "5 - STORE");

        @(posedge clk_tb);
        @(negedge clk_tb);

        // -------------------------------------------------------------------------------------------------
        // 6. JUMP
        instruction_tb = {5'b01110, 2'b00, 2'b00, 4'hC};
        execute_instruction();

        check(jump_tb && jump_target_tb == 4'hC && !pc_enable_tb, "6 - JUMP");
        @(posedge clk_tb);
        @(negedge clk_tb);

        // -------------------------------------------------------------------------------------------------
        // 7. MUL

        test_multicycle(5'b10000, 2'b01, 2'b10, 1'b1, "7 - MUL");

        // -------------------------------------------------------------------------------------------------
        // 8. DIV

        test_multicycle(5'b10001, 2'b10, 2'b11, 1'b0, "8 - DIV");

        // -------------------------------------------------------------------------------------------------
        // 9. DIVISION BY ZERO
    
           instruction_tb = {5'b10001, 2'b10, 2'b01, 4'h0};
           alu_done_tb = 1'b0;
           alu_div_zero_tb = 1'b0;
           execute_instruction();
            
           @(posedge clk_tb);  // EXECUTE -> WAIT_MULDIV
           @(negedge clk_tb);
            
           check(!reg_write_enable_tb && !pc_enable_tb, "9A - DIV ZERO WAIT");
           alu_div_zero_tb = 1'b1;
   
           #1;
            
            check(!reg_write_enable_tb && pc_enable_tb, "9B - DIV ZERO EXIT");
            
            @(posedge clk_tb);  // WAIT_MULDIV -> FETCH
            @(negedge clk_tb);
            
            alu_div_zero_tb = 1'b0;
            
        // -------------------------------------------------------------------------------------------------
        // 10. BRANCHES

        test_branch(5'b10011, 1'b1, 4'h5, 1'b1, "10A - BEQ TAKEN");
        test_branch(5'b10011, 1'b0, 4'h5, 1'b0, "10B - BEQ NOT TAKEN");

        test_branch(5'b10100, 1'b0, 4'h6, 1'b1, "10C - BNE TAKEN");
        test_branch(5'b10100, 1'b1, 4'h6, 1'b0, "10D - BNE NOT TAKEN");

        test_branch(5'b10101, 1'b1, 4'h7, 1'b1, "10E - BC TAKEN");
        test_branch(5'b10101, 1'b0, 4'h7, 1'b0, "10F - BC NOT TAKEN");

        test_branch(5'b10110, 1'b1, 4'h8, 1'b1, "10G - BN TAKEN");
        test_branch(5'b10110, 1'b0, 4'h8, 1'b0, "10H - BN NOT TAKEN");

        // -------------------------------------------------------------------------------------------------
        // 11. HALT
        instruction_tb = {5'b01111, 2'b00, 2'b00, 4'b0000};
        execute_instruction();

        check(halt_tb, "11A - HALT EXECUTE");
        @(posedge clk_tb);
        @(negedge clk_tb);

        check(halt_tb, "11B - HALTED STATE");

        // -------------------------------------------------------------------------------------------------
        // SUMMARY
        // -------------------------------------------------------------------------------------------------
        
        $display("========================================");
        $display("       CONTROL UNIT TEST SUMMARY");
        $display("========================================");
        $display("PASSED : %0d", pass_count);
        $display("FAILED : %0d", fail_count);
        
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
        $display("========================================");
        $finish;
    end
endmodule