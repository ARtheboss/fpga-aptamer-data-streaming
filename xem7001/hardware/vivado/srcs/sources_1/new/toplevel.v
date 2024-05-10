`timescale 1ns / 1ps
`default_nettype wire

`define CLK1_FREQ 50155000 // experimentally found
`define TARGET_CLK_FREQ 640000

module toplevel(
    // input [7:0] serial_in,
    input clk1,
    // input ext_clk,
    input [7:0] hi_in,
    output [1:0] hi_out,
    inout [15:0] hi_inout,
    inout hi_aa,
    output hi_muxsel,
    input [3:0] button,
    output [7:0] led,
    output ext_clk
    );
    
    assign hi_muxsel = 1'b0;
    
    assign led[0] = 0;
    assign led[1] = button[0];
    
    // wire ext_clk; // fake ext_clk
    fake_ext_clk #(.CLK_IN_FREQ(`CLK1_FREQ), .CLK_OUT_FREQ(`TARGET_CLK_FREQ)) fec(.clk_in(clk1), .rst(~button[0]), .clk_out(ext_clk));
    
    wire [7:0] serial_fake;
    generate
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin
            // assign serial_fake[i] = 1;
            serial_counter sc(.clk(ext_clk), .rst(!button[0]), .out(serial_fake[i]));
            // prbs15 #(.seed(i+1)) fake_data (.clk(ext_clk), .rst(!button[0]), .bs(serial_fake[i]));
        end
    endgenerate
    
    wire ti_clk;
    wire [16:0] ok2;
    wire [30:0] ok1;
    wire [16:0] ok2x;
    
    okWireOR #(.N(1)) wireOR (ok2, ok2x);
    
    //Host interfaces directly with FPGA pins
    okHost okHI( 
        .hi_in(hi_in),
        .hi_out(hi_out),
        .hi_inout(hi_inout),
        .hi_aa(hi_aa),
        .ti_clk(ti_clk),
        .ok1(ok1),
        .ok2(ok2)
    );

    wire fifo_read;
    wire [15:0] data_out;
    wire toggle, fifo_full;

    fifo_loader fl(
        .ext_clk(ext_clk),
        .ti_clk(ti_clk),
        .rst(!button[0]),
        .serial_in(serial_fake),
        .fifo_ren(fifo_read),
        .pipe_out(data_out),
        .fifo_full(fifo_full),
        .toggle(led[2])
    );
    assign led[3] = ~fifo_full;
        
    // FrontPanel module instantiations
    
    okPipeOut pipeA0(
        .ok1(ok1),
        .ok2(ok2x),
        .ep_addr(8'hA0),
        .ep_read(fifo_read),
        .ep_datain(data_out)
    );
    assign led[7:4] = data_out[3:0];
endmodule
