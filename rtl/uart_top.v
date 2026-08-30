`timescale 1ns/1ps
`default_nettype none

module uart_top #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       reset,

    // TX interface
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx,
    output wire       tx_busy,
    output wire       tx_done,

    // RX interface
    input  wire       rx,
    output wire [7:0] rx_data,
    output wire       rx_done,
    output wire       rx_busy
);

    // ==========================================
    // INTERNAL BAUD TICK
    // ==========================================

    wire bit_tick;


    // ==========================================
    // BAUD TICK GENERATOR
    // ==========================================

    baud_tick_gen #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) baud_gen_inst (
        .clk      (clk),
        .reset    (reset),
        .bit_tick (bit_tick)
    );


    // ==========================================
    // UART TRANSMITTER
    // ==========================================

    uart_tx tx_inst (
        .clk      (clk),
        .reset    (reset),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .bit_tick (bit_tick),
        .tx       (tx),
        .tx_busy  (tx_busy),
        .tx_done  (tx_done)
    );


    // ==========================================
    // UART RECEIVER
    // ==========================================

    uart_rx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) rx_inst (
        .clk      (clk),
        .reset    (reset),
        .rx       (rx),
        .rx_data  (rx_data),
        .rx_done  (rx_done),
        .rx_busy  (rx_busy)
    );

endmodule

`default_nettype wire