module Top (
    input  logic               clk,
    input  logic               rst,
    input  logic        [3:0]  data_in,       // keypad digit
    input  logic        [1:0]  load_value,    // which register to write
    input  logic               write_enable,  // 1 = write on this clock edge
    output logic signed [10:0] Result         // stored answer (to display)
);
    // Wires between the two blocks
    logic signed [10:0] Operand1, Operand2;
    logic        [1:0]  Operator;
    logic signed [10:0] alu_out;              

    MEM mem (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .result(alu_out),                    
        .load_value(load_value),
        .write_enable(write_enable),
        .Operand1(Operand1),
        .Operand2(Operand2),
        .Operator(Operator),
        .Result(Result)
    );

    ALU alu (
        .Operand1(Operand1),
        .Operand2(Operand2),
        .Operator(Operator),
        .Result(alu_out)
    );
endmodule