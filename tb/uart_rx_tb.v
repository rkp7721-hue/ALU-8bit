`timescale 1ns/1ps
`default_nettype none

module uart_rx_tb;

    reg       clk;
    reg       reset;
    reg       rx;

    wire [7:0] rx_data;
    wire       rx_done;
    wire       rx_busy;

    integer pass_count;
    integer fail_count;


    // ==========================================
    // DUT
    // ==========================================

    uart_rx #(
        .CLK_FREQ  (50_000_000),
        .BAUD_RATE (9600)
    ) uut (
        .clk      (clk),
        .reset    (reset),
        .rx       (rx),
        .rx_data  (rx_data),
        .rx_done  (rx_done),
        .rx_busy  (rx_busy)
    );


    // ==========================================
    // 50 MHz CLOCK
    // ==========================================

    always #10 clk = ~clk;


    // ==========================================
    // SEND ONE UART BIT
    // ==========================================

    task send_bit;
        input bit_value;
        begin
            rx = bit_value;
            #104170;
        end
    endtask


    // ==========================================
    // SEND ONE UART BYTE
    // ==========================================

    task send_byte;
        input [7:0] data;
        integer i;

        begin

            // START BIT
            send_bit(1'b0);

            // DATA BITS — LSB FIRST
            for (i = 0; i < 8; i = i + 1) begin
                send_bit(data[i]);
            end

            // STOP BIT
            send_bit(1'b1);

        end
    endtask


    // ==========================================
    // TEST
    // ==========================================

    task check_byte;
        input [7:0] expected;
        begin

            wait (rx_done == 1'b1);

            if (rx_data == expected) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS: RX = %02h, Expected = %02h",
                    rx_data,
                    expected
                );

            end

            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL: RX = %02h, Expected = %02h",
                    rx_data,
                    expected
                );

            end

        end
    endtask


    // ==========================================
    // MAIN TEST
    // ==========================================

    initial begin

        $dumpfile("uart_rx_waveform.vcd");
        $dumpvars(0, uart_rx_tb);

        pass_count = 0;
        fail_count = 0;

        clk   = 1'b0;
        reset = 1'b1;
        rx    = 1'b1;


        // ======================================
        // RESET
        // ======================================

        #100;

        reset = 1'b0;

        #100;


        // ======================================
        // TEST 1 — A5
        // ======================================

        fork
            send_byte(8'hA5);
            check_byte(8'hA5);
        join


        #1000;


        // ======================================
        // TEST 2 — 55
        // ======================================

        fork
            send_byte(8'h55);
            check_byte(8'h55);
        join


        #1000;


        // ======================================
        // TEST 3 — 00
        // ======================================

        fork
            send_byte(8'h00);
            check_byte(8'h00);
        join


        #1000;


        // ======================================
        // TEST 4 — FF
        // ======================================

        fork
            send_byte(8'hFF);
            check_byte(8'hFF);
        join


        #1000;


        // ======================================
        // FINAL RESULT
        // ======================================

        $display("");
        $display("================================");
        $display("       UART RX TEST");
        $display("================================");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("================================");
        $display("");

        $finish;

    end

endmodule

`default_nettype wire