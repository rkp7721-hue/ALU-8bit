module alu (
    input  [7:0] A,
    input  [7:0] B,
    input  [2:0] OPCODE,
    output reg [7:0] RESULT
);

always @(*) begin
    case (OPCODE)
    3'b000: RESULT = A + B;
    3'b001: RESULT = A - B;
    3'b010: RESULT = A & B;
    3'b011: RESULT = A | B;
    3'b100: RESULT = A ^ B;
    default: RESULT = 8'b00000000;
endcase
end

endmodule