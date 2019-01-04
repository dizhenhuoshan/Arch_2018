`include "defines.v"
module pc_reg(
    input wire                  clk,
    input wire                  rst,
    input wire                  rdy,

    output reg[`InstAddrBus]    pc,

    // ctrl signal
    input wire[`StallBus]       stall_sign,

    // branch input
    input wire                  branch_enable_i,
    input wire[`InstAddrBus]    branch_addr_i
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            pc <= 32'h00000000;
        end else if (branch_enable_i == 1'b1) begin
            pc <= branch_addr_i;
        end else if (rdy == `PauseDisable && stall_sign[0] == 1'b0) begin
            pc <= pc + 4;
        end
    end

endmodule //
