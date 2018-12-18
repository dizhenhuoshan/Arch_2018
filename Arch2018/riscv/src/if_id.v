`include "defines.v"
// only need to pass instaddr and inst from if to id
module if_id(
    input wire                  clk,
    input wire                  rst,
    input wire                  rdy,

    // from ctrl
    input wire[`StallBus]       stall_sign,
    // from if
    input wire[`InstAddrBus]    if_pc,
    input wire[`InstBus]        if_inst,
    input wire[`CntBus8]        if_cnt_i,

    // to if
    output reg[`CntBus8]        if_cnt_o,

    // to id
    output reg[`InstAddrBus]    id_pc,
    output reg[`InstBus]        id_inst
);

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc   <= `ZeroWord;
            id_inst <= `ZeroWord;
            if_cnt_o  <= 4'b0000;
        end else if ((rdy == `PauseDisable) && (stall_sign[1] == 1'b1) && (stall_sign[2] == 1'b0))  begin
            id_pc   <= `ZeroWord;
            id_inst <= `ZeroWord;
            if_cnt_o  <= if_cnt_i;
        end else if ((rdy == `PauseDisable) && (stall_sign[1] == 1'b0)) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
            if_cnt_o  <= 4'b0000;
        end
    end

endmodule // if_id
