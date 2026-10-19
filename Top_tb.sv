`timescale 1ns / 1ps
module Top_tb;
    logic        clk = 0;
    logic [15:0] sw  = 0;
    logic [3:0]  btn = 0;
    logic [15:0] led;

    Top #(.SLOW(3)) dut (.clk(clk), .sw(sw), .btn(btn), .led(led));  // check button every 8 clocks

    always #5 clk = ~clk;

    // One button press: set the switches, hold btn[0] for a while, release
    task press(input logic [3:0] key, input logic [1:0] dest);
        sw[3:0] = key;  sw[5:4] = dest;
        btn[0] = 1;  #300  btn[0] = 0;  #200;
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, Top_tb);

        btn[3] = 1;  #30  btn[3] = 0;   // reset

        press(4'd1, 2'b00);   // Operand1 = 1
        press(4'd7, 2'b00);   // Operand1 = 17
        press(4'd3, 2'b01);   // Operand2 = 3
        press(4'd0, 2'b10);   // Operator = add
        press(4'd0, 2'b11);   // save Result

        $display("LEDs = %0d (expected 20)", $signed(led[10:0]));
        $finish;
    end
endmodule