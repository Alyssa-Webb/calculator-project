module ALU(
    input  [10:0] Operand1,
    input  [10:0] Operand2,
    input  [1:0]  Operator,
    output reg [10:0] Result
);

    always @(*) begin
        case (Operator)
            2'b00: Result = Operand1 + Operand2;
            2'b01: Result = Operand1 - Operand2;
            2'b10: Result = Operand1 * Operand2;
            2'b11: Result = Operand1 / Operand2;
            default: Result = 11'b0;
        endcase
    end

endmodule
