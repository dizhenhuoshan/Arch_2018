// time 1ns accuracy 1ps
`timescale 1ns / 1ps

module openmips_min_spoc_tb();

    reg CLOCK_50;
    reg rst;

    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        rst = `RstEnable;
        #195 rst = `RstDisable;
        #1000 $stop;
    end
    
    openmips_min_spoc openmips_min_spoc0(
                .clk(CLOCK_50),
                .rst(rst)
        );
        
endmodule
