// 全局宏
`define RstEnable       1'b0            //复位有效
`define RstDisable      1'b1            //复位无效
`define ZeroWord        32'h00000000    //32bit的0
`define WriteEnable     1'b1            //能写
`define WriteDisable    1'b0            //禁写
`define ReadEnable      1'b1            //能读
`define ReadDisable     1'b0            //禁读
`define AluOpBus        7:0             //译码阶段的指令运算子类型接口的宽度
`define AluSelBus       2:0             //译码阶段的指令运算类型接口的宽度
`define InstValid       1'b0            //指令有效
`define InstInvalid     1'b1            //指令无效
`define True_v          1'b1            //逻辑真
`define False_v         1'b0            //逻辑假
`define ChipEnable      1'b1            //芯片使能
`define ChipDisable     1'b0            //芯片禁止

// 指令宏
`define EXE_ORI         6'b001101       //指令ori的指令码
`define EXE_NOP         6'b000000
// AluOP
`define EXE_OR_OP       8'b00100101
`define EXE_NOP_OP      8'b00000000
// AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_NOP     3'b000

// ROM宏
`define InstAddrBus     31:0            //ROM地址总线宽度
`define InstBus         31:0            //ROM数据总线宽度
`define InstMemNum      131071          //ROM实际大小
`define InstMemNumLog2  17              //ROM实际使用的地址线宽度

// Reg宏
`define RegAddrBus      4:0             //Reg模块地址线宽度
`define RegBus          31:0            //Reg模块数据线宽度
`define RegWidth        32              //通用寄存器的宽度
`define DoubleRegWidth  64              //两倍的通用寄存器宽度
`define DoubleRegBus    63:0            //两倍的通用寄存器数据线宽度
`define RegNum          32              //通用寄存器数量
`define RegNumLog2      5               //寻址通用寄存器的地址位数
`define NOPRegAddr      5'b00000
