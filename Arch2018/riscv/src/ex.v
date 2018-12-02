`include "defines.v"
module ex(
    input wire                  rst,
    input wire                  rdy,

    // read from id_ex
    input wire[`OpcodeBus]      opcode_i,
    input wire[`FunctBus3]      funct3_i,
    input wire[`FunctBus7]      funct7_i,
    input wire[`RegBus]         reg1_i,
    input wire[`RegBus]         reg2_i,
    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,

    // output the result of ex
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,
    output reg[`RegBus]         wdata_o
);

    reg[`RegBus]        op_imm_res;
    reg[`RegBus]        other_res;

    always @ ( * ) begin
        if (rst == `RstEnable) begin
            op_imm_res <= `ZeroWord;
        end else if (rdy == `PauseDisable) begin
            case (funct3_i)
                `ADDI_FUNCT3: begin
                    op_imm_res <= reg1_i + reg2_i;
                end
                default: begin
                    op_imm_res <= `ZeroWord;
                end
            endcase
        end
    end

    always @ ( * ) begin
        if (rst == `RstEnable) begin
            other_res <= `ZeroWord;
        end else if (rdy == `PauseDisable) begin
            case (opcode_i)
                `LUI_OP: begin
                    other_res <= reg1_i;
                end
                default: begin
                end
            endcase
        end
    end

    always @ ( * ) begin
        if (rdy == `PauseDisable) begin
            wd_o    <= wd_i;
            wreg_o  <= wreg_i;
            case (opcode_i)
                `OP_IMM_OP: begin
                    wdata_o <= op_imm_res;
                end
                `LUI_OP: begin
                    wdata_o <= other_res;
                end
                default: begin
                    wdata_o <= `ZeroWord;
                end
            endcase
        end
    end

endmodule // ex
