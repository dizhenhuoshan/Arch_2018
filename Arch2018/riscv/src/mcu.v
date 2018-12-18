`include"defines.v"
module mcu (
    input wire rst,
    input wire rdy,

    input wire write_enable_i,
    input wire stage_mem_busy,

    input wire[`InstAddrBus]    if_mem_addr_i,
    input wire[`InstAddrBus]    mem_mem_addr_i,

    output reg                  write_enable_o,
    output reg[`InstAddrBus]    mem_addr_o
);

    always @ ( * ) begin
        if (rst == `RstEnable) begin
            write_enable_o  <= `False_v;
            mem_addr_o      <= `ZeroWord;
        end else if (rdy == `PauseDisable) begin
            write_enable_o  <= write_enable_i;
            if (stage_mem_busy == `True_v) begin
                mem_addr_o  <= mem_mem_addr_i;
            end else begin
                mem_addr_o  <= if_mem_addr_i;
            end
        end
    end

endmodule // mcu
