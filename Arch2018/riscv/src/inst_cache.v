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

reg [31:0]                  cache_data[`BlockNum - 1:0];
reg [12:0]                  cache_vtag[`BlockNum - 1:0];

wire        rvalid;
wire [11:0] rtag_i;
wire [5:0]  rindex_i;
wire [11:0] wtag_i;
wire [5:0]  windex_i;
wire [11:0] rtag_c;
wire [31:0] rinst_c;

assign rtag_i    = rpc_i[17:6];
assign rindex_i  = rpc_i[5:0];

assign wtag_i    = wpc_i[17:6];
assign windex_i  = wpc_i[5:0];

assign {rvalid, rtag_c}     = cache_vtag[rindex_i];
assign rinst_c              = cache_data[rindex_i];

always @ (posedge clk) begin
    if (we_i) begin
        cache_vtag[windex_i] <= {1'b1, wpc_i[17:6]};
        cache_data[windex_i] <= winst_i;
    end
end

always @ ( * ) begin
    if (rst || !rdy) begin
        hit_o           <= `False_v;
        inst_o          <= `ZeroWord;
    end else begin
        if ((rindex_i == windex_i) && we_i) begin
            hit_o       <= `True_v;
            inst_o      <= winst_i;
        end else if ((rtag_i == rtag_c) && rvalid) begin
            hit_o       <= `True_v;
            inst_o      <= rinst_c;
        end else begin
            hit_o       <= `False_v;
            inst_o      <= `ZeroWord;
        end
    end
end

endmodule // cache
