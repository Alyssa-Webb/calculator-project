`timescale 1ns / 1ps
module MEM_tb;
    logic clk = 0;
    logic rst, write_enable;
    logic        [3:0]  data_in;
    logic signed [10:0] alu_result;
    logic        [1:0]  load_value;
    logic signed [10:0] Operand1, Operand2, Result;
    logic        [1:0]  Operator;

    MEM dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .alu_result(alu_result),
        .load_value(load_value),
        .write_enable(write_enable),
        .Operand1(Operand1),
        .Operand2(Operand2),
        .Operator(Operator),
        .Result(Result)
    );

    always #5 clk = ~clk;   // 10 ns clock: rising edges at 5, 15, 25, ...

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, MEM_tb);

        // Reset
        rst = 1; write_enable = 0; load_value = 2'b00;
        data_in = 0; alu_result = 0;
        #12 rst = 0;

        // Load Operand1: press key 7 with load_value = 00
        data_in = 4'd7;  load_value = 2'b00;  write_enable = 1;  #10  write_enable = 0;

        // Reset
        rst = 1;  #10  rst = 0;

        $finish;
    end
endmodule