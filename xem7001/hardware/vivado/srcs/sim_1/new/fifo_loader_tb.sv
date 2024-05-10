`timescale 1ns / 1ps

`define CLK1_T 4
`define CLK2_T 80

module fifo_loader_tb;

    reg ti_clk = 1;
    wire ext_clk;
    always #(`CLK1_T/2) ti_clk <= ~ti_clk;
    fake_ext_clk #(.CLK_IN_FREQ(250000000), .CLK_OUT_FREQ(12500000)) fec(
        .clk_in(ti_clk),
        .rst(rst),
        .clk_out(ext_clk)
    );
    
    reg rst;
    reg [7:0] serial_in;
    reg fifo_ren = 1;
    
    wire [15:0] pipe_out;
    wire fifo_full;
    
    fifo_loader fl(.ext_clk(ext_clk), .ti_clk(ti_clk), .rst(rst), .serial_in(serial_in), .fifo_ren(fifo_ren), .pipe_out(pipe_out), .fifo_full(fifo_full));
    generate
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin
            serial_counter sc(.clk(ext_clk), .rst(rst), .out(serial_in[i]));
        end
    endgenerate
    
    integer error_count;
    
    integer k, l, m;
    task set_serial_in (input [31:0] i);
       k = 0;
        for (; k < 16; k = k + 1) begin
            for (l = 1; l <= 8; l = l + 1) begin
                serial_in[l-1] = (k < 8) ? l[8-k-1] : i[8-(k-8)-1]; 
            end
            @(posedge ext_clk);
        end
    endtask
    task check_output (input [31:0] i);
        while (pipe_out == 16'd0) begin
            @(posedge ti_clk);
        end
        for (m = 1; m <= 8; m = m + 1) begin
            if (pipe_out != m[15:0]) begin
                error_count = error_count + 1;
                 $display("Expected %d, was %d", m[15:0], pipe_out);
            end
            @(posedge ti_clk);
            if (pipe_out != i[15:0]) begin
                error_count = error_count + 1;
                $display("Expected %x, was %x", i[15:0], pipe_out); 
            end
            @(posedge ti_clk);
        end
    endtask
    
    localparam REPEATS = 100;
    
    integer j;
    initial begin
        error_count = 0;
        j = 0;
        rst = 1;
        serial_in = 8'd0;
        @(posedge ti_clk);
        #2; rst = 0;
        begin
            for (j = 1; j < REPEATS; j = j + 1) begin
                check_output(j);
            end
        end
        $display("Finished. Error Count: %d", error_count);
        $finish();
    end

endmodule
