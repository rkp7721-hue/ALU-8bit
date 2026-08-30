`timescale 1ns/1ps
`default_nettype none

module baud_tick_gen #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire reset,

    output reg  bit_tick
);

    // ==========================================
    // CLOCKS PER UART BIT
    // ==========================================

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;


    // ==========================================
    // COUNTER
    // ==========================================

    reg [31:0] bit_counter;


    // ==========================================
    // BAUD TICK GENERATOR
    // ==========================================

    always @(posedge clk) begin

        if (reset) begin

            bit_counter <= 32'd0;
            bit_tick    <= 1'b0;

        end

        else begin

            // Default: tick is LOW
            bit_tick <= 1'b0;

            if (bit_counter == CLKS_PER_BIT - 1) begin

                bit_counter <= 32'd0;
                bit_tick    <= 1'b1;

            end

            else begin

                bit_counter <= bit_counter + 1'b1;

            end

        end

    end

endmodule

`default_nettype wire