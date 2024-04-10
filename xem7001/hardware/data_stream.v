module data_stream (
    input serial_in,
    input wire[7:0] hi_in,
    output wire [1:0] hi_out,
    inout wire [15:0] hi_inout,
    input wire [3:0] button,
    output reg [7:0] led,
    input wire clk1
);

    wire ti_clk;
    wire [16:0] ok2;
    wire [30:0] ok1;
    // Adjust size of ok2x to fit the number of outgoing FrontPanel endpoints in your design [n*17-1:0]

    // Your wires here

    //Your circuit behavior here
    
    //Host interfaces directly with FPGA pins
    okHost okHI( 
        .hi_in(hi_in),
        .hi_out(hi_out),
        .hi_inout(hi_inout),
        .ti_clk(ti_clk),
        .ok1(ok1),
        .ok2(ok2)
    );

    // Circuit wires
    wire fifowrite;
    wire fiforead;
    wire [15:0] dataout;
    wire reset;
    wire [15:0] wireout;
    reg [3:0] cycle_counter;
    reg [15:0] shift_reg;

    always @(posedge ti_clk) begin
        cycle_counter => cycle_counter + 1;
        shift_reg => {serial_in, shift_reg[14:0]};
    end
    assign fifowrite = cycle_counter == 4'd15;
        
    //Circuit behavior
    assign reset = wireout[0];
    
    // Xilinx Core IP Generated FIFO	
    FIFO_16bit fifo(
        .din(shift_reg),
        .dout(dataout),
        .wr_en(fifowrite),
        .rd_en(fiforead),
        .clk(ti_clk),
        .rst(reset)
    );
        
    // FrontPanel module instantiations
    
    okPipeOut pipeA0(
        .ok1(ok1),
        .ok2(ok2),
        .ep_addr(8'hA0),
        .ep_read(fiforead),
        .ep_datain(dataout)
    );
endmodule