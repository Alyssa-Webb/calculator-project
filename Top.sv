// Top level: Keypad + Memory + ALU + Display on the Boolean Board.
//   7-segment display 0 and led[10:0] = Result
//   btn[3] = reset
//
// Switches (same as Lab 10):
//   sw[3:0] = key value    sw[5:4] = which register (00 Op1, 01 Op2, 10 Operator, 11 Result)
//   btn[0]  = enter
//
// Keypad:
//   3x4 keypad (Pmod A) = digits, # = equals, * = clear
//   1x4 keypad (Pmod B) = + - x /
//   digits go to Operand1 until an operator is pressed, then to Operand2
//   operator key  -> stores the Operator
//   #             -> stores the Result
//   *             -> clears everything (press * before starting a new calculation)
module Top #(
    parameter int SLOW = 20,       // check btn[0] every 2^SLOW clocks (~10 ms)
    parameter int SLOT = 16        // each display digit gets 2^SLOT clocks (~0.66 ms)
)(
    input  logic        clk,
    input  logic [15:0] sw,        // sw[3:0] = value, sw[5:4] = operand/operator
    input  logic [3:0]  btn,       // btn[0] = enter, btn[3] = reset
    output logic [15:0] led,
    output logic [3:0]  D0_AN,
    output logic [7:0]  D0_SEG,
    output logic [3:0]  row,       // 3x4 keypad rows    (Pmod A)
    input  logic [2:0]  col,       // 3x4 keypad columns (Pmod A)
    input  logic [3:0]  op         // 1x4 keypad buttons (Pmod B)
);
    logic signed [10:0] Operand1, Operand2, alu_result, Result;
    logic        [1:0]  Operator;

    // ---------------- Switches + btn[0] ----------------
    logic [SLOW-1:0] timer = 0;
    logic            btn_before = 0;
    logic            btn_write = 0;

    always_ff @(posedge clk) begin
        timer     <= timer + 1;
        btn_write <= 0;
        if (timer == 0) begin
            btn_write  <= btn[0] & ~btn_before;
            btn_before <= btn[0];
        end
    end

    // ---------------- Keypad ----------------
    logic [3:0] key_data;
    logic [1:0] key_type;
    logic       key_valid;

    INP inp (
        .clk(clk), .rst(btn[3]),
        .col(col), .op(op), .row(row),
        .data(key_data), .key_type(key_type), .valid(key_valid)
    );

    // key_type values from INP
    typedef enum logic [1:0] {
        NUMBER   = 2'b00,
        OPERATOR = 2'b01,
        ENTER    = 2'b10,   // #
        CLEAR    = 2'b11    // *
    } key_t;

    // second_number = 1 after an operator is pressed, so digits go to Operand2
    logic second_number;
    logic clear;
    assign clear = key_valid && (key_type == CLEAR);

    always_ff @(posedge clk) begin
        if (btn[3] || clear)
            second_number <= 0;
        else if (key_valid) begin
            case (key_type)
                OPERATOR: second_number <= 1;   // next digits are Operand2
                ENTER:    second_number <= 0;   // back to Operand1 (press * to start fresh)
                default:  second_number <= second_number;
            endcase
        end
    end

    // Which register the key goes to (00 Op1, 01 Op2, 10 Operator, 11 Result)
    logic [1:0] key_load;
    logic       key_write;

    always_comb begin
        case (key_type)
            NUMBER:   key_load = second_number ? 2'b01 : 2'b00;
            OPERATOR: key_load = 2'b10;
            ENTER:    key_load = 2'b11;
            default:  key_load = 2'b00;        // CLEAR does not write
        endcase
    end

    assign key_write = key_valid && (key_type != CLEAR);

    // ---------------- Pick the input that is writing ----------------
    // Keypad press -> keypad value and register
    // btn[0] press -> switch value and register
    logic [3:0] data_in;
    logic [1:0] load_value;
    logic       write_enable;

    assign data_in      = key_write ? key_data : sw[3:0];
    assign load_value   = key_write ? key_load : sw[5:4];
    assign write_enable = key_write || btn_write;

    // ---------------- Calculator blocks ----------------
    MEM mem (
        .clk(clk), .rst(btn[3] || clear),
        .data_in(data_in), .load_value(load_value), .write_enable(write_enable),
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
