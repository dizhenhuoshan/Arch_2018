`include"defines.v"
module mem_wb(
    input wire                  clk,
    input wire                  rst,

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
        if (rst) begin
            wb_wd       <= `NOPRegAddr;
            wb_wreg     <= `WriteDisable;
            wb_wdata    <= `ZeroWord;
        end else if (stall_sign[5] && !stall_sign[6]) begin
            wb_wd       <= `NOPRegAddr;
            wb_wreg     <= `WriteDisable;
            wb_wdata    <= `ZeroWord;
        end else if (!stall_sign[5]) begin
            wb_wd       <= mem_wd;
            wb_wreg     <= mem_wreg;
            wb_wdata    <= mem_wdata;
        end
    end

endmodule
