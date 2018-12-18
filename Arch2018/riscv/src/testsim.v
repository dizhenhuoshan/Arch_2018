// time 1ns accuracy 1ps
`timescale 1ns / 1ps

`include"defines.v"
module riscvtest();

    reg CLOCK_50;
    reg rst;
    reg rdy;

    initial begin
        CLOCK_50 = 1'b0;
        forever #1 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        rst = `RstEnable;
        rdy = `PauseEnable;
        #190 rdy = `PauseDisable;
        rst = `RstDisable;
    end

    spoc spoc0(
                .clk(CLOCK_50),
                .rst(rst),
                .rdy(rdy)
        );

endmodule
