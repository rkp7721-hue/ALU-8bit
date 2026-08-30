`timescale 1ns/1ps
`default_nettype none

module uart_tx_tb;

    // ==========================================
    // INPUTS
    // ==========================================

    reg       clk;
    reg       reset;
    reg       tx_start;
    reg [7:0] tx_data;
    reg       bit_tick;


    // ==========================================
    // OUTPUTS
    // ==========================================

    wire tx;
    wire tx_busy;
    wire tx_done;


    // ==========================================
    // DUT
    // ==========================================

    uart_tx uut (
        .clk      (clk),
        .reset    (reset),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .bit_tick (bit_tick),
        .tx        (tx),
        .tx_busy  (tx_busy),
        .tx_done   (tx_done)
    );


    // ==========================================
    // SYSTEM CLOCK
    // ==========================================

    always #5 clk = ~clk;


    // ==========================================
    // TEST
    // ==========================================

    initial begin

        $dumpfile("uart_tx_waveform.vcd");
        $dumpvars(0, uart_tx_tb);


        // ======================================
        // INITIAL STATE
        // ======================================

        clk      = 1'b0;
        reset    = 1'b1;
        tx_start = 1'b0;
        tx_data  = 8'h00;
        bit_tick = 1'b0;


        // ======================================
        // RESET
        // ======================================

        #12;

        reset = 1'b0;


        // ======================================
        // LOAD DATA
        // ======================================

        tx_data = 8'b1010_0101;


        // ======================================
        // START TRANSMISSION
        // ======================================

        tx_start = 1'b1;

        @(posedge clk);

        #1;

        tx_start = 1'b0;


        // ======================================
        // START BIT
        // ======================================

        // Generate one bit tick at a clock edge

        repeat (1) begin

            @(negedge clk);
            bit_tick = 1'b1;

            @(posedge clk);
            #1;

            bit_tick = 1'b0;

        end


        // ======================================
        // DATA BITS
        // ======================================

        repeat (8) begin

            @(negedge clk);
            bit_tick = 1'b1;

            @(posedge clk);
            #1;

            bit_tick = 1'b0;

        end


        // ======================================
        // STOP BIT
        // ======================================

        @(negedge clk);
        bit_tick = 1'b1;

        @(posedge clk);
        #1;

        bit_tick = 1'b0;


        // ======================================
        // WAIT
        // ======================================

        #20;


        // ======================================
        // FINISH
        // ======================================

        $display("");
        $display("================================");
        $display("       UART TX TEST COMPLETE");
        $display("================================");
        $display("");

        $finish;

    end

endmodule

`default_nettype wire