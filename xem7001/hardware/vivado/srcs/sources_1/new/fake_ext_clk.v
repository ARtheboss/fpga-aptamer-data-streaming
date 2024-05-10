`timescale 1ns / 1ps


module fake_ext_clk(
    input wire clk_in,
    input wire rst,
    output reg clk_out
    );
    parameter CLK_IN_FREQ = 48000000;
    parameter CLK_OUT_FREQ = 100000;
    localparam TARGET = CLK_IN_FREQ / CLK_OUT_FREQ / 2;
    localparam T_WIDTH = $clog2(TARGET);
    
    reg [T_WIDTH-1:0] counter, counter_n;
    reg clk_out_n;
    always @(*) begin
        if (rst) begin
            counter_n = 0;
            clk_out_n = 1;
        end else begin
            counter_n = (counter == TARGET-1) ? 0 : counter + 1;
            clk_out_n = (counter == TARGET-1) ? ~clk_out : clk_out;
        end
    end
    always @(posedge clk_in) begin
        counter <= counter_n; 
        clk_out <= clk_out_n;
    end
endmodule
