`timescale 1ns/1ps
`default_nettype none

module uart_rx #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx,

    output reg [7:0]  rx_data,
    output reg        rx_done,
    output reg        rx_busy
);

    // ==========================================
    // CLOCKS PER UART BIT
    // ==========================================

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam integer HALF_BIT     = CLKS_PER_BIT / 2;


    // ==========================================
    // RECEIVER STATES
    // ==========================================

    localparam [2:0]
        IDLE  = 3'd0,
        START = 3'd1,
        DATA  = 3'd2,
        STOP  = 3'd3,
        DONE  = 3'd4;


    reg [2:0] state;

    reg [15:0] clk_count;
    reg [2:0]  bit_count;
    reg [7:0]  rx_shift;


    // ==========================================
    // UART RX
    // ==========================================

    always @(posedge clk) begin

        if (reset) begin

            state     <= IDLE;
            clk_count <= 16'd0;
            bit_count <= 3'd0;
            rx_shift  <= 8'd0;

            rx_data   <= 8'd0;
            rx_done   <= 1'b0;
            rx_busy   <= 1'b0;

        end

        else begin

            // Default: rx_done is a one-clock pulse
            rx_done <= 1'b0;


            case (state)

                // ==================================
                // IDLE
                // ==================================

                IDLE: begin

                    rx_busy   <= 1'b0;
                    clk_count <= 16'd0;
                    bit_count <= 3'd0;

                    // UART line normally HIGH.
                    // LOW means START bit detected.
                    if (rx == 1'b0) begin

                        rx_busy   <= 1'b1;
                        clk_count <= 16'd0;
                        state     <= START;

                    end

                end


                // ==================================
                // START BIT
                // ==================================

                START: begin

                    // Wait until middle of START bit
                    if (clk_count == HALF_BIT - 1) begin

                        clk_count <= 16'd0;

                        // Confirm line is still LOW
                        if (rx == 1'b0) begin

                            bit_count <= 3'd0;
                            state     <= DATA;

                        end
                        else begin

                            // False start
                            state <= IDLE;
                            rx_busy <= 1'b0;

                        end

                    end

                    else begin

                        clk_count <= clk_count + 1'b1;

                    end

                end


                // ==================================
                // DATA BITS
                // ==================================

                DATA: begin

                    if (clk_count == CLKS_PER_BIT - 1) begin

                        clk_count <= 16'd0;

                        // LSB first
                        rx_shift[bit_count] <= rx;

                        if (bit_count == 3'd7) begin

                            state <= STOP;

                        end
                        else begin

                            bit_count <= bit_count + 1'b1;

                        end

                    end

                    else begin

                        clk_count <= clk_count + 1'b1;

                    end

                end


                // ==================================
                // STOP BIT
                // ==================================

                STOP: begin

                    if (clk_count == CLKS_PER_BIT - 1) begin

                        clk_count <= 16'd0;

                        // Stop bit should be HIGH
                        if (rx == 1'b1) begin

                            rx_data <= rx_shift;
                            state   <= DONE;

                        end
                        else begin

                            // Invalid stop bit
                            state <= IDLE;
                            rx_busy <= 1'b0;

                        end

                    end

                    else begin

                        clk_count <= clk_count + 1'b1;

                    end

                end


                // ==================================
                // DONE
                // ==================================

                DONE: begin

                    rx_done <= 1'b1;
                    rx_busy <= 1'b0;

                    state <= IDLE;

                end


                // ==================================
                // DEFAULT
                // ==================================

                default: begin

                    state     <= IDLE;
                    clk_count <= 16'd0;
                    bit_count <= 3'd0;
                    rx_busy   <= 1'b0;

                end

            endcase

        end

    end

endmodule

`default_nettype wire