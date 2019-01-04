`include"defines.v"
module mcu (
    input wire                  rst,
    input wire                  rdy,

    input wire                  stage_mem_busy,

    input wire                  if_write_enable_i,
    input wire                  mem_write_enable_i,
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
            if (stage_mem_busy == `True_v) begin
                mem_addr_o      <= mem_mem_addr_i;
                write_enable_o  <= mem_write_enable_i;
            end else begin
                mem_addr_o      <= if_mem_addr_i;
                write_enable_o  <= if_write_enable_i;
            end
        end
    end

endmodule // mcu
