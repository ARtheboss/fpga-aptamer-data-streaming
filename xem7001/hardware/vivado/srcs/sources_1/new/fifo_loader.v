`timescale 1ns / 1ps

module fifo_loader(
    input wire ext_clk,
    input wire ti_clk,
    input wire en,
    input wire [7:0] serial_in,
    input wire fifo_ren,
    output reg [15:0] pipe_out,
    output wire fifo_full
    );

    wire rst;
    assign rst = ~en;

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
    reg toggle;
    always @(posedge ti_clk) begin
        if (rst || bit_cnt < 4'd15) toggle <= 1;
        else toggle <= ~toggle;
    end
    reg [3:0] channel_cnt;
    always @(posedge ti_clk) begin
        if (rst || bit_cnt < 4'd15) channel_cnt <= 0;
        else begin
            if (channel_cnt > 4'd8 || ~toggle) channel_cnt <= channel_cnt;
            else channel_cnt <= channel_cnt + 1;
        end
    end
    assign fifo_din = (toggle) ? par[channel_cnt[2:0]] : {8'd0, channel_cnt};
    assign fifo_wen = (4'd1 <= channel_cnt && channel_cnt <= 4'd8);

    fifo_generator_0 fifo(
        .clk(ti_clk),
        .srst(rst),
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
    always @(posedge ti_clk) begin
        if (read_last) pipe_out = fifo_dout;
        else pipe_out = 16'd0;
    end
endmodule

