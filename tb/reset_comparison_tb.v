`timescale 1ns/1ps
`default_nettype none

module reset_comparison_tb;

    // ==========================================
    // COMMON INPUTS
    // ==========================================

    reg       clk;
    reg       reset;
    reg [7:0] D;


    // ==========================================
    // REGISTER OUTPUTS
    // ==========================================

    wire [7:0] Q_SYNC;
    wire [7:0] Q_ASYNC;


    // ==========================================
    // SYNCHRONOUS RESET REGISTER
    // ==========================================

    register_8bit sync_register (
        .clk   (clk),
        .reset (reset),
        .D     (D),
        .Q     (Q_SYNC)
    );


    // ==========================================
    // ASYNCHRONOUS RESET REGISTER
    // ==========================================

    register_8bit_async async_register (
        .clk   (clk),
        .reset (reset),
        .D     (D),
        .Q     (Q_ASYNC)
    );


    // ==========================================
    // CLOCK
    // ==========================================

    always #5 clk = ~clk;


    // ==========================================
    // TEST
    // ==========================================

    initial begin

        $dumpfile("reset_comparison_waveform.vcd");
        $dumpvars(0, reset_comparison_tb);


        // ======================================
        // INITIAL STATE
        // ======================================

        clk   = 0;
        reset = 0;
        D     = 8'h00;


        // ======================================
        // LOAD DATA = AA
        // ======================================

        #2;

        D = 8'hAA;

        @(posedge clk);
        #1;


        // ======================================
        // ASSERT RESET BETWEEN CLOCK EDGES
        // ======================================

        #2;

        reset = 1;

        // At this point:
        //
        // Q_ASYNC should become 00 immediately.
        //
        // Q_SYNC should still contain AA
        // until the next rising clock edge.


        #1;

        $display("");
        $display("================================");
        $display(" RESET COMPARISON");
        $display("================================");

        $display(
            "RESET ASSERTED | SYNC=%h ASYNC=%h",
            Q_SYNC,
            Q_ASYNC
        );


        // ======================================
        // NEXT CLOCK EDGE
        // ======================================

        @(posedge clk);
        #1;

        $display(
            "AFTER CLOCK    | SYNC=%h ASYNC=%h",
            Q_SYNC,
            Q_ASYNC
        );


        // ======================================
        // RELEASE RESET
        // ======================================

        @(negedge clk);

        reset = 0;


        // ======================================
        // LOAD DATA = 55
        // ======================================

        D = 8'h55;

        @(posedge clk);
        #1;

        $display(
            "NORMAL OP      | SYNC=%h ASYNC=%h",
            Q_SYNC,
            Q_ASYNC
        );


        // ======================================
        // ASSERT RESET AGAIN BETWEEN EDGES
        // ======================================

        #2;

        reset = 1;

        #1;

        $display(
            "RESET AGAIN    | SYNC=%h ASYNC=%h",
            Q_SYNC,
            Q_ASYNC
        );


        // ======================================
        // NEXT CLOCK EDGE
        // ======================================

        @(posedge clk);
        #1;

        $display(
            "AFTER CLOCK    | SYNC=%h ASYNC=%h",
            Q_SYNC,
            Q_ASYNC
        );


        // ======================================
        // FINISH
        // ======================================

        $display("");
        $display("================================");
        $display(" RESET COMPARISON COMPLETE");
        $display("================================");
        $display("");

        $finish;

    end

endmodule

`default_nettype wire