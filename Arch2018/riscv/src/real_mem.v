`include "defines.v"
module real_mem(
    input wire clk,
    input wire write_enable_i,

    input wire[`InstAddrBus] mem_addr_i,
    input wire[`MemDataBus]  mem_data_i,
    output wire[`MemDataBus] mem_data_o
);

single_port_ram_sync #(.ADDR_WIDTH(17), .DATA_WIDTH(8)) ram0
(
    .clk(clk),
    .we(write_enable_i),
    .addr_a(mem_addr_i[16:0]),
    .din_a(mem_data_i),
    .dout_a(mem_data_o)
);

endmodule // real_mem
