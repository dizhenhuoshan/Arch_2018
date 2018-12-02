// time 1ns accuracy 1ps
`timescale 1ns / 1ps
`include"defines.v"
module riscvtest();

    reg CLOCK_50;
    reg rst;
    reg rdy;

    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        rst = `RstEnable;
        rdy = `PauseEnable;
        #195 rdy = `PauseDisable;
        rst = `RstDisable;
        #1000 $stop;
    end

    cpu cpu0(
                .clk_in(CLOCK_50),
                .rst_in(rst),
                .rdy_in(rdy)
        );

endmodule
