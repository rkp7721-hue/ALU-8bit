`timescale 1ns/1ps
`default_nettype none

module alu_datapath (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [2:0] OPCODE,

    output wire [7:0] ALU_RESULT,
    output wire [7:0] REGISTERED_RESULT
);

    // ==========================================
    // ALU OUTPUT
    // ==========================================

    wire [7:0] alu_output;


    // ==========================================
    // ALU INSTANCE
    // ==========================================

    alu alu_instance (
        .A(A),
        .B(B),
        .OPCODE(OPCODE),
        .RESULT(alu_output)
    );


    // ==========================================
    // 8-BIT REGISTER
    // ==========================================

    register_8bit register_instance (
        .clk(clk),
        .reset(reset),
        .D(alu_output),
        .Q(REGISTERED_RESULT)
    );


    // ==========================================
    // DIRECT ALU OUTPUT
    // ==========================================

    assign ALU_RESULT = alu_output;


endmodule

`default_nettype wire