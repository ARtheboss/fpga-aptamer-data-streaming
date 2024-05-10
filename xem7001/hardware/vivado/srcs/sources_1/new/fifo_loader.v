`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2024 04:14:01 PM
// Design Name: 
// Module Name: fifo_loader
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_loader(
    input ext_clk,
    input ti_clk,
    input rst,
    input [15:0] par [7:0],
    input fifo_ren,
    output [15:0] pipe_out,
    output fifo_full
    );
endmodule
