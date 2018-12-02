`include "defines.v"
module pc_reg(
    input wire                  clk,
    input wire                  rst,
    input wire                  rdy,
    output reg[`InstAddrBus]    pc
);

    // always @ (posedge clk) begin
    //     if (rdy == `PauseDisable) begin
    //         if (rst == `RstEnable) begin
    //             ce <= `ChipDisable;
    //         end else begin
    //             ce <= `ChipEnable;
    //         end
    //     end
    // end

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            pc <= 32'h00000000;
        end else if (rdy == `PauseDisable) begin
            pc <= pc + 4;
        end
    end

endmodule //
