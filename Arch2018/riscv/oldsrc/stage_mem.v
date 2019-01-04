`include"defines.v"
module stage_mem(

    input wire                  rst,
    input wire                  rdy,

    // read from ex
    input wire[`OpcodeBus]      opcode_i,
    input wire[`FunctBus3]      funct3_i,
    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,
    input wire[`RegBus]         wdata_i,
    input wire[`InstAddrBus]    mem_addr_i,
    input wire[`CntBus8]        mem_cnt_i,

    // load mem data
    input wire[`MemDataBus]     mem_data_i,
    // pass the result
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o,
    output reg[`RegBus]         wdata_o,

    // mem ctrl
    output reg                  mem_stall_req_o,
    output reg                  stage_mem_busy_o,
    output reg[`CntBus8]        mem_cnt_o,
    output reg                  mem_we_o,

    output reg[`InstAddrBus]    mem_addr_o,
    output reg[`MemDataBus]     mem_data_o
);

reg[`MemDataBus]    data_block1;
reg[`MemDataBus]    data_block2;
reg[`MemDataBus]    data_block3;

    always @ ( * ) begin
        if (rst) begin
            wd_o                <= `NOPRegAddr;
            wreg_o              <= `WriteDisable;
            wdata_o             <= `ZeroWord;
            stage_mem_busy_o    <= `False_v;
            mem_stall_req_o     <= `False_v;
            mem_cnt_o           <= 4'b0000;
            mem_we_o            <= `WriteDisable;
            mem_data_o          <= 8'b00;
        end else if (rdy == `PauseDisable) begin
            case (opcode_i)
                `LOAD_OP: begin
                    case (funct3_i)
                        `LB_FUNCT3, `LBU_FUNCT3: begin
                            case (mem_cnt_i)
                                4'b0000: begin
                                    wdata_o             <= `ZeroWord;
                                    wd_o                <= `NOPRegAddr;
                                    wreg_o              <= `WriteDisable;
                                    mem_stall_req_o     <= `True_v;
                                    stage_mem_busy_o    <= `True_v;
                                    mem_addr_o          <= mem_addr_i;
                                    mem_cnt_o           <= 4'b0001;
                                end
                                4'b0001: begin
                                    wreg_o              <= `WriteEnable;
                                    wd_o                <= wd_i;
                                    mem_addr_o          <= mem_addr_i;
                                    if (funct3_i == `LB_FUNCT3) begin
                                        wdata_o         <= {{24{mem_data_i[7]}}, mem_data_i};
                                    end else begin
                                        wdata_o         <=  {24'h000000, mem_data_i};
                                    end
                                    mem_stall_req_o     <= `False_v;
                                    stage_mem_busy_o    <= `False_v;
                                    mem_cnt_o           <= 4'b1000;

                                end
                                default: begin
                                end
                            endcase
                        end
                        `LH_FUNCT3, `LHU_FUNCT3: begin
                            case (mem_cnt_i)
                                4'b0000: begin
                                    wdata_o             <= `ZeroWord;
                                    wd_o                <= `NOPRegAddr;
                                    wreg_o              <= `WriteDisable;
                                    mem_stall_req_o     <= `True_v;
                                    stage_mem_busy_o    <= `True_v;
                                    data_block1         <= 8'h00;
                                    mem_addr_o          <= mem_addr_i;
                                    mem_cnt_o           <= 4'b0001;
                                end
                                4'b0001: begin
                                    data_block1     <= mem_data_i;
                                    mem_cnt_o       <= 4'b0010;
                                end
                                4'b0010: begin
                                    mem_addr_o      <= mem_addr_i + 1;
                                    mem_cnt_o       <= 4'b0011;
                                end
                                4'b0011: begin
                                    wreg_o              <= `WriteEnable;
                                    wd_o                <= wd_i;
                                    mem_addr_o          <= mem_addr_i + 1;
                                    if (funct3_i == `LH_FUNCT3) begin
                                        wdata_o             <= {{16{mem_data_i[7]}}, mem_data_i, data_block1};
                                    end else begin
                                        wdata_o             <= {16'h0000, mem_data_i, data_block1};
                                    end
                                    mem_stall_req_o     <= `False_v;
                                    stage_mem_busy_o    <= `False_v;
                                    mem_cnt_o           <= 4'b1000;
                                end
                                default: begin
                                end
                            endcase
                        end
                        `LW_FUNCT3: begin
                            case (mem_cnt_i)
                                4'b0000: begin
                                    wdata_o             <= `ZeroWord;
                                    wd_o                <= `NOPRegAddr;
                                    wreg_o              <= `WriteDisable;
                                    mem_stall_req_o     <= `True_v;
                                    stage_mem_busy_o    <= `True_v;
                                    data_block1         <= 8'h00;
                                    data_block2         <= 8'h00;
                                    data_block3         <= 8'h00;
                                    mem_addr_o          <= mem_addr_i;
                                    mem_cnt_o           <= 4'b0001;
                                end
                                4'b0001: begin
                                    data_block1     <= mem_data_i;
                                    mem_cnt_o       <= 4'b0010;
                                end
                                4'b0010: begin
                                    mem_addr_o      <= mem_addr_i + 1;
                                    mem_cnt_o       <= 4'b0011;
                                end
                                4'b0011: begin
                                    data_block2     <= mem_data_i;
                                    mem_cnt_o       <= 4'b0100;
                                end
                                4'b0100: begin
                                    mem_addr_o      <= mem_addr_i + 2;
                                    mem_cnt_o       <= 4'b0101;
                                end
                                4'b0101: begin
                                    data_block3     <= mem_data_i;
                                    mem_cnt_o       <= 4'b0110;
                                end
                                4'b0110: begin
                                    mem_addr_o      <= mem_addr_i + 3;
                                    mem_cnt_o       <= 4'b0111;
                                end
                                4'b0111: begin
                                    wreg_o              <= `WriteEnable;
                                    wd_o                <= wd_i;
                                    mem_addr_o          <= mem_addr_i + 3;
                                    wdata_o             <= {mem_data_i, data_block3, data_block2, data_block1};
                                    mem_stall_req_o     <= `False_v;
                                    stage_mem_busy_o    <= `False_v;
                                    mem_cnt_o           <= 4'b1000;
                                end
                                default: begin
                                end
                            endcase
                        end
                        default: begin
                        end
                    endcase
                end
                `STORE_OP: begin
                    case (funct3_i)
                        `SW_FUNCT3: begin
                            case (mem_cnt_i)
                                4'b0000: begin
                                    wdata_o             <= `ZeroWord;
                                    wd_o                <= `NOPRegAddr;
                                    wreg_o              <= `WriteDisable;
                                    mem_we_o            <= `WriteEnable;
                                    mem_stall_req_o     <= `True_v;
                                    stage_mem_busy_o    <= `True_v;
                                    mem_addr_o          <= mem_addr_i;
                                    mem_data_o          <= wdata_i[7:0];
                                    mem_cnt_o           <= 4'b0001;
                                end
                                4'b0001: begin
                                    mem_cnt_o       <= 4'b0010;
                                end
                                4'b0010: begin
                                    mem_addr_o      <= mem_addr_i + 1;
                                    mem_data_o      <= wdata_i[15:8];
                                    mem_cnt_o       <= 4'b0011;
                                end
                                4'b0011: begin
                                    mem_cnt_o       <= 4'b0100;
                                end
                                4'b0100: begin
                                    mem_addr_o      <= mem_addr_i + 2;
                                    mem_data_o      <= wdata_i[23:16];
                                    mem_cnt_o       <= 4'b0101;
                                end
                                4'b0101: begin
                                    mem_cnt_o       <= 4'b0110;
                                end
                                4'b0110: begin
                                    mem_addr_o      <= mem_addr_i + 3;
                                    mem_data_o      <= wdata_i[31:24];
                                    mem_cnt_o       <= 4'b0111;
                                end
                                4'b0111: begin
                                    mem_we_o            <= `WriteDisable;
                                    mem_stall_req_o     <= `False_v;
                                    stage_mem_busy_o    <= `False_v;
                                    mem_cnt_o           <= 4'b1000;
                                end
                                default: begin
                                end
                            endcase
                        end
                        `SH_FUNCT3: begin
                            case (mem_cnt_i)
                                4'b0000: begin
                                    wdata_o             <= `ZeroWord;
                                    wd_o                <= `NOPRegAddr;
                                    wreg_o              <= `WriteDisable;
                                    mem_we_o            <= `WriteEnable;
                                    mem_stall_req_o     <= `True_v;
                                    stage_mem_busy_o    <= `True_v;
                                    mem_addr_o          <= mem_addr_i;
                                    mem_data_o          <= wdata_i[7:0];
                                    mem_cnt_o           <= 4'b0001;
                                end
                                4'b0001: begin
                                    mem_cnt_o       <= 4'b0010;
                                end
                                4'b0010: begin
                                    mem_addr_o      <= mem_addr_i + 1;
                                    mem_data_o      <= wdata_i[15:8];
                                    mem_cnt_o       <= 4'b0011;
                                end
                                4'b0011: begin
                                    mem_we_o            <= `WriteDisable;
                                    mem_stall_req_o     <= `False_v;
                                    stage_mem_busy_o    <= `False_v;
                                    mem_cnt_o           <= 4'b1000;
                                end
                                default: begin
                                end
                            endcase
                        end
                        `SB_FUNCT3: begin
                            case (mem_cnt_i)
                                4'b0000: begin
                                    wdata_o             <= `ZeroWord;
                                    wd_o                <= `NOPRegAddr;
                                    wreg_o              <= `WriteDisable;
                                    mem_we_o            <= `WriteEnable;
                                    mem_stall_req_o     <= `True_v;
                                    stage_mem_busy_o    <= `True_v;
                                    mem_addr_o          <= mem_addr_i;
                                    mem_data_o          <= wdata_i[7:0];
                                    mem_cnt_o           <= 4'b0001;
                                end
                                4'b0001: begin
                                    mem_we_o            <= `WriteDisable;
                                    mem_stall_req_o     <= `False_v;
                                    stage_mem_busy_o    <= `False_v;
                                    mem_cnt_o           <= 4'b1000;
                                end
                                default: begin
                                end
                            endcase
                        end
                        default: begin
                        end
                    endcase
                end
                default: begin
                    wd_o    <= wd_i;
                    wreg_o  <= wreg_i;
                    wdata_o <= wdata_i;
                end
            endcase
        end
    end

endmodule
