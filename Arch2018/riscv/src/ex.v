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
    reg[`RegBus]        op_op_res;

    wire                reg1_eq_reg2; // if reg1 == reg2, thisi is 1'b1;
    wire                reg1_lt_reg2; // if reg1 < reg2, this is 1'b1;
    wire[`RegBus]       reg2_i_mux;   // reg2's two's complement representation;
    wire[`RegBus]       result_sum;   // reg1 + reg2;

    assign reg1_eq_reg2 = reg1_i == reg2_i;
    assign reg2_i_mux = ((funct7_i == `SUB_FUNCT7) ||
                        (funct3_i ==  `SLT_FUNCT3))? (~reg2_i) + 1 : reg2_i;
    assign result_sum = reg1_i + reg2_i_mux;
    assign reg1_lt_reg2 = (funct3_i == `SLT_FUNCT3)? ((reg1_i[31] & !reg2_i[31])
                        || (!reg1_i[31] && !reg2_i[31] && result_sum[31])
                        || (reg1_i[31] && reg2_i[31] && result_sum[31])):
                        (reg1_i < reg2_i);


    // for OP_IMM
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

    // for OP_OP
    always @ ( * ) begin
        if (rst == `RstEnable) begin
            op_op_res <= `ZeroWord;
        end else if (rdy == `PauseDisable) begin
            case (funct3_i)
                `ADD_SUB_FUNCT3: begin
                    op_op_res <= result_sum;
                end
                `SLT_FUNCT3, `SLTU_FUNCT3: begin
                    op_op_res <= reg1_lt_reg2;
                end
                default: begin
                    op_imm_res <= `ZeroWord;
                end
            endcase
        end
    end

    // final mux
    always @ ( * ) begin
        if (rdy == `PauseDisable) begin
            wd_o    <= wd_i;
            wreg_o  <= wreg_i;
            case (opcode_i)
                `OP_IMM_OP: begin
                    wdata_o <= op_imm_res;
                end
                `OP_OP: begin
                    wdata_o <= op_op_res;
                end
                `LUI_OP: begin
                    wdata_o <= reg1_i;
                end
                `AUIPC_OP: begin
                    wdata_o <= reg1_i;
                end
                `JAL_OP: begin
                    wdata_o <= reg1_i;
                end
                `JALR_OP: begin
                    wdata_o <= reg1_i;
                end
                default: begin
                    wdata_o <= `ZeroWord;
                end
            endcase
        end
    end

endmodule // ex
