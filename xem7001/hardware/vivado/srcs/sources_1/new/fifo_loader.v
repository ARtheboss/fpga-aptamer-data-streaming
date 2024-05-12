`timescale 1ns / 1ps

module fifo_loader(
    input wire clk1,
    input wire ext_clk,
    input wire ti_clk,
    input wire en,
    input wire [7:0] serial_in,
    input wire fifo_ren,
    output reg [15:0] pipe_out,
    output wire fifo_full,
    output wire data_out_valid
    );

    wire rst;
    assign rst = ~en;
    
    reg rst_negedge, rst_last;
    always @(posedge clk1) begin
        rst_last <= rst;
        rst_negedge = !rst & rst_last;
    end

    // generate parallel signals from serial
    wire [15:0] par [7:0];
    generate 
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin
           serial_to_par stp(.clk(ext_clk), .serial(serial_in[i]), .par(par[i]));
        end
    endgenerate

    wire [15:0] fifo_din, fifo_dout;
    wire fifo_wen, empty;
    reg [3:0] bit_cnt;

    always @(posedge ext_clk) begin
        if (rst) bit_cnt <= 0;
        else bit_cnt <= bit_cnt + 1;
    end
    reg [3:0] word_cnt;
    always @(posedge clk1) begin
        if (rst || bit_cnt < 4'd15) word_cnt <= 0;
        else if (word_cnt >= 4'd9) word_cnt <= word_cnt;
        else word_cnt <= word_cnt + 1;
    end
    assign fifo_din = (word_cnt == 4'd0) ? 16'hfffe : par[word_cnt - 1];
    assign fifo_wen = bit_cnt == 4'd15 && word_cnt < 4'd9;

    fifo_generator_0 fifo(
        .wr_clk(clk1),
        .rd_clk(ti_clk),
        .rst(rst),
        .din(fifo_din),
        .wr_en(fifo_wen),
        .rd_en(fifo_ren & !empty),
        .dout(fifo_dout),
        .full(fifo_full),
        .empty(empty)
    );
    reg read_last;
    always @(posedge ti_clk) begin
        read_last <= fifo_ren & !empty;
    end
    assign data_out_valid = empty;
    always @(*) begin
        if (read_last) pipe_out = fifo_dout;
        else pipe_out = 16'hffff;
    end
endmodule

