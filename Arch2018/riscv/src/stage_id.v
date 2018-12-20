`include "defines.v"
module stage_id(
    input wire                  rst,
    input wire                  rdy,

    // get the inst and inst addr
    input wire[`InstAddrBus]    pc_i,
    input wire[`InstBus]        inst_i,

    // read data from reg
    input wire [`RegBus]        reg1_data_i,
    input wire [`RegBus]        reg2_data_i,

    // read from ex to solve data hazard
    input wire                  ex_wreg_i,
    input wire[`RegAddrBus]     ex_wd_i,
    input wire[`RegBus]         ex_wdata_i,

    // read from mem to solve data hazard
    input wire                  mem_wreg_i,
    input wire[`RegAddrBus]     mem_wd_i,
    input wire[`RegBus]         mem_wdata_i,

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
    output reg[`RegBus]         ls_offset_o,
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,

    // output to pc_reg for branch and jump
    output reg                  branch_enable_o,
    output reg[`InstAddrBus]    branch_addr_o
);

// get the keys to identify the options
wire [`OpcodeBus]   opcode = inst_i[6:0];
wire [`FunctBus3]   funct3 = inst_i[14:12];
wire [`FunctBus7]   funct7 = inst_i[31:25];

// imm number
reg[`RegBus]    imm;

assign pc_i_plus_4 = pc_i + 4;
assign reg1_eq_reg2 = reg1_o == reg2_o;
assign reg1_lt_reg2 = reg1_o < reg2_o;
assign reg1_lt_reg2_u = {1'b0, reg1_o} < {1'b0, reg2_o};
assign reg1_gt_reg2 = reg1_o > reg2_o;
assign reg1_gt_reg2_u = {1'b0, reg1_o} > {1'b0, reg2_o};

// InstValid bit
reg     inst_valid;

    always @ ( * ) begin
        if (rst == `RstEnable) begin
            opcode_o        <= `NON_OP;
            funct3_o        <= `NON_FUNCT3;
            funct7_o        <= `NON_FUNCT7;
            wd_o            <= `NOPRegAddr;
            wreg_o          <= `WriteDisable;
            inst_valid      <= `InstValid;
            reg1_read_o     <= `False_v;
            reg2_read_o     <= `False_v;
            reg1_addr_o     <= `NOPRegAddr;
            reg2_addr_o     <= `NOPRegAddr;
            imm             <= `ZeroWord;
            branch_enable_o <= 1'b0;
            branch_addr_o   <= `ZeroWord;
        end else if (rdy == `PauseDisable) begin
            opcode_o        <= `NON_OP;
            funct3_o        <= `NON_FUNCT3;
            funct7_o        <= `NON_FUNCT7;
            wd_o            <= inst_i[11:7];
            wreg_o          <= `WriteDisable;
            inst_valid      <= `InstInvalid;
            reg1_read_o     <= `False_v;
            reg2_read_o     <= `False_v;
            reg1_addr_o     <= inst_i[19:15];
            reg2_addr_o     <= inst_i[24:20];
            imm             <= `ZeroWord;
            branch_enable_o <= 1'b0;
            branch_addr_o   <= `ZeroWord;
            case (opcode)
                `OP_IMM_OP: begin
                    wreg_o      <= `WriteEnable;
                    opcode_o    <= `OP_IMM_OP; // to simply the ex
                    reg1_read_o <= `True_v;
                    reg2_read_o <= `False_v;
                    funct7_o    <= `NON_FUNCT7;
                    wd_o        <= inst_i[11:7];
                    inst_valid  <= `InstValid;
                    case (funct3)
                        `ADDI_FUNCT3: begin
                            funct3_o    <= `ADDI_FUNCT3;
                            imm         <= {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `SLTI_FUNCT3: begin
                            opcode_o    <= `OP_OP; // to simply the ex, SLTI == SLT in ex stage
                            funct3_o    <= `SLTI_FUNCT3;
                            imm         <= {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `SLTIU_FUNCT3: begin
                            opcode_o    <= `OP_OP; // to simply the ex
                            funct3_o    <= `SLTIU_FUNCT3;
                            imm         <= {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `XORI_FUNCT3: begin
                            funct3_o    <= `XORI_FUNCT3;
                            imm         <= {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `ORI_FUNCT3: begin
                            funct3_o    <= `ORI_FUNCT3;
                            imm         <= {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `ANDI_FUNCT3: begin
                            funct3_o    <= `ANDI_FUNCT3;
                            imm         <= {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        default: begin
                        end
                    endcase
                end
                `OP_OP: begin
                    wreg_o      <= `WriteEnable;
                    opcode_o    <= `OP_OP;
                    reg1_read_o <= `True_v;
                    reg2_read_o <= `True_v;
                    wd_o        <= inst_i[11:7];
                    inst_valid  <= `InstValid;
                    funct7_o    <= `NON_FUNCT7;
                    funct3_o    <= funct3;
                    funct7_o    <= funct7;
                end
                `JAL_OP: begin
                    branch_enable_o <= 1'b1;
                    branch_addr_o   <= {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0} + pc_i;
                    wreg_o          <= `WriteEnable;
                    opcode_o        <= `JAL_OP;
                    funct3_o        <= `NON_FUNCT3;
                    reg1_read_o     <= `False_v;
                    reg2_read_o     <= `False_v;
                    imm             <= pc_i_plus_4;
                    wd_o            <= inst_i[11:7];
                    inst_valid      <= `InstValid;
                end
                `JALR_OP: begin
                    branch_enable_o <= 1'b1;
                    wreg_o          <= `WriteEnable;
                    opcode_o        <= `JALR_OP;
                    funct3_o        <= `NON_FUNCT3;
                    reg1_read_o     <= `True_v;
                    reg2_read_o     <= `False_v;
                    imm             <= pc_i_plus_4;
                    wd_o            <= inst_i[11:7];
                    inst_valid      <= `InstValid;
                    branch_addr_o   <= {{20{inst_i[31]}}, inst_i[31:20]} + reg1_o;
                end
                `BRANCH_OP: begin
                    wreg_o          <= `WriteDisable;
                    opcode_o        <= `BRANCH_OP;
                    funct3_o        <= funct3;
                    reg1_read_o     <= `True_v;
                    reg2_read_o     <= `True_v;
                    imm             <= `ZeroWord;
                    wd_o            <= `ZeroWord;
                    inst_valid      <= `InstValid;
                    case (funct3)
                        `BEQ_FUNCT3: begin
                            if (reg1_o == reg2_o) begin
                                branch_enable_o <= 1'b1;
                                branch_addr_o   <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
                            end
                        end
                        `BNE_FUNCT3: begin
                            if (reg1_o != reg2_o) begin
                                branch_enable_o <= 1'b1;
                                branch_addr_o   <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
                            end
                        end
                        `BLT_FUNCT3: begin
                            if (reg1_lt_reg2) begin
                                branch_enable_o <= 1'b1;
                                branch_addr_o   <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
                            end
                        end
                        `BLTU_FUNCT3: begin
                            if (reg1_lt_reg2_u) begin
                                branch_enable_o <= 1'b1;
                                branch_addr_o   <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
                            end
                        end
                        `BGE_FUNCT3: begin
                            if (reg1_gt_reg2) begin
                                branch_enable_o <= 1'b1;
                                branch_addr_o   <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
                            end
                        end
                        `BGE_FUNCT3: begin
                            if (reg1_gt_reg2_u) begin
                                branch_enable_o <= 1'b1;
                                branch_addr_o   <= {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
                            end
                        end
                        default: begin
                        end
                    endcase
                end
                `LOAD_OP: begin
                    wreg_o      <= `WriteEnable;
                    opcode_o    <= `LOAD_OP;
                    funct3_o    <= funct3;
                    funct7_o    <= `NON_FUNCT7;
                    ls_offset_o <= {{20{inst_i[31]}}, inst_i[31:20]};
                    reg1_read_o <= `True_v;
                    reg2_read_o <= `False_v;
                    wd_o        <= inst_i[11:7];
                    inst_valid  <= `InstValid;
                end
                `STORE_OP: begin
                    wreg_o      <= `WriteDisable;
                    opcode_o    <= `STORE_OP;
                    funct3_o    <= funct3;
                    funct7_o    <= `NON_FUNCT7;
                    ls_offset_o <= {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                    reg1_read_o <= `True_v;
                    reg2_read_o <= `True_v;
                    wd_o        <= inst_i[11:7];
                    inst_valid  <= `InstValid;
                end
                `LUI_OP: begin
                    wreg_o          <= `WriteEnable;
                    opcode_o        <= `LUI_OP;
                    funct3_o        <= `NON_FUNCT3;
                    reg1_read_o     <= `False_v;
                    reg2_read_o     <= `False_v;
                    imm             <= {inst_i[31:12], 12'b0};
                    wd_o            <= inst_i[11:7];
                    inst_valid      <= `InstValid;
                end
                `AUIPC_OP: begin
                    wreg_o          <= `WriteEnable;
                    opcode_o        <= `AUIPC_OP;
                    funct3_o        <= `NON_FUNCT3;
                    reg1_read_o     <= `False_v;
                    reg2_read_o     <= `False_v;
                    imm             <= {inst_i[31:12], 12'b0} + pc_i;
                    wd_o            <= inst_i[11:7];
                    inst_valid      <= `InstValid;
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
            if ((reg1_read_o == `True_v) && (ex_wreg_i == `True_v) && (ex_wd_i == reg1_addr_o)) begin
                reg1_o <= ex_wdata_i;
            end else if ((reg1_read_o == `True_v) && (mem_wreg_i == `True_v) && (mem_wd_i == reg1_addr_o)) begin
                reg1_o <= mem_wdata_i;
            end else if (reg1_read_o == `True_v) begin
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
            if ((reg2_read_o == `True_v) && (ex_wreg_i == `True_v) && (ex_wd_i == reg2_addr_o)) begin
                reg2_o <= ex_wdata_i;
            end else if ((reg2_read_o == `True_v) && (mem_wreg_i == `True_v) && (mem_wd_i == reg2_addr_o)) begin
                reg2_o <= mem_wdata_i;
            end else if (reg2_read_o == `True_v) begin
                reg2_o <= reg2_data_i;
            end else if (reg2_read_o == `False_v) begin
                reg2_o <= imm;
            end else begin
                reg2_o <= `ZeroWord;
            end
        end
    end

endmodule // id