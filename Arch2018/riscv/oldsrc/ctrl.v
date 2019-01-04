`include "defines.v"
module ctrl (
    input wire                  rst,
    input wire                  rdy,

    input wire                  if_stall_req_i,
    input wire                  mem_stall_req_i,
    output reg[`StallBus]       stall_sign
);

always @ ( * ) begin
    if (rst == `RstEnable) begin
        stall_sign <= 6'b000000;
    end else if (rdy == `PauseDisable) begin
        if (mem_stall_req_i == 1'b1) begin
            stall_sign <= 6'b011111;
        end else if (if_stall_req_i == 1'b1) begin
            stall_sign <= 6'b000011;
        end else begin
            stall_sign <= 6'b000000;
        end
    end
end

endmodule // ctrl
