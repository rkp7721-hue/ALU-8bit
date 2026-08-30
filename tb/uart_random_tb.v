`timescale 1ns/1ps
`default_nettype none

module uart_random_tb;

    reg       clk;
    reg       reset;

    reg       tx_start;
    reg [7:0] tx_data;

    wire       tx;
    wire       tx_busy;
    wire       tx_done;

    wire [7:0] rx_data;
    wire       rx_done;
    wire       rx_busy;

    integer pass_count;
    integer fail_count;
    integer test_count;
    integer i;
    integer timeout_count;

    reg [7:0] test_data;


    // ==========================================
    // UART TOP DUT
    // ==========================================

    uart_top #(
        .CLK_FREQ  (50_000_000),
        .BAUD_RATE (9600)
    ) dut (
        .clk      (clk),
        .reset    (reset),

        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (tx),
        .tx_busy  (tx_busy),
        .tx_done  (tx_done),

        .rx       (tx),
        .rx_data  (rx_data),
        .rx_done  (rx_done),
        .rx_busy  (rx_busy)
    );


    // ==========================================
    // 50 MHz CLOCK
    // ==========================================

    always #10 clk = ~clk;


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
    // CHECK BYTE WITH TIMEOUT
    // ==========================================

    task check_byte;
        input [7:0] expected;

        begin

            timeout_count = 0;

            while ((rx_done == 1'b0) && (timeout_count < 70000)) begin

                @(posedge clk);

                #1;

                timeout_count = timeout_count + 1;

            end


            // ==================================
            // TEST RESULT
            // ==================================

            test_count = test_count + 1;


            if (rx_done == 1'b1) begin

                if (rx_data == expected) begin

                    pass_count = pass_count + 1;

                    $display(
                        "PASS %0d: TX=%02h RX=%02h",
                        test_count,
                        expected,
                        rx_data
                    );

                end

                else begin

                    fail_count = fail_count + 1;

                    $display(
                        "FAIL %0d: TX=%02h RX=%02h",
                        test_count,
                        expected,
                        rx_data
                    );

                end

            end

            else begin

                fail_count = fail_count + 1;

                $display(
                    "TIMEOUT %0d: TX=%02h RX_DONE did not arrive",
                    test_count,
                    expected
                );

            end

        end

    endtask


    // ==========================================
    // MAIN TEST
    // ==========================================

    initial begin

        $dumpfile("uart_random_waveform.vcd");
        $dumpvars(0, uart_random_tb);

        clk        = 1'b0;
        reset      = 1'b1;

        tx_start   = 1'b0;
        tx_data    = 8'h00;

        pass_count = 0;
        fail_count = 0;
        test_count = 0;
        timeout_count = 0;

        test_data = 8'h00;
        i = 0;


        // ======================================
        // RESET
        // ======================================

        #100;

        reset = 1'b0;

        #100;


        // ======================================
        // FIXED EDGE CASES
        // ======================================

        fork
            send_byte(8'h00);
            check_byte(8'h00);
        join

        #1000;


        fork
            send_byte(8'hFF);
            check_byte(8'hFF);
        join

        #1000;


        fork
            send_byte(8'hA5);
            check_byte(8'hA5);
        join

        #1000;


        fork
            send_byte(8'h55);
            check_byte(8'h55);
        join

        #1000;


        // ======================================
        // RANDOM TESTS
        // ======================================

        for (i = 0; i < 96; i = i + 1) begin

            test_data = $random;

            fork
                send_byte(test_data);
                check_byte(test_data);
            join

            #1000;

        end


        // ======================================
        // FINAL RESULT
        // ======================================

        $display("");
        $display("================================");
        $display("     UART RANDOM TEST");
        $display("================================");
        $display("TOTAL TESTS = %0d", test_count);
        $display("TOTAL PASS  = %0d", pass_count);
        $display("TOTAL FAIL  = %0d", fail_count);
        $display("================================");
        $display("");

        if ((pass_count == 100) && (fail_count == 0)) begin

            $display("STATUS: PASS");

        end

        else begin

            $display("STATUS: FAIL");

        end

        $display("");

        $finish;

    end

endmodule

`default_nettype wire