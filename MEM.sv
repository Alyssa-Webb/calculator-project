module MEM (
    input  logic               clk,
    input  logic               rst,
    input  logic        [3:0]  data_in,       // keypad digit
    input  logic signed [10:0] result,        // from ALU
    input  logic        [1:0]  load_value,    // which register to write
    input  logic               write_enable,  // 1 = write on this clock edge

    output logic signed [10:0] Operand1,
    output logic signed [10:0] Operand2,
    output logic        [1:0]  Operator,
    output logic signed [10:0] Result
);
    always_ff @(posedge clk) begin
        if (rst) begin
            Operand1 <= '0;
            Operand2 <= '0;
            Operator <= '0;
            Result   <= '0;
        end else if (write_enable) begin
            case (load_value)
                2'b00: Operand1 <= Operand1 * 10 + data_in;
                2'b01: Operand2 <= Operand2 * 10 + data_in; 
                2'b10: Operator <= data_in[1:0];
                2'b11: Result   <= result;
            endcase
        end
    end
endmodule