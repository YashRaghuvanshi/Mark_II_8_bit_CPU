`timescale 1ns / 1ps

module Program_Counter_tb;

    logic clk_tb;
    logic rst_tb;
    logic jump_tb;
    logic pc_enable_tb;
    logic [3:0] jump_target_tb;
    logic [3:0] pc_tb;

    Program_Counter uut (.clk(clk_tb), .rst(rst_tb), .jump(jump_tb), .pc_enable(pc_enable_tb), 
                         .jump_target(jump_target_tb), .pc(pc_tb));

    // Clock generation
    always #5 clk_tb = ~clk_tb;

    initial begin
        clk_tb = 0;
        rst_tb = 1;
        jump_tb = 0;
        pc_enable_tb = 0;
        jump_target_tb = 4'b0000;

        // Reset
        #10;
        rst_tb = 0;

        if (pc_tb !== 4'b0000)
            $display("ERROR: PC did not reset to 0");
        else
            $display("PASS: PC reset to 0");

        // Normal counting
        pc_enable_tb = 1;
        #10;

        if (pc_tb !== 4'b0001)
            $display("ERROR: PC did not increment to 1");
        else
            $display("PASS: PC incremented to 1");

        #10;

        if (pc_tb !== 4'b0010)
            $display("ERROR: PC did not increment to 2");
        else
            $display("PASS: PC incremented to 2");

        // Jump to instruction-memory location 9
        jump_tb = 1;
        jump_target_tb = 4'b1001;
        #10;
        jump_tb = 0;

        if (pc_tb !== 4'b1001)
            $display("ERROR: PC did not jump to 9");
        else
            $display("PASS: PC jumped to instruction-memory location 9");

        // Continue counting after jump
        #10;

        if (pc_tb !== 4'b1010)
            $display("ERROR: PC did not increment to 10 after jump");
        else
            $display("PASS: PC continued counting after jump");

        // Test jump priority over pc_enable
        jump_tb = 1;
        jump_target_tb = 4'b1100;
        pc_enable_tb = 1;
        #10;
        jump_tb = 0;

        if (pc_tb !== 4'b1100)
            $display("ERROR: Jump did not have priority over PC increment");
        else
            $display("PASS: Jump has priority over PC increment");

        // Reset mid-operation
        pc_enable_tb = 0;
        rst_tb = 1;
        #10;
        rst_tb = 0;

        if (pc_tb !== 4'b0000)
            $display("ERROR: PC did not reset to 0 during operation");
        else
            $display("PASS: PC reset correctly during operation");

        $display("Program Counter test completed.");
        $finish;
    end

endmodule