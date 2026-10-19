module ALU(
    input  logic signed [10:0] Operand1,
    input  logic signed [10:0] Operand2,
    input  logic        [1:0]  Operator,
    output logic signed [10:0] Result
);
    always_comb begin
        case (Operator)
            2'b00: Result = Operand1 + Operand2;
            2'b01: Result = Operand1 - Operand2;
            2'b10: Result = Operand1 * Operand2;
            2'b11: Result = (Operand2 == 0) ? 11'sd0 : Operand1 / Operand2;
            default: Result = 11'sd0;
        endcase
    end
endmodule