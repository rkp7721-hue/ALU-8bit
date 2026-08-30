`timescale 1ns/1ps
`default_nettype none

module register_8bit_tb;

    reg clk;
    reg [7:0] D;
    wire [7:0] Q;


    // ==========================================
    // REGISTER INSTANCE
    // ==========================================

    register_8bit uut (
        .clk(clk),
        .D(D),
        .Q(Q)
    );


    // ==========================================
    // CLOCK GENERATION
    // ==========================================

    always #5 clk = ~clk;


    // ==========================================
    // TEST
    // ==========================================

    initial begin

        $dumpfile("register_8bit_waveform.vcd");
        $dumpvars(0, register_8bit_tb);


        clk = 0;
        D   = 8'd0;

        #10;

        D = 8'd25;

        #10;

        D = 8'd100;

        #10;

        D = 8'd255;

        #10;

        D = 8'd0;

        #10;

        $finish;

    end

endmodule

`default_nettype wire