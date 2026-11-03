// Top level: Keypad + Memory + ALU + Display on the Boolean Board.
//   keypad    = key value (replaces sw[3:0]), each press writes (replaces btn[0])
//   sw[5:4]   = which register (00 Op1, 01 Op2, 10 Operator, 11 Result)
//   btn[3]    = reset
//   7-segment display 0 and led[10:0] = Result
module Top #(
    // parameter int SLOW = 20,    // OLD: check the button every 2^SLOW clocks (~10 ms)
    parameter int SLOT = 16        // each display digit gets 2^SLOT clocks (~0.66 ms)
)(
    input  logic        clk,
    input  logic [15:0] sw,
    input  logic [3:0]  btn,
    output logic [15:0] led,
    output logic [3:0]  D0_AN,
    output logic [7:0]  D0_SEG,
    output logic [3:0]  row,       // NEW: 3x4 keypad rows    (PMOD A)
    input  logic [2:0]  col,       // NEW: 3x4 keypad columns (PMOD A)
    input  logic [3:0]  op         // NEW: 1x4 keypad buttons (PMOD B)
);
    logic signed [10:0] Operand1, Operand2, alu_result, Result;
    logic        [1:0]  Operator;

    // OLD: one write per button press
    // logic [SLOW-1:0] timer = 0;
    // logic            btn_before = 0;
    // logic            write_enable = 0;
    //
    // always_ff @(posedge clk) begin
    //     timer        <= timer + 1;
    //     write_enable <= 0;
    //     if (timer == 0) begin
    //         write_enable <= btn[0] & ~btn_before;
    //         btn_before   <= btn[0];
    //     end
    // end

    // NEW: the keypad gives the value and one write per key press
    logic [3:0] key_data;
    logic [1:0] key_type;
    logic       key_valid;

    INP inp (
        .clk(clk), .rst(btn[3]),
        .col(col), .op(op), .row(row),
        .data(key_data), .key_type(key_type), .valid(key_valid)
    );

    MEM mem (
        .clk(clk), .rst(btn[3]),
        // .data_in(sw[3:0]), .load_value(sw[5:4]), .write_enable(write_enable),   // OLD
        .data_in(key_data), .load_value(sw[5:4]), .write_enable(key_valid),        // NEW
        .alu_result(alu_result),
        .Operand1(Operand1), .Operand2(Operand2), .Operator(Operator), .Result(Result)
    );

    ALU alu (
        .Operand1(Operand1), .Operand2(Operand2), .Operator(Operator),
        .Result(alu_result)
    );

    DIS #(.SLOT(SLOT)) display (
        .clk(clk), .rst(btn[3]),
        .Result(Result),
        .D0_AN(D0_AN), .D0_SEG(D0_SEG), .led(led)
    );
endmodule
