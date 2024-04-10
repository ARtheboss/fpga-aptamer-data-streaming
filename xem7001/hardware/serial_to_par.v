module serial_to_par(
    input clk,
    input serial,
    output reg [15:0] par
); 
    always @(posedge clk) begin
        par <= {par[14:0], serial};
    end
endmodule