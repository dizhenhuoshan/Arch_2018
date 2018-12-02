`include "defines.v"
module id_ex(
    input wire                  clk,
    input wire                  rst,
    input wire                  rdy,

    // read from id
    input wire[`OpcodeBus]      id_opcode,
    input wire[`FunctBus3]      id_funct3,
    input wire[`FunctBus7]      id_funct7,
    input wire[`RegBus]         id_reg1,
    input wire[`RegBus]         id_reg2,
    input wire[`RegAddrBus]     id_wd,
    input wire                  id_wreg,

    // send to ex
    output reg[`OpcodeBus]      ex_opcode,
    output reg[`FunctBus3]      ex_funct3,
    output reg[`FunctBus7]      ex_funct7,
    output reg[`RegBus]         ex_reg1,
    output reg[`RegBus]         ex_reg2,
    output reg[`RegAddrBus]     ex_wd,
    output reg                  ex_wreg
);

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ex_opcode   <= `NON_OP;
            ex_funct3   <= `NON_FUNCT3;
            ex_funct7   <= `NON_FUNCT7;
            ex_reg1     <= `ZeroWord;
            ex_reg2     <= `ZeroWord;
            ex_wd       <= `NOPRegAddr;
            ex_wreg     <= `WriteDisable;
        end else if (rdy == `PauseDisable) begin
            ex_opcode   <= id_opcode;
            ex_funct3   <= id_funct3;
            ex_funct7   <= id_funct7;
            ex_reg1     <= id_reg1;
            ex_reg2     <= id_reg2;
            ex_wd       <= id_wd;
            ex_wreg     <= id_wreg;
        end
    end

endmodule // id_ex
