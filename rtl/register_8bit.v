`timescale 1ns/1ps
`default_nettype none

module register_8bit (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] D,
    output reg  [7:0] Q
);

    // ==========================================
    // 8-BIT REGISTER WITH SYNCHRONOUS RESET
    // ==========================================

    always @(posedge clk) begin

        if (reset) begin
            Q <= 8'd0;
        end
        else begin
            Q <= D;
        end

    end

endmodule

`default_nettype wire