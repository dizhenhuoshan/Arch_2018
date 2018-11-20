`include"defines.v"
module openmips(

    input wire                  clk,
    input wire                  rst,

    input wire[`RegBus]         rom_data_i,
    output wire[`RegBus]        rom_data_o,
    output wire                 rom_ce_o    
);

endmodule
