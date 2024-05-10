`timescale 1ns / 1ps
`default_nettype wire
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2024 09:49:04 AM
// Design Name: 
// Module Name: prbs15
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


module prbs15(input clk, input rst, output bs);
  parameter [14:0] seed = 15'b111111111111111;
  reg [14:0] state;
  wire temp_next;
  
  assign temp_next = state[14] ^ state[13];
  assign bs = state[14];
  always @(posedge clk) begin
    if (rst) begin
      state = seed;
    end else begin
      state[14:1] <= state[13:0];
      state[0] <= temp_next;
    end
  end
endmodule
