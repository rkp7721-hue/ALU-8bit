`timescale 1ns/1ps
`default_nettype none

module baud_generator_tb;

    reg clk;
    reg reset;

    wire baud_tick;


    // ==========================================
    // DUT
    // ==========================================

    baud_generator #(
        .CLK_FREQ  (50_000_000),
        .BAUD_RATE (9_600)
    ) uut (
        .clk       (clk),
        .reset     (reset),
        .baud_tick (baud_tick)
    );


    // ==========================================
    // CLOCK
    // ==========================================

    always #10 clk = ~clk;


    // ==========================================
    // TEST
    // ==========================================

    initial begin

        $dumpfile("baud_generator_waveform.vcd");
        $dumpvars(0, baud_generator_tb);


        clk   = 1'b0;
        reset = 1'b1;


        // Reset
        #100;

        reset = 1'b0;


        // Run long enough to observe
        // several baud ticks.
        #1_100_000;


        $display("");
        $display("================================");
        $display("   BAUD GENERATOR TEST COMPLETE");
        $display("================================");
        $display("");

        $finish;

    end

endmodule

`default_nettype wire