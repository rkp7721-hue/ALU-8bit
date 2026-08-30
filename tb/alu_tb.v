`timescale 1ns/1ps
`default_nettype none

module alu_tb;

    // ==========================================
    // ALU INPUTS
    // ==========================================

    reg [7:0] A;
    reg [7:0] B;
    reg [2:0] OPCODE;


    // ==========================================
    // ALU OUTPUT
    // ==========================================

    wire [7:0] RESULT;


    // ==========================================
    // EXPECTED RESULT
    // ==========================================

    reg [7:0] expected;


    // ==========================================
    // COUNTERS
    // ==========================================

    integer pass_count;
    integer fail_count;
    integer i;

    integer add_count;
    integer sub_count;
    integer and_count;
    integer or_count;
    integer xor_count;

    integer random_test_count;


    // ==========================================
    // ALU INSTANCE
    // ==========================================

    alu uut (
        .A(A),
        .B(B),
        .OPCODE(OPCODE),
        .RESULT(RESULT)
    );


    // ==========================================
    // TEST TASK
    // ==========================================

    task check_result;

        input [7:0] test_A;
        input [7:0] test_B;
        input [2:0] test_OPCODE;
        input [7:0] test_expected;

        begin

            A = test_A;
            B = test_B;
            OPCODE = test_OPCODE;

            expected = test_expected;

            #10;

            if (RESULT == expected) begin

                $display(
                    "PASS | A=%d B=%d OPCODE=%b RESULT=%d",
                    A,
                    B,
                    OPCODE,
                    RESULT
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "FAIL | A=%d B=%d OPCODE=%b Expected=%d Actual=%d",
                    A,
                    B,
                    OPCODE,
                    expected,
                    RESULT
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // ==========================================
    // MAIN TESTBENCH
    // ==========================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        add_count = 0;
        sub_count = 0;
        and_count = 0;
        or_count  = 0;
        xor_count = 0;

        random_test_count = 1000;


        // ==========================================
        // WAVEFORM
        // ==========================================

        $dumpfile("alu_waveform.vcd");
        $dumpvars(0, alu_tb);


        // ==========================================
        // DIRECTED EDGE-CASE TESTS
        // ==========================================

        $display("");
        $display("================================");
        $display("     DIRECTED EDGE TESTS");
        $display("================================");


        // ADD: 0 + 0
        check_result(
            8'd0,
            8'd0,
            3'b000,
            8'd0
        );


        // ADD overflow: 255 + 1
        check_result(
            8'd255,
            8'd1,
            3'b000,
            8'd0
        );


        // AND: 255 & 255
        check_result(
            8'd255,
            8'd255,
            3'b010,
            8'd255
        );


        // AND: 0 & 255
        check_result(
            8'd0,
            8'd255,
            3'b010,
            8'd0
        );


        // OR: 0 | 255
        check_result(
            8'd0,
            8'd255,
            3'b011,
            8'd255
        );


        // XOR: 255 ^ 0
        check_result(
            8'd255,
            8'd0,
            3'b100,
            8'd255
        );


        // SUB underflow: 5 - 10
        check_result(
            8'd5,
            8'd10,
            3'b001,
            8'd251
        );


        // SUB: 255 - 255
        check_result(
            8'd255,
            8'd255,
            3'b001,
            8'd0
        );


        // ==========================================
        // INVALID OPCODE TESTS
        // ==========================================

        $display("");
        $display("================================");
        $display("      INVALID OPCODE TESTS");
        $display("================================");


        // OPCODE 101
        check_result(
            8'd170,
            8'd85,
            3'b101,
            8'd0
        );


        // OPCODE 110
        check_result(
            8'd255,
            8'd255,
            3'b110,
            8'd0
        );


        // OPCODE 111
        check_result(
            8'd123,
            8'd231,
            3'b111,
            8'd0
        );


        // ==========================================
        // RANDOM TESTS
        // ==========================================

        $display("");
        $display("================================");
        $display("       RANDOM TESTS");
        $display("================================");


        for (i = 0; i < random_test_count; i = i + 1) begin

            // Random inputs
            A = $random;
            B = $random;

            // Valid random opcode: 0 to 4
            OPCODE = $urandom_range(0, 4);


            // ======================================
            // COUNT OPERATION
            // ======================================

            case (OPCODE)

                3'b000:
                    add_count = add_count + 1;

                3'b001:
                    sub_count = sub_count + 1;

                3'b010:
                    and_count = and_count + 1;

                3'b011:
                    or_count = or_count + 1;

                3'b100:
                    xor_count = xor_count + 1;

            endcase


            // ======================================
            // EXPECTED RESULT
            // ======================================

            case (OPCODE)

                3'b000:
                    expected = A + B;

                3'b001:
                    expected = A - B;

                3'b010:
                    expected = A & B;

                3'b011:
                    expected = A | B;

                3'b100:
                    expected = A ^ B;

                default:
                    expected = 8'd0;

            endcase


            #10;


            // ======================================
            // CHECK RESULT
            // ======================================

            if (RESULT == expected) begin

                $display(
                    "RANDOM TEST %0d : PASS | A=%d B=%d OPCODE=%b RESULT=%d",
                    i + 1,
                    A,
                    B,
                    OPCODE,
                    RESULT
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "RANDOM TEST %0d : FAIL | A=%d B=%d OPCODE=%b Expected=%d Actual=%d",
                    i + 1,
                    A,
                    B,
                    OPCODE,
                    expected,
                    RESULT
                );

                fail_count = fail_count + 1;

            end

        end


        // ==========================================
        // FINAL SUMMARY
        // ==========================================

        $display("");
        $display("================================");
        $display("       VERIFICATION SUMMARY");
        $display("================================");

        $display(
            "ADD RANDOM TESTS = %d",
            add_count
        );

        $display(
            "SUB RANDOM TESTS = %d",
            sub_count
        );

        $display(
            "AND RANDOM TESTS = %d",
            and_count
        );

        $display(
            "OR  RANDOM TESTS = %d",
            or_count
        );

        $display(
            "XOR RANDOM TESTS = %d",
            xor_count
        );

        $display("--------------------------------");

        $display(
            "DIRECTED TESTS    = 8"
        );

        $display(
            "INVALID OPCODES   = 3"
        );

        $display(
            "RANDOM TESTS      = %d",
            random_test_count
        );

        $display(
            "TOTAL TESTS       = %d",
            pass_count + fail_count
        );

        $display(
            "TOTAL PASS        = %d",
            pass_count
        );

        $display(
            "TOTAL FAIL        = %d",
            fail_count
        );

        $display("================================");


        // ==========================================
        // FINAL STATUS
        // ==========================================

        if (fail_count == 0) begin

            $display("");
            $display(">>> ALU VERIFICATION PASSED <<<");
            $display("");

        end
        else begin

            $display("");
            $display(">>> ALU VERIFICATION FAILED <<<");
            $display("");

        end


        $finish;

    end

endmodule