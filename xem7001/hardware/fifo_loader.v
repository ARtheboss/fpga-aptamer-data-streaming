module fifo_loader(
    input ext_clk,
    input ti_clk,
    input rst,
    input [15:0] par [7:0],
    input fifo_ren,
    output [15:0] pipe_out,
    output fifo_full,
);
    wire [15:0] fifo_din, fifo_dout;
    wire fifo_wen, empty;
    reg [3:0] bit_cnt;
    always @(posedge ext_clk) begin
        if (rst) bit_cnt <= 0;
        else bit_cnt <= bit_cnt + 1;
    end
    reg toggle;
    always @(posedge ti_clk) begin
        if (rst || bit_cnt < 4'd15) toggle <= 0;
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
    assign fifo_wen = (bit_cnt == 4'd15) && (channel_cnt <= 4'd8);

    fifo_generator_0 fifo(
        .clk(ti_clk),
        .srst(rst),
        .din(fifo_din),
        .wr_en(fifo_wen),
        .rd_en(fifo_ren),
        .dout(fifo_dout),
        .full(fifo_full),
        .empty(empty)
    );
    assign pipe_out = (empty) ? 16'd0 : fifo_dout;
endmodule