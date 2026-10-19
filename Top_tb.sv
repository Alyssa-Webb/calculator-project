`timescale 1ns / 1ps
module Top_tb;
    logic        clk = 0;
    logic [15:0] sw  = 0;
    logic [3:0]  btn = 0;
    logic [15:0] led;

    // Short debounce (4 clocks) so the simulation doesn't take millions of cycles
    Top #(.DEBOUNCE(4)) dut (
        .clk(clk),
        .sw(sw),
        .btn(btn),
        .led(led)
    );

    always #5 clk = ~clk;   // 10 ns clock

    // Press btn[0] like a person: it bounces, then is held for many clocks
    task press(input logic [3:0] key, input logic [1:0] dest);
        sw[3:0] = key;  sw[5:4] = dest;
        btn[0] = 1;  #7  btn[0] = 0;  #6  btn[0] = 1;   // bounce
        #300  btn[0] = 0;                               // hold 30 clocks, release
        #200;
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, Top_tb);

        // Reset with btn[3]
        btn[3] = 1;  #30  btn[3] = 0;  #20;

        press(4'd1, 2'b00);   // Operand1: 1
        press(4'd7, 2'b00);   // Operand1: 17
        press(4'd3, 2'b01);   // Operand2: 3
        press(4'd0, 2'b10);   // Operator: add
        press(4'd0, 2'b11);   // store Result

        $finish;
    end
endmodule