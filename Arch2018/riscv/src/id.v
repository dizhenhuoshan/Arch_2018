`include "defines.v"
module id(
    input wire                  rst,
    input wire                  rdy,

    // get the inst and inst addr
    input wire[`InstAddrBus]    pc_i,
    input wire[`InstBus]        inst_i,

    // read data from reg
    input wire [`RegBus]        reg1_data_i,
    input wire [`RegBus]        reg2_data_i,

    // read from ex to solve data hazard
    // TODO

    // read from mem to solve data hazard
    // TODO

    // output to the reg file
    output reg                  reg1_read_o,
    output reg                  reg2_read_o,
    output reg[`RegAddrBus]     reg1_addr_o,
    output reg[`RegAddrBus]     reg2_addr_o,

    //output to id_ex
    output reg[`OpcodeBus]      opcode_o,
    output reg[`FunctBus3]      funct3_o,
    output reg[`FunctBus7]      funct7_o,
    output reg[`RegBus]         reg1_o,
    output reg[`RegBus]         reg2_o,
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o
);

// get the keys to identify the options
wire [`OpcodeBus]   opcode = inst_i[6:0];
wire [`FunctBus3]   funct3 = inst_i[14:12];
wire [`FunctBus7]   funct7 = inst_i[31:25];

// imm number
reg[`RegBus]    imm;

// InstValid bit
reg     inst_valid;

    always @ ( * ) begin
        if (rst == `RstEnable) begin
            opcode_o    <= `NON_OP;
            funct3_o    <= `NON_FUNCT3;
            funct7_o    <= `NON_FUNCT7;
            wd_o        <= `NOPRegAddr;
            wreg_o      <= `WriteDisable;
            inst_valid  <= `InstValid;
            reg1_read_o <= `False_v;
            reg2_read_o <= `False_v;
            reg1_addr_o <= `NOPRegAddr;
            reg2_addr_o <= `NOPRegAddr;
            imm         <= `ZeroWord;
        end else if (rdy == `PauseDisable) begin
            opcode_o    <= `NON_OP;
            funct3_o    <= `NON_FUNCT3;
            funct7_o    <= `NON_FUNCT7;
            wd_o        <= inst_i[11:7];
            wreg_o      <= `WriteDisable;
            inst_valid  <= `InstInvalid;
            reg1_read_o <= `False_v;
            reg2_read_o <= `False_v;
            reg1_addr_o <= inst_i[19:15];
            reg2_addr_o <= inst_i[24:20];
            imm         <= `ZeroWord;
            case (opcode)
                `OP_IMM_OP: begin
                    case (funct3)
                        `ADDI_FUNCT3: begin
                            wreg_o      <= `WriteEnable;
                            opcode_o    <= `OP_IMM_OP;
                            funct3_o    <= `ADDI_FUNCT3;
                            reg1_read_o <= `True_v;
                            reg2_read_o <= `False_v;
                            imm         <= {{20{inst_i[11]}}, inst_i[31:20]};
                            wd_o        <= inst_i[11:7];
                            inst_valid   <= `InstValid;
                        end
                        default: begin
                        end
                    endcase
                end
                `LUI_OP: begin
                    wreg_o      <= `WriteEnable;
                    opcode_o    <= `LUI_OP;
                    funct3_o    <= `NON_FUNCT3;
                    reg1_read_o <= `False_v;
                    reg2_read_o <= `False_v;
                    imm         <= {inst_i[31:12], 11'b0};
                    wd_o        <= inst_i[11:7];
                    inst_valid   <= `InstValid;
                end
                default: begin
                end
            endcase
        end
    end

    always @ ( * ) begin
        if (rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end else if (rdy == `PauseDisable) begin
            if (reg1_read_o == `True_v) begin
                reg1_o <= reg1_data_i;
            end else if (reg1_read_o == `False_v) begin
                reg1_o <= imm;
            end else begin
                reg1_o <= `ZeroWord;
            end
        end
    end

    always @ ( * ) begin
        if (rst == `RstEnable) begin
            reg2_o <= `ZeroWord;
        end else if (rdy == `PauseDisable) begin
            if (reg2_read_o == `True_v) begin
                reg2_o <= reg2_data_i;
            end else if (reg2_read_o == `False_v) begin
                reg2_o <= imm;
            end else begin
                reg2_o <= `ZeroWord;
            end
        end
    end

endmodule // id
