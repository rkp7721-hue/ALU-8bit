`timescale 1ns/1ps
`default_nettype none

module alu_datapath_tb;

    // ==========================================
    // INPUTS
    // ==========================================

    reg        clk;
    reg        reset;
    reg [7:0]  A;
    reg [7:0]  B;
    reg [2:0]  OPCODE;


    // ==========================================
    // OUTPUTS
    // ==========================================

    wire [7:0] ALU_RESULT;
    wire [7:0] REGISTERED_RESULT;


    // ==========================================
    // EXPECTED RESULT
    // ==========================================

    reg [7:0] expected;


    // ==========================================
    // COUNTERS
    // ==========================================

    integer pass_count;
    integer fail_count;
    integer test_count;


    // ==========================================
    // DUT
    // ==========================================

    alu_datapath uut (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .OPCODE(OPCODE),
        .ALU_RESULT(ALU_RESULT),
        .REGISTERED_RESULT(REGISTERED_RESULT)
    );


    // ==========================================
    // CLOCK
    // ==========================================

    always #5 clk = ~clk;


    // ==========================================
    // MAIN TEST
    // ==========================================

    initial begin

        pass_count = 0;
        fail_count = 0;
        test_count = 0;

        clk      = 0;
        reset    = 0;
        A        = 8'd0;
        B        = 8'd0;
        OPCODE   = 3'b000;
        expected = 8'd0;


        // ==========================================
        // WAVEFORM
        // ==========================================

        $dumpfile("alu_datapath_waveform.vcd");
        $dumpvars(0, alu_datapath_tb);


        // ==========================================
        // STARTUP RESET TEST
        // ==========================================

        $display("");
        $display("================================");
        $display("        STARTUP RESET TEST");
        $display("================================");

        reset = 1;

        @(posedge clk);
        #1;

        test_count = test_count + 1;

        if (REGISTERED_RESULT == 8'd0) begin

            $display(
                "STARTUP RESET : PASS | REGISTERED_RESULT=%d",
                REGISTERED_RESULT
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "STARTUP RESET : FAIL | Expected=0 Actual=%d",
                REGISTERED_RESULT
            );

            fail_count = fail_count + 1;

        end


        // ==========================================
        // RELEASE RESET
        // ==========================================

        @(negedge clk);

        reset = 0;


        // ==========================================
        // ADD TEST
        // ==========================================

        A        = 8'd10;
        B        = 8'd20;
        OPCODE   = 3'b000;
        expected = 8'd30;

        @(posedge clk);
        #1;

        test_count = test_count + 1;

        if (REGISTERED_RESULT == expected) begin

            $display(
                "ADD TEST : PASS | A=%d B=%d RESULT=%d",
                A,
                B,
                REGISTERED_RESULT
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "ADD TEST : FAIL | Expected=%d Actual=%d",
                expected,
                REGISTERED_RESULT
            );

            fail_count = fail_count + 1;

        end


        // ==========================================
        // SUB TEST
        // ==========================================

        @(negedge clk);

        A        = 8'd50;
        B        = 8'd20;
        OPCODE   = 3'b001;
        expected = 8'd30;

        @(posedge clk);
        #1;

        test_count = test_count + 1;

        if (REGISTERED_RESULT == expected) begin

            $display(
                "SUB TEST : PASS | A=%d B=%d RESULT=%d",
                A,
                B,
                REGISTERED_RESULT
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "SUB TEST : FAIL | Expected=%d Actual=%d",
                expected,
                REGISTERED_RESULT
            );

            fail_count = fail_count + 1;

        end


        // ==========================================
        // AND TEST
        // ==========================================

        @(negedge clk);

        A        = 8'hF0;
        B        = 8'h0F;
        OPCODE   = 3'b010;
        expected = 8'h00;

        @(posedge clk);
        #1;

        test_count = test_count + 1;

        if (REGISTERED_RESULT == expected) begin

            $display(
                "AND TEST : PASS | A=%h B=%h RESULT=%h",
                A,
                B,
                REGISTERED_RESULT
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "AND TEST : FAIL | Expected=%h Actual=%h",
                expected,
                REGISTERED_RESULT
            );

            fail_count = fail_count + 1;

        end


        // ==========================================
        // OR TEST
        // ==========================================

        @(negedge clk);

        A        = 8'hF0;
        B        = 8'h0F;
        OPCODE   = 3'b011;
        expected = 8'hFF;

        @(posedge clk);
        #1;

        test_count = test_count + 1;

        if (REGISTERED_RESULT == expected) begin

            $display(
                "OR TEST : PASS | A=%h B=%h RESULT=%h",
                A,
                B,
                REGISTERED_RESULT
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "OR TEST : FAIL | Expected=%h Actual=%h",
                expected,
                REGISTERED_RESULT
            );

            fail_count = fail_count + 1;

        end


        // ==========================================
        // XOR TEST
        // ==========================================

        @(negedge clk);

        A        = 8'hAA;
        B        = 8'h55;
        OPCODE   = 3'b100;
        expected = 8'hFF;

        @(posedge clk);
        #1;

        test_count = test_count + 1;

        if (REGISTERED_RESULT == expected) begin

            $display(
                "XOR TEST : PASS | A=%h B=%h RESULT=%h",
                A,
                B,
                REGISTERED_RESULT
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "XOR TEST : FAIL | Expected=%h Actual=%h",
                expected,
                REGISTERED_RESULT
            );

            fail_count = fail_count + 1;

        end


        // ==========================================
        // RESET WHILE RUNNING
        // ==========================================

        $display("");
        $display("================================");
        $display("     RESET WHILE RUNNING");
        $display("================================");


        // At this point REGISTERED_RESULT should be FF
        // because of the XOR test.


        @(negedge clk);

        reset = 1;

        // Keep the data inputs unchanged.
        // Reset should override normal register loading
        // at the next rising clock edge.


        @(posedge clk);
        #1;

        test_count = test_count + 1;

        if (REGISTERED_RESULT == 8'd0) begin

            $display(
                "RUNNING RESET : PASS | REGISTERED_RESULT=%h",
                REGISTERED_RESULT
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "RUNNING RESET : FAIL | Expected=00 Actual=%h",
                REGISTERED_RESULT
            );

            fail_count = fail_count + 1;

        end


        // ==========================================
        // RELEASE RESET AGAIN
        // ==========================================

        @(negedge clk);

        reset = 0;


        // ==========================================
        // POST-RESET ADD TEST
        // ==========================================

        A        = 8'd100;
        B        = 8'd25;
        OPCODE   = 3'b000;
        expected = 8'd125;

        @(posedge clk);
        #1;

        test_count = test_count + 1;

        if (REGISTERED_RESULT == expected) begin

            $display(
                "POST-RESET ADD : PASS | A=%d B=%d RESULT=%d",
                A,
                B,
                REGISTERED_RESULT
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "POST-RESET ADD : FAIL | Expected=%d Actual=%d",
                expected,
                REGISTERED_RESULT
            );

            fail_count = fail_count + 1;

        end


        // ==========================================
        // FINAL SUMMARY
        // ==========================================

        $display("");
        $display("================================");
        $display("     RESET DATAPATH SUMMARY");
        $display("================================");

        $display(
            "TOTAL TESTS = %d",
            test_count
        );

        $display(
            "TOTAL PASS  = %d",
            pass_count
        );

        $display(
            "TOTAL FAIL  = %d",
            fail_count
        );

        $display("================================");


        // ==========================================
        // FINAL STATUS
        // ==========================================

        if (fail_count == 0) begin

            $display("");
            $display(">>> RESET DATAPATH VERIFICATION PASSED <<<");
            $display("");

        end
        else begin

            $display("");
            $display(">>> RESET DATAPATH VERIFICATION FAILED <<<");
            $display("");

        end


        $finish;

    end

endmodule

`default_nettype wire