// Top level: Memory + ALU + Display on the Boolean Board.
//   sw[3:0] = key value    sw[5:4] = which register (00 Op1, 01 Op2, 10 Operator, 11 Result)
//   btn[0]  = enter        btn[3]  = reset
//   7-segment display 0 and led[10:0] = Result
module Top #(
    parameter int SLOW = 20,       // check the button every 2^SLOW clocks (~10 ms)
    parameter int SLOT = 16        // each display digit gets 2^SLOT clocks (~0.66 ms)
)(
    input  logic        clk,
    input  logic [15:0] sw,
    input  logic [3:0]  btn,
    output logic [15:0] led,
    output logic [3:0]  D0_AN,
    output logic [7:0]  D0_SEG
);
    logic signed [10:0] Operand1, Operand2, alu_result, Result;
    logic        [1:0]  Operator;

    // One write per button press: look at the button only every ~10 ms
    // (slow enough to ignore bounce) and pulse once when it goes 0 -> 1.
    logic [SLOW-1:0] timer = 0;
    logic            btn_before = 0;
    logic            write_enable = 0;

    always_ff @(posedge clk) begin
        timer        <= timer + 1;
        write_enable <= 0;
        if (timer == 0) begin
            write_enable <= btn[0] & ~btn_before;
            btn_before   <= btn[0];
        end
    end

    MEM mem (
        .clk(clk), .rst(btn[3]),
        .data_in(sw[3:0]), .load_value(sw[5:4]), .write_enable(write_enable),
        .alu_result(alu_result),
        .Operand1(Operand1), .Operand2(Operand2), .Operator(Operator), .Result(Result)
    );

    ALU alu (
        .Operand1(Operand1), .Operand2(Operand2), .Operator(Operator),
        .Result(alu_result)
    );

    Display #(.SLOT(SLOT)) display (
        .clk(clk), .rst(btn[3]),
        .Result(Result),
        .D0_AN(D0_AN), .D0_SEG(D0_SEG), .led(led)
    );
endmodule