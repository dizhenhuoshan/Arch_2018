// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include"defines.v"
module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire			        rdy_in,			// ready signal, pause cpu when low

    input  wire [7:0]           mem_din,		// data input bus
    output wire [7:0]           mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// link fakemem
wire[`InstAddrBus]      inst_addr;
wire[`InstBus]          inst_data;

// link if_id to id
wire[`InstAddrBus]      id_pc_i;
wire[`InstBus]          id_inst_i;

// link id to id_ex
wire[`OpcodeBus]        id_opcode_o;
wire[`FunctBus3]        id_funct3_o;
wire[`FunctBus7]        id_funct7_o;
wire[`RegBus]           id_reg1_o;
wire[`RegBus]           id_reg2_o;
wire[`RegAddrBus]       id_wd_o;
wire                    id_wreg_o;

// link id_ex to ex
wire[`OpcodeBus]        ex_opcode_i;
wire[`FunctBus3]        ex_funct3_i;
wire[`FunctBus7]        ex_funct7_i;
wire[`RegBus]           ex_reg1_i;
wire[`RegBus]           ex_reg2_i;
wire[`RegAddrBus]       ex_wd_i;
wire                    ex_wreg_i;

// link ex to ex_mem
wire[`RegAddrBus]       ex_wd_o;
wire[`RegBus]           ex_wdata_o;
wire                    ex_wreg_o;

// link ex_mem to mem
wire[`RegAddrBus]       mem_wd_i;
wire[`RegBus]           mem_wdata_i;
wire                    mem_wreg_i;

// link mem to mem_wb
wire[`RegAddrBus]       mem_wd_o;
wire[`RegBus]           mem_wdata_o;
wire                    mem_wreg_o;

// link mem_wb to reg
wire[`RegAddrBus]       wb_wd_i;
wire[`RegBus]           wb_wdata_i;
wire                    wb_wreg_i;

// link id to regfile
wire                    reg1_read;
wire                    reg2_read;
wire[`RegAddrBus]       reg1_addr;
wire[`RegAddrBus]       reg2_addr;
wire[`RegBus]           reg1_data;
wire[`RegBus]           reg2_data;

pc_reg pc_reg0(
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .pc(inst_addr)
);

regfile regfile0(
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .we(wb_wreg_i),
    .waddr(wb_wd_i),
    .wdata(wb_wdata_i),
    .re1(reg1_read),
    .re2(reg2_read),
    .raddr1(reg1_addr),
    .rdata1(reg1_data),
    .raddr2(reg2_addr),
    .rdata2(reg2_data)
);

if_id if_id0(
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .if_pc(inst_addr),
    .if_inst(inst_data),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

id id0(
    .rst(rst_in),
    .rdy(rdy_in),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),
    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),
    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),
    .opcode_o(id_opcode_o),
    .funct3_o(id_funct3_o),
    .funct7_o(id_funct7_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o)
);

id_ex id_ex0(
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .id_opcode(id_opcode_o),
    .id_funct3(id_funct3_o),
    .id_funct7(id_funct7_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),
    .ex_opcode(ex_opcode_i),
    .ex_funct3(ex_funct3_i),
    .ex_funct7(ex_funct7_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i)
);

ex ex0(
    .rst(rst_in),
    .rdy(rdy_in),
    .opcode_i(ex_opcode_i),
    .funct3_i(ex_funct3_i),
    .funct7_i(ex_funct7_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o)
);

ex_mem ex_mem0(
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i)
);

mem mem0(
    .rst(rst_in),
    .rdy(rdy_in),
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o)
);

mem_wb mem_wb0(
    .clk(clk_in),
    .rst(rst_in),
    .rdy(rdy_in),
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)
);

fakemem fakemem0(
    .rst(rst_in),
    .rdy(rdy_in),
    .addr(inst_addr),
    .inst(inst_data)
);

endmodule