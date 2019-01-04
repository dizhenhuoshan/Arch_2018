`include "defines.v"
module stage_if(
    input wire                  clk,
    input wire                  rst,

    // input from ctrl
    input wire[`StallBus]       stall_sign,

    // input from mem_data
    input wire[`MemDataBus]     mem_data_i,

    // input for branch
    input wire                  branch_enable_i,
    input wire[`InstAddrBus]    branch_addr_i,

    output reg[`InstAddrBus]    mem_addr_o,
    output reg                  mem_we_o,
    // for branch ctrl
    output reg                  if_mem_req_o,
    output reg 					branch_stall_req_o,
    // pass universal info
    output reg[`InstAddrBus]    pc_o,
    output reg[`InstBus]        inst_o
);

reg[`MemDataBus]    inst_block1;
reg[`MemDataBus]    inst_block2;
reg[`MemDataBus]    inst_block3;
reg[3:0]            cnt;

// Warning: If stage mem interupte if in the mem_data fetch, then you
// need resent pc in order to get the right data;

always @ (posedge clk) begin
    if (rst) begin
        pc_o                <= `ZeroWord;
        cnt                 <= 4'b0000;
        inst_block1         <= 8'h00;
        inst_block2         <= 8'h00;
        inst_block3         <= 8'h00;
        mem_addr_o          <= `ZeroWord;
        mem_we_o            <= `False_v;
        branch_stall_req_o  <= `False_v;
        if_mem_req_o        <= `False_v;
        pc_o                <= `ZeroWord;
        inst_o              <= `ZeroWord;
    end else if(branch_enable_i && !stall_sign[2]) begin
		pc_o                <= branch_addr_i;
		cnt                 <= 4'b0000;
        inst_o              <= `ZeroWord;
        mem_addr_o          <= `ZeroWord;
		if_mem_req_o        <= `False_v;
		branch_stall_req_o	<= `False_v;
    end else begin
        case (cnt)
            4'b0000: begin
                if (!stall_sign[2] && !stall_sign[3]) begin
                    if_mem_req_o        <= `True_v;
                    mem_addr_o          <= pc_o;
                    cnt                 <= 4'b0001;
                end
            end
            4'b0001: begin
                mem_addr_o      <= pc_o + 1;
                cnt             <= 4'b0010;
            end
            4'b0010: begin
                mem_addr_o      <= pc_o + 2;
                inst_block1     <= mem_data_i;
                cnt             <= 4'b0011;
            end
            4'b0011: begin
                if (stall_sign[1]) begin // last inst is in mem stage.
                    cnt             <= 4'b1010; // to resent the addr.
                end else begin
                    mem_addr_o      <= pc_o + 3;
                    inst_block2     <= mem_data_i;
                    cnt             <= 4'b0100;
                end
            end
            4'b0100: begin
                if (stall_sign[1]) begin
                    cnt             <= 4'b1100;
                end else begin
                    inst_block3     <= mem_data_i;
                    cnt             <= 4'b0101;
                end
            end
            4'b0101: begin
                inst_o          <= {mem_data_i, inst_block3, inst_block2, inst_block1};
                if_mem_req_o    <= `False_v;
                cnt             <= 4'b0000;
                if (inst_block1[6]) begin
                    branch_stall_req_o   <= `True_v;
                end else begin
                    branch_stall_req_o   <= `False_v;
                    pc_o                 <= pc_o + 4;
                end
            end
            // For the interuption from stage_mem;
            4'b1010: begin
                if (!stall_sign[1]) begin
                    mem_addr_o      <= pc_o + 1;
                    cnt             <= 4'b1011;
                end
            end
            4'b1011: begin
                mem_addr_o      <= pc_o + 2;
                cnt             <= 4'b0011; // pc + 1 data is ready
            end
            4'b1100: begin
                if (!stall_sign[1]) begin
                    mem_addr_o      <= pc_o + 2;
                    cnt             <= 4'b1101;
                end
            end
            4'b1101: begin
                mem_addr_o      <= pc_o + 3;
                cnt             <= 4'b0100; // pc + 2 data is ready
            end
            default: begin
            end
        endcase
    end
end

endmodule // if
