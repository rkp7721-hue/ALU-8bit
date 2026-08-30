`timescale 1ns/1ps
`default_nettype none

module baud_tick_gen_tb;

    reg clk;
    reg reset;

    wire bit_tick;

    integer tick_count;


    // ==========================================
    // DUT
    // ==========================================

    baud_tick_gen #(
        .CLK_FREQ  (50_000_000),
        .BAUD_RATE (9600)
    ) dut (
        .clk      (clk),
        .reset    (reset),
        .bit_tick (bit_tick)
    );


    // ==========================================
    // 50 MHz CLOCK
    // ==========================================

    always #10 clk = ~clk;


    // ==========================================
    // MONITOR TICKS
    // ==========================================

    always @(posedge clk) begin

        if (bit_tick) begin

            tick_count = tick_count + 1;

            $display(
                "BIT TICK %0d at time %0t ns",
                tick_count,
                $time
            );

        end

    end


    // ==========================================
    // TEST
    // ==========================================

    initial begin

        $dumpfile("baud_tick_waveform.vcd");
        $dumpvars(0, baud_tick_gen_tb);

        clk       = 1'b0;
        reset     = 1'b1;
        tick_count = 0;

        // Reset
        #100;

        reset = 1'b0;

        // Run long enough to observe several ticks
        #2_000_000;

        $display("");
        $display("==============================");
        $display("   BAUD TICK GENERATOR TEST");
        $display("==============================");
        $display("TOTAL TICKS = %0d", tick_count);
        $display("==============================");
        $display("");

        $finish;

    end

endmodule

`default_nettype wire