`include "defines.v"

module stage_if(
    input wire                  rst,
    input wire                  rdy,

    // input from pc_reg
    input wire[`InstAddrBus]    pc_i,
    // input from ctrl
    input wire[`StallBus]       stall_sign,
    // for mem ctrl clk
    input wire[`CntBus8]        if_cnt_i,
    // input from mem_data
    input wire[`MemDataBus]     mem_data_i,
    output reg[`InstAddrBus]    mem_addr_o,
    output reg                  mem_we_o,
    // for branch ctrl
    output reg                  branch_sign_o,

    output reg                  if_stall_req_o,
    // pass universal info
    output reg[`InstAddrBus]    pc_o,
    output reg[`InstBus]        inst_o,
    output reg[`CntBus8]        if_cnt_o
);

reg[`MemDataBus]   inst_block1;
reg[`MemDataBus]   inst_block2;
reg[`MemDataBus]   inst_block3;


    always @ ( * ) begin
        if (rst == `RstEnable) begin
            inst_o          <= `ZeroWord;
            if_cnt_o        <= 4'b0000;
            branch_sign_o   <= `False_v;
            mem_we_o        <= `WriteDisable;
            inst_block1     <= 8'h00;
            inst_block2     <= 8'h00;
            inst_block3     <= 8'h00;
            if_stall_req_o  <= `True_v;
        end else if (rdy == `PauseDisable) begin
            if_cnt_o        <= 4'b0000;
            branch_sign_o   <= `False_v;
            mem_we_o        <= `WriteDisable;
            pc_o            <= pc_i;
            case (if_cnt_i)
                4'b0000: begin
                    inst_o          <= `ZeroWord;
                    if_stall_req_o  <= `True_v;
                    mem_addr_o      <= pc_i;
                    inst_block1     <= 8'h00;
                    inst_block2     <= 8'h00;
                    inst_block3     <= 8'h00;
                    if_cnt_o        <= 4'b0001;
                end
                4'b0001: begin
                    inst_block1     <= mem_data_i;
                    if_cnt_o        <= 4'b0010;
                end
                4'b0010: begin
                    mem_addr_o      <= pc_i + 1;
                    if_cnt_o        <= 4'b0011;
                end
                4'b0011: begin
                    inst_block2     <= mem_data_i;
                    if_cnt_o        <= 4'b0100;
                end
                4'b0100: begin
                    mem_addr_o      <= pc_i + 2;
                    if_cnt_o        <= 4'b0101;
                end
                4'b0101: begin
                    inst_block3     <= mem_data_i;
                    if_cnt_o        <= 4'b0110;
                end
                4'b0110: begin
                    mem_addr_o      <= pc_i + 3;
                    if_cnt_o        <= 4'b0111;
                end
                4'b0111: begin
                    inst_o          <= {mem_data_i, inst_block3, inst_block2, inst_block1};
                    if ((inst_block1[6:0] == `BRANCH_OP) || (inst_block1[6:0] == `JAL_OP) || (inst_block1[6:0] == `JALR_OP)) begin
                        if_stall_req_o      <= `True_v;
                        branch_sign_o       <= `True_v;
                        if_cnt_o            <= 4'b1000;
                    end else begin
                        if_stall_req_o      <= `False_v;
                        if_cnt_o       <= 4'b1001;
                    end
                end
                4'b1000: begin
                    branch_sign_o   <= `False_v;
                    if_stall_req_o      <= `False_v;
                    if_cnt_o        <= 4'b1001;
                end
                default: begin
                end
            endcase
        end
    end

endmodule // if
