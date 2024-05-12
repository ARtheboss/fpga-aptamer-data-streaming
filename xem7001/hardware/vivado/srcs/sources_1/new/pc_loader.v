
module pc_loader(
    input wire [30:0] ok1,
    input wire ext_clk,
    input wire ti_clk,
    input wire clk1,
    input wire en,
    input wire [7:0] serial_in,
    output wire fifo_full,
    output wire [16:0] ok2,
    output wire data_out_valid
    );
    
    wire fifo_ren;

    wire [15:0] data_out;

    wire [17*2-1:0] ok2x;
    okWireOR #(.N(2)) wireOR (ok2, ok2x);

    okPipeOut pipeA0(
        .ok1(ok1),
        .ok2(ok2x[16:0]),
        .ep_addr(8'hA0),
        .ep_read(fifo_ren),
        .ep_datain(data_out)
    );

    reg en_last;
    always @(posedge ti_clk) begin
        en_last <= en;
    end

    okTriggerOut trigOut6A(
        .ok1(ok1),
        .ok2(ok2x[17*2-1:17]),
        .ep_addr(8'h6a),
        .ep_clk(ti_clk),
        .ep_trigger({15'd0, en})
    );

    fifo_loader fl(
        .ext_clk(ext_clk),
        .ti_clk(ti_clk),
        .clk1(clk1),
        .en(en),
        .serial_in(serial_in),
        .fifo_ren(fifo_ren),
        .pipe_out(data_out),
        .fifo_full(fifo_full),
        .data_out_valid(data_out_valid)
    );
endmodule