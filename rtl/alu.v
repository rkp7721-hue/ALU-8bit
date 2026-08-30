`timescale 1ns/1ps
`default_nettype none

module alu (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [2:0] OPCODE,
    output reg  [7:0] RESULT
);

    // ==========================================
    // OPCODE DEFINITIONS
    // ==========================================

    localparam [2:0] OP_ADD = 3'b000;
    localparam [2:0] OP_SUB = 3'b001;
    localparam [2:0] OP_AND = 3'b010;
    localparam [2:0] OP_OR  = 3'b011;
    localparam [2:0] OP_XOR = 3'b100;


    // ==========================================
    // COMBINATIONAL ALU LOGIC
    // ==========================================

    always @(*) begin

        // Safe default value
        RESULT = 8'b0;

        case (OPCODE)

            OP_ADD: begin
                RESULT = A + B;
            end

            OP_SUB: begin
                RESULT = A - B;
            end

            OP_AND: begin
                RESULT = A & B;
            end

            OP_OR: begin
                RESULT = A | B;
            end

            OP_XOR: begin
                RESULT = A ^ B;
            end

            default: begin
                RESULT = 8'b0;
            end

        endcase

    end

endmodule

`default_nettype wire