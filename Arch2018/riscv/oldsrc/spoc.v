`include "defines.v"
module spoc(
    input wire          clk,
    input wire          rst,
    input wire          rdy,

    output wire[31:0]   debug
);

wire[`MemDataBus]   mem_data_i;
wire[`MemDataBus]   mem_data_o;
wire[`InstAddrBus]  mem_addr;
wire                mem_we;

cpu cpu0(
    .clk_in(clk),
    .rst_in(rst),
    .rdy_in(rdy),
    .mem_din(mem_data_o),
    .mem_dout(mem_data_i),
    .mem_a(mem_addr),
    .mem_wr(mem_we),
    .dbgreg_dout(debug)
);

real_mem real_mem0(
    .clk(clk),
    .write_enable_i(mem_we),
    .mem_addr_i(mem_addr),
    .mem_data_i(mem_data_i),
    .mem_data_o(mem_data_o)
);

endmodule // spoc
