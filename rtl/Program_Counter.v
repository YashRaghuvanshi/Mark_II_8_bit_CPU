module Program_Counter(
    input clk,
    input rst,
    input jump,
    input pc_enable,
    input [3:0] jump_target, // Instruction-memory location to jump to
    output reg [3:0] pc      // 4-bit PC selects 1 of 16 instruction-memory locations
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 4'b0000;
        else if (jump)
            pc <= jump_target;
        else if (pc_enable)
            pc <= pc + 1'b1;
    end

endmodule