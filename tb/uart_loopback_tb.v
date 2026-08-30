`timescale 1ns/1ps
`default_nettype none

module uart_loopback_tb;

    reg       clk;
    reg       reset;

    reg       tx_start;
    reg [7:0] tx_data;

    wire      tx;
    wire      tx_busy;
    wire      tx_done;

    wire [7:0] rx_data;
    wire       rx_done;
    wire       rx_busy;

    reg        bit_tick;

    integer    bit_counter;

    integer pass_count;
    integer fail_count;


    // ==========================================
    // UART TX
    // ==========================================

    uart_tx #(
        .CLK_FREQ  (50_000_000),
        .BAUD_RATE (9600)
    ) tx_inst (
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
    // UART RX
    // TX OUTPUT CONNECTED DIRECTLY TO RX INPUT
    // ==========================================

    uart_rx #(
        .CLK_FREQ  (50_000_000),
        .BAUD_RATE (9600)
    ) rx_inst (
        .clk      (clk),
        .reset    (reset),
        .rx       (tx),
        .rx_data  (rx_data),
        .rx_done  (rx_done),
        .rx_busy  (rx_busy)
    );


    // ==========================================
    // 50 MHz CLOCK
    // 20 ns PERIOD
    // ==========================================

    always #10 clk = ~clk;


    // ==========================================
    // BAUD TICK GENERATOR
    // 50 MHz / 9600 ≈ 5208 CLOCKS PER BIT
    // ==========================================

    always @(posedge clk) begin

        if (reset) begin

            bit_counter <= 0;
            bit_tick    <= 1'b0;

        end

        else begin

            if (bit_counter == 5207) begin

                bit_counter <= 0;
                bit_tick    <= 1'b1;

            end

            else begin

                bit_counter <= bit_counter + 1;
                bit_tick    <= 1'b0;

            end

        end

    end


    // ==========================================
    // SEND BYTE
    // ==========================================

    task send_byte;
        input [7:0] data;

        begin

            wait (tx_busy == 1'b0);

            @(negedge clk);

            tx_data  = data;
            tx_start = 1'b1;

            @(posedge clk);

            #1;
            tx_start = 1'b0;

        end

    endtask


    // ==========================================
    // CHECK RECEIVED BYTE
    // ==========================================

    task check_byte;
        input [7:0] expected;

        begin

            wait (rx_done == 1'b1);

            if (rx_data == expected) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS: TX=%02h RX=%02h",
                    expected,
                    rx_data
                );

            end

            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL: TX=%02h RX=%02h",
                    expected,
                    rx_data
                );

            end

        end

    endtask


    // ==========================================
    // MAIN TEST
    // ==========================================

    initial begin

        $dumpfile("uart_loopback_waveform.vcd");
        $dumpvars(0, uart_loopback_tb);

        clk        = 1'b0;
        reset      = 1'b1;
        tx_start   = 1'b0;
        tx_data    = 8'h00;

        bit_tick   = 1'b0;
        bit_counter = 0;

        pass_count = 0;
        fail_count = 0;


        // ======================================
        // RESET
        // ======================================

        #100;

        reset = 1'b0;

        #100;


        // ======================================
        // BYTE 1: A5
        // ======================================

        fork
            send_byte(8'hA5);
            check_byte(8'hA5);
        join

        #1000;


        // ======================================
        // BYTE 2: 55
        // ======================================

        fork
            send_byte(8'h55);
            check_byte(8'h55);
        join

        #1000;


        // ======================================
        // BYTE 3: 00
        // ======================================

        fork
            send_byte(8'h00);
            check_byte(8'h00);
        join

        #1000;


        // ======================================
        // BYTE 4: FF
        // ======================================

        fork
            send_byte(8'hFF);
            check_byte(8'hFF);
        join

        #1000000;


        // ======================================
        // FINAL RESULT
        // ======================================

        $display("");
        $display("================================");
        $display("      UART LOOPBACK TEST");
        $display("================================");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("================================");
        $display("");

        $finish;

    end

endmodule

`default_nettype wire