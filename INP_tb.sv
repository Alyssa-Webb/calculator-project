`timescale 1ns / 1ps
module INP_tb;
    logic clk = 0, rst;
    logic [2:0] col;
    logic [3:0] op;
    logic [3:0] row;
    logic [3:0] data;
    logic [1:0] key_type;
    logic       valid;
    logic       press_5 = 0;

    INP #(.TickCount(20), .GapCount(5), .WaitTick(4)) dut (.*);

    always #5 clk = ~clk;

    // Keypad: "5" is row[1], middle column
    assign col = (press5 && row[1]) ? 3'b010 : 3'b000;
    assign op  = 4'b0000;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, INP_tb);
        rst = 1;
        #20 rst = 0;

        #100 press5 = 1;
        @(posedge valid) #1
        #500 press5 = 0;

        #1000

        $finish;
    end
endmodule