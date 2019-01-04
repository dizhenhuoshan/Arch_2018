`include "defines.v"
module icache(
    input wire              clk,
    input wire              rst,
    input wire              rdy,

    // write port
    input wire              pc_i,

    output reg              hit_o,
    output reg              inst_o
);

endmodule // cache
