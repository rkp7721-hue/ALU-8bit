`timescale 1ns/1ps
`default_nettype none

module uart_tx #(
    parameter integer CLK_FREQ  = 50_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       reset,

    input  wire       tx_start,
    input  wire [7:0] tx_data,

    input  wire       bit_tick,

    output reg        tx,
    output reg        tx_busy,
    output reg        tx_done
);

    // ==========================================
    // UART TRANSMITTER STATES
    // ==========================================

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;


    // ==========================================
    // INTERNAL REGISTERS
    // ==========================================

    reg [1:0] state;

    reg [7:0] tx_shift_reg;

    reg [2:0] bit_count;


    // ==========================================
    // UART TRANSMITTER
    // ==========================================

    always @(posedge clk) begin

        if (reset) begin

            state        <= IDLE;
            tx_shift_reg <= 8'd0;
            bit_count    <= 3'd0;

            tx            <= 1'b1;
            tx_busy       <= 1'b0;
            tx_done       <= 1'b0;

        end

        else begin

            // tx_done is one-clock pulse
            tx_done <= 1'b0;


            case (state)

                // ==================================
                // IDLE
                // ==================================

                IDLE: begin

                    tx        <= 1'b1;
                    tx_busy   <= 1'b0;
                    bit_count <= 3'd0;

                    if (tx_start) begin

                        // Capture data
                        tx_shift_reg <= tx_data;

                        // Start transmission
                        tx_busy <= 1'b1;

                        // Go to START bit
                        state <= START;

                    end

                end


                // ==================================
                // START BIT
                // ==================================

                START: begin

                    // UART START bit = LOW
                    tx      <= 1'b0;
                    tx_busy <= 1'b1;

                    if (bit_tick) begin

                        // START bit completed
                        state     <= DATA;
                        bit_count <= 3'd0;

                    end

                end


                // ==================================
                // DATA BITS
                // ==================================

                DATA: begin

                    // Send LSB first
                    tx      <= tx_shift_reg[0];
                    tx_busy <= 1'b1;

                    if (bit_tick) begin

                        if (bit_count == 3'd7) begin

                            // Last data bit completed
                            state <= STOP;

                        end

                        else begin

                            // Shift next bit into bit 0
                            tx_shift_reg <= {
                                1'b0,
                                tx_shift_reg[7:1]
                            };

                            bit_count <= bit_count + 3'd1;

                        end

                    end

                end


                // ==================================
                // STOP BIT
                // ==================================

                STOP: begin

                    // UART STOP bit = HIGH
                    tx      <= 1'b1;
                    tx_busy <= 1'b1;

                    if (bit_tick) begin

                        // Transmission complete
                        state    <= IDLE;
                        tx_busy  <= 1'b0;
                        tx_done  <= 1'b1;

                    end

                end


                // ==================================
                // DEFAULT
                // ==================================

                default: begin

                    state        <= IDLE;
                    tx_shift_reg <= 8'd0;
                    bit_count    <= 3'd0;

                    tx       <= 1'b1;
                    tx_busy  <= 1'b0;
                    tx_done  <= 1'b0;

                end

            endcase

        end

    end

endmodule

`default_nettype wire