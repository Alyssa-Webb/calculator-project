`timescale 1ns / 1ps
module Top_tb;
    logic clk = 0;
    logic rst, write_enable;
    logic        [3:0]  data_in;
    logic        [1:0]  load_value;
    logic signed [10:0] Result;

    Top dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .load_value(load_value),
        .write_enable(write_enable),
        .Result(Result)
    );

    always #5 clk = ~clk;   // 10 ns clock: rising edges at 5, 15, 25, ...

    initial begin

        // temporary, so i can see the waveform using surfer 
        $dumpfile("wave.vcd");
        $dumpvars(0, Top_tb);

        // At the beginning, registers are empty "XXX"

        // Reset
        rst = 1; write_enable = 0; load_value = 2'b00; data_in = 0;
        #12 rst = 0;

        // Operand1 = 10 + 7
        data_in = 4'd1;  load_value = 2'b00;  write_enable = 1;  #10  write_enable = 0;  #10;
        data_in = 4'd7;  load_value = 2'b00;  write_enable = 1;  #10  write_enable = 0;  #10;
        
        // Operand2 = 3
        data_in = 4'd3;  load_value = 2'b01;  write_enable = 1;  #10  

        // Operator = 00 (add)
        data_in = 4'd0;  load_value = 2'b10;  write_enable = 1;  #10  

        // Store the ALU's answer in Result
        load_value = 2'b11;  write_enable = 1;  #10  write_enable = 0; #10
        $finish;
    end
endmodule