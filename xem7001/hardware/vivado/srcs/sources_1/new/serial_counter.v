`timescale 1ns / 1ps

module serial_counter(
    input wire clk,
    input wire rst,
    output wire out
    );
    parameter START = 16'd0;
    reg [3:0] bit_counter, bit_counter_n;
    reg [15:0] value, value_n;
    always @(*) begin
        bit_counter_n = bit_counter + 1;
        value_n = (bit_counter == 4'd15) ? value + 1 : value;
        if (rst) begin
            bit_counter_n = 4'd0;
            value_n = START;
        end
    end
    always @(posedge clk) begin
        bit_counter <= bit_counter_n;
        value <= value_n;
    end
    assign out = value[bit_counter];
endmodule
