module serial_to_par(
    input wire clk,
    input wire serial,
    output reg [15:0] par
);
    reg [15:0] par_last;
    always @(*) begin
        par = {serial, par_last[15:1]};
    end
    always @(posedge clk) begin
        par_last <= par;
    end
endmodule