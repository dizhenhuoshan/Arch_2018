`include"defines.v"
module mem_wb(
    input wire                  clk,
    input wire                  rst,
    input wire                  rdy,

    // ctrl signal
    input wire[`StallBus]       stall_sign,

    // read from mem
    input wire[`RegAddrBus]     mem_wd,
    input wire                  mem_wreg,
    input wire[`RegBus]         mem_wdata,

    // output to wb
    output reg[`RegAddrBus]     wb_wd,
    output reg                  wb_wreg,
    output reg[`RegBus]         wb_wdata
);

    always @ (posedge clk) begin
        if ((rst == `RstEnable) || ((stall_sign[4] == 1'b1) && (stall_sign[5] == 1'b0))) begin
            wb_wd       <= `NOPRegAddr;
            wb_wreg     <= `WriteDisable;
            wb_wdata    <= `ZeroWord;
        end else if ((rdy == `PauseDisable) && (stall_sign[4] == 1'b0)) begin
            wb_wd       <= mem_wd;
            wb_wreg     <= mem_wreg;
            wb_wdata    <= mem_wdata;
        end
    end

endmodule
