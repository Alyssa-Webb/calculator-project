`timescale 1ns / 1ps
module ALU_tb;
    logic signed [10:0] Operand1;
    logic signed [10:0] Operand2;
    logic [1:0]  Operator;
    logic [10:0] Result;

    ALU dut (
        .Operand1(Operand1),
        .Operand2(Operand2),
        .Operator(Operator),
        .Result(Result)
    );

    initial begin
        // Test addition (00)
        Operand1 = 11'd10;
        Operand2 = 11'd5;
        Operator = 2'b00;
        #10;

        // Test subtraction (01)
        Operand1 = 11'd10;
        Operand2 = 11'd5;
        Operator = 2'b01;
        #10;

        // Test multiplication (10)
        Operand1 = 11'd10;
        Operand2 = 11'd5;
        Operator = 2'b10;
        #10;

        // Test division (11)
        Operand1 = 11'd10;
        Operand2 = 11'd5;
        Operator = 2'b11;
        #10;

        $finish;
    end
endmodule