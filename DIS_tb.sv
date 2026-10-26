`timescale 1ns / 1ps
module DIS_tb;
    logic clk = 0, rst;
    logic signed [10:0] Result;
    logic [3:0]  D0_AN;
    logic [7:0]  D0_SEG;
    logic [15:0] led;

    Display #(.SLOT(2)) dut (.*);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, Display_simple_tb);
        rst = 1; Result = 1;
        #20 rst = 0;

        #1000

        $finish;
    end
endmodule




