//Defines of Instructions

// For control
`define RstEnable           1'b1
`define RstDisable          1'b0
`define PauseEnable         1'b0
`define PauseDisable        1'b1
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define WriteEnable         1'b1
`define WriteDisable        1'b0
`define InstValid           1'b1
`define InstInvalid         1'b0
`define ChipEnable          1'b1
`define ChipDisable         1'b0
`define True_v              1'b1
`define False_v             1'b0

// For InterFace
`define RegAddrBus          4:0
`define RegBus              31:0
`define InstAddrBus         31:0
`define InstBus             31:0
`define OpcodeBus           6:0
`define FunctBus3           2:0
`define FunctBus7           6:0


// For Inst opcode
`define NON_OP              7'b0000000 // Nothing
`define OP_IMM_OP           7'b0010011 // ADDI SLTI SLTIU XORI ORI ANDI
`define OP_OP               7'b0110011 // ADD SUB SLL SLT SLTU XOR SRL SRA OR AND
`define LUI_OP              7'b0110111 // LUI
`define AUIPC_OP            7'b0010111 // AUIPC
`define JAL_OP              7'b1101111 // JAL
`define JALR_OP             7'b1100111 // JALR
`define BRANCH_OP           7'b1100011 // BEQ BNE BLT BGE BLTU BGEU
`define LOAD_OP             7'b0000011 // LB LH LW LBU LHU
`define STORE_OP            7'b0100011 // SB SH SW

// For Inst funct3
`define NON_FUNCT3          3'b000
`define ADDI_FUNCT3         3'b000
`define ORI_FUNCT3          3'b110

// For Inst funct7
`define NON_FUNCT7          7'b0000000 // Nothing

// For General
`define RegNum              32
`define RegNumLog2          5
`define ZeroWord            32'h00000000
`define NOPRegAddr          5'b00000
