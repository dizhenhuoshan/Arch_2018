`include "defines.v"
module fakemem(
    input wire                  rst,
    input wire                  rdy,
    input wire[`InstAddrBus]    addr,
    output reg[`InstBus]        inst
);

reg[`InstBus]   inst_mem[0:63];

initial $readmemh("/home/wymt/code/system2018/Arch2018/riscv/test.data", inst_mem);

always @ ( * ) begin
    if (rst == `RstEnable) begin
        inst <= `ZeroWord;
    end else if (rdy == `PauseDisable) begin
        inst[7:0]   <= inst_mem[addr[7:2]][31:24];
        inst[15:8]  <= inst_mem[addr[7:2]][23:16];
        inst[23:16] <= inst_mem[addr[7:2]][15:8];
        inst[31:24] <= inst_mem[addr[7:2]][7:0];
    end
end

endmodule // fakemem
