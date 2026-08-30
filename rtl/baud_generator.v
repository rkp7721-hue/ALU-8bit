`timescale 1ns/1ps
`default_nettype none

module baud_generator #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire reset,

    output reg baud_tick
);

    // Number of system-clock cycles required
    // for approximately one UART bit period.
    localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;

    integer baud_count;

    always @(posedge clk) begin

        if (reset) begin

            baud_count <= 0;
            baud_tick  <= 1'b0;

        end

        else begin

            if (baud_count == BAUD_DIV - 1) begin

                baud_count <= 0;
                baud_tick  <= 1'b1;

            end

            else begin

                baud_count <= baud_count + 1;
                baud_tick  <= 1'b0;

            end

        end

    end

endmodule

`default_nettype wire