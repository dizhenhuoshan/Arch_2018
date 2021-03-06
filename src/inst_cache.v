`include "defines.v"
module icache(
    input wire                  clk,
    input wire                  rst,
    input wire                  rdy,

    // write port
    input wire                  we_i,
    input wire[`InstAddrBus]    wpc_i,
    input wire[`InstBus]        winst_i,

    input wire[`InstAddrBus]    rpc_i,

    // output port
    output reg                  hit_o,
    output reg[`InstBus]        inst_o
);

(* ram_style = "registers" *) reg [31:0]    cache_data[`BlockNum - 1:0];
(* ram_style = "registers" *) reg [9:0]    cache_tag[`BlockNum - 1:0];
(* ram_style = "registers" *) reg           cache_valid[`BlockNum - 1:0];
wire            rvalid;
wire [9:0]      rtag_i;
wire [6:0]      rindex_i;
wire [9:0]      wtag_i;
wire [6:0]      windex_i;
wire [9:0]      rtag_c;
wire [31:0]     rinst_c;

assign rtag_i    = rpc_i[16:7];
assign rindex_i  = rpc_i[6:0];

assign wtag_i    = wpc_i[16:7];
assign windex_i  = wpc_i[6:0];

assign rvalid    = cache_valid[rindex_i];
assign rtag_c    = cache_tag[rindex_i];
assign rinst_c   = cache_data[rindex_i];

integer i;
always @ (posedge clk) begin
    if (rst)begin
        for (i = 0; i < `BlockNum; i = i + 1)
            cache_valid[i]   <= 1'b0;
    end else if (we_i) begin
        cache_valid[windex_i]   <= 1'b1;
        cache_tag[windex_i]     <= wpc_i[16:7];
        cache_data[windex_i]    <= winst_i;
    end
end


always @ ( * ) begin
    if (rst || !rdy) begin
        hit_o           <= `False_v;
        inst_o          <= `ZeroWord;
    end else begin
        if (!(rindex_i ^ windex_i) && we_i) begin
            hit_o       <= `True_v;
            inst_o      <= winst_i;
        end else if (!(rtag_i ^ rtag_c) && rvalid) begin
            hit_o       <= `True_v;
            inst_o      <= rinst_c;
        end else begin
            hit_o       <= `False_v;
            inst_o      <= `ZeroWord;
        end
    end
end

endmodule // cache
