`timescale 1ns/1ps
`default_nettype none

module register_8bit_async_tb;

    // ==========================================
    // INPUTS
    // ==========================================

    reg       clk;
    reg       reset;
    reg [7:0] D;


    // ==========================================
    // OUTPUT
    // ==========================================

    wire [7:0] Q;


    // ==========================================
    // DUT
    // ==========================================

    register_8bit_async uut (
        .clk(clk),
        .reset(reset),
        .D(D),
        .Q(Q)
    );


    // ==========================================
    // CLOCK
    // ==========================================

    always #5 clk = ~clk;


    // ==========================================
    // WAVEFORM
    // ==========================================

    initial begin

        $dumpfile("register_8bit_async_waveform.vcd");
        $dumpvars(0, register_8bit_async_tb);


        // ======================================
        // INITIAL VALUES
        // ======================================

        clk   = 0;
        reset = 0;
        D     = 8'h00;


        // ======================================
        // TEST 1: NORMAL REGISTER OPERATION
        // ======================================

        #2;

        D = 8'hAA;

        @(posedge clk);
        #1;

        $display(
            "TEST 1 | D=%h Q=%h",
            D,
            Q
        );


        // ======================================
        // TEST 2: ASYNCHRONOUS RESET
        // ======================================

        #2;

        reset = 1;

        // IMPORTANT:
        // Reset is asserted between clock edges.
        // Q should become 00 immediately.

        #1;

        $display(
            "TEST 2 | RESET ASSERTED | Q=%h",
            Q
        );


        // ======================================
        // TEST 3: RELEASE RESET
        // ======================================

        #2;

        reset = 0;

        D = 8'h55;

        @(posedge clk);
        #1;

        $display(
            "TEST 3 | D=%h Q=%h",
            D,
            Q
        );


        // ======================================
        // TEST 4: RESET AGAIN BETWEEN CLOCK EDGES
        // ======================================

        #2;

        D = 8'hFF;

        reset = 1;

        // Again, reset is asserted between
        // clock edges.

        #1;

        $display(
            "TEST 4 | RESET ASSERTED | Q=%h",
            Q
        );


        // ======================================
        // RELEASE RESET
        // ======================================

        #2;

        reset = 0;

        D = 8'h3C;

        @(posedge clk);
        #1;

        $display(
            "TEST 5 | D=%h Q=%h",
            D,
            Q
        );


        // ======================================
        // FINISH
        // ======================================

        $display("");
        $display("================================");
        $display(" ASYNCHRONOUS RESET TEST DONE");
        $display("================================");
        $display("");

        $finish;

    end

endmodule

`default_nettype wire