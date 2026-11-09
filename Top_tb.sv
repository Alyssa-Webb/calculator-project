`timescale 1ns / 1ps
module Top_tb;
    logic        clk = 0;
    logic [15:0] sw  = 0;
    logic [3:0]  btn = 0;
    logic [15:0] led;
    logic [3:0]  D0_AN;
    logic [7:0]  D0_SEG;
    logic [3:0]  row;
    logic [2:0]  col;
    logic [3:0]  op  = 0;
    logic [3:0]  key_row = 0;   // which 3x4 row the pressed key is in
    logic [2:0]  key_col = 0;   // which 3x4 column the pressed key is in

    Top #(.SLOW(3), .SLOT(2)) dut (.*);

    // Short keypad timing so the simulation is fast
    defparam dut.inp.TickCount = 20;
    defparam dut.inp.GapCount  = 5;
    defparam dut.inp.WaitTick  = 4;

    always #5 clk = ~clk;

    // Pretend 3x4 keypad: the column reads 1 only when the key's row is on
    assign col = (row & key_row) ? key_col : 3'b000;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, Top_tb);

        // Reset
        btn[3] = 1;  #30  btn[3] = 0;

        // --- Keypad: 17 + 3 = 20

        // Press 1 (row 1, left column)
        key_row = 4'b0001;  key_col = 3'b001;  #2000; // press key
        key_row = 4'b0000;  key_col = 3'b000;  #2000; // release key

        // Press 7 (row 3, left column)
        key_row = 4'b0100;  key_col = 3'b001;  #2000;
        key_row = 4'b0000;  key_col = 3'b000;  #2000;

        // Press + (1x4 button 1)
        op = 4'b0001;  #2000;
        op = 4'b0000;  #2000;

        // Press 3 (row 1, right column)
        key_row = 4'b0001;  key_col = 3'b100;  #2000;
        key_row = 4'b0000;  key_col = 3'b000;  #2000;

        // Press # (row 4, right column)
        key_row = 4'b1000;  key_col = 3'b100;  #2000;
        key_row = 4'b0000;  key_col = 3'b000;  #2000;

        // Press * to clear (row 4, left column)
        key_row = 4'b1000;  key_col = 3'b001;  #2000;
        key_row = 4'b0000;  key_col = 3'b000;  #2000;

        // --- Switches: 3 - 6 = -3 

        // Operand1 = 3
        sw[5:4] = 2'b00;  sw[3:0] = 4'd3;
        btn[0] = 1;  #300  btn[0] = 0;  #200;

        // Operand2 = 6
        sw[5:4] = 2'b01;  sw[3:0] = 4'd6;
        btn[0] = 1;  #300  btn[0] = 0;  #200;

        // Operator = - (01)
        sw[5:4] = 2'b10;  sw[3:0] = 4'd1;
        btn[0] = 1;  #300  btn[0] = 0;  #200;

        // Save Result
        sw[5:4] = 2'b11;
        btn[0] = 1;  #300  btn[0] = 0;  #200;

        $finish;
    end
endmodule
