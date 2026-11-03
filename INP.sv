// Input block
//   3x4 keypad (numbers): turn on one row at a time, read the 3 columns
//   1x4 keypad (+ - x /): read the 4 buttons directly (always on)
//   For each press: save data and key_type, and pulse valid for 1 clock
//   key_type: 00 = number   01 = operator   10 = enter (#)   11 = clear (*)
module INP #(
    parameter int TickCount = 25_000,  // clocks per row (250 us)
    parameter int GapCount  = 6_250,   // clocks the row is off at the start (62.5 us)
    parameter int WaitTick  = 40       // ticks with no key before scanning again (10 ms)
)(
    input  logic       clk,
    input  logic       rst,
    input  logic [2:0] col,        // 3x4 columns (1 = pressed)
    input  logic [3:0] op,         // 1x4 buttons: [0]=+  [1]=-  [2]=x  [3]=/
    output logic [3:0] row,        // 3x4 rows (1 = on)
    output logic [3:0] data,
    output logic [1:0] key_type,
    output logic       valid
);

    // States
    typedef enum logic [2:0] {
        ROW_1     = 3'b000,
        ROW_2     = 3'b001,
        ROW_3     = 3'b010,
        ROW_4     = 3'b011,
        KEY_FOUND = 3'b100,
        WAIT      = 3'b101
    } state_t;

    state_t state, next_state;

    logic [14:0] tick_counter;
    logic tick;
    assign tick = (tick_counter == TickCount - 1);

    always_ff @(posedge clk) begin
        if (rst || tick) tick_counter <= 0;
        else             tick_counter <= tick_counter + 1;
    end

    logic pressed;
    assign pressed = (col != 0) || (op != 0);

    logic [5:0] quiet;

    always_ff @(posedge clk) begin
        if (rst || state != WAIT) quiet <= 0;
        else if (tick && pressed)  quiet <= 0;
        else if (tick)             quiet <= quiet + 1;
    end

    // Reset to Row 1, else go to next state
    always_ff @(posedge clk) begin
        if (rst) state <= ROW_1;
        else     state <= next_state;
    end

    // Next stage logic: go to KEY_FOUND if pressed, else go to next row, else stay in WAIT until quiet enough
    always_comb begin
        next_state = state;                      // stay unless something below happens
        case (state)
            ROW_1: if (tick && pressed) next_state = KEY_FOUND;
                   else if (tick)       next_state = ROW_2;
            ROW_2: if (tick && pressed) next_state = KEY_FOUND;
                   else if (tick)       next_state = ROW_3;
            ROW_3: if (tick && pressed) next_state = KEY_FOUND;
                   else if (tick)       next_state = ROW_4;
            ROW_4: if (tick && pressed) next_state = KEY_FOUND;
                   else if (tick)       next_state = ROW_1;
            KEY_FOUND:                  next_state = WAIT;
            WAIT:  if (quiet == WaitTick) next_state = ROW_1;
            default:                    next_state = ROW_1;
        endcase
    end

    // Row Logic: turn one row high at a time, except when in KEY_FOUND or WAIT (then all low for a gap)
    always_comb begin
        case (state)
            ROW_1:   row = 4'b0001;
            ROW_2:   row = 4'b0010;
            ROW_3:   row = 4'b0100;
            ROW_4:   row = 4'b1000;
            default: row = 4'b1111;
        endcase
        if (state != KEY_FOUND && state != WAIT && tick_counter < GapCount)
            row = 4'b0000;                       // gap between rows
    end

    // Valid Bit (only high for 1 clock)
    assign valid = (state == KEY_FOUND);

    // Save Key Data and Type
    // Happens on the clock edge going into KEY_FOUND.
    always_ff @(posedge clk) begin
        if (rst) begin
            data     <= 0;
            key_type <= 0;
        end else if (next_state == KEY_FOUND) begin
            if (op != 0) begin
                key_type <= 2'b01;               // operator
                case (op)
                    4'b0001: data <= 0;          // +
                    4'b0010: data <= 1;          // -
                    4'b0100: data <= 2;          // x
                    4'b1000: data <= 3;          // /
                endcase
            end else begin
                key_type <= 2'b00;               // number (changed below for * and #)
                case ({row, col})
                    {4'b0001, 3'b001}: data <= 1;
                    {4'b0001, 3'b010}: data <= 2;
                    {4'b0001, 3'b100}: data <= 3;
                    {4'b0010, 3'b001}: data <= 4;
                    {4'b0010, 3'b010}: data <= 5;
                    {4'b0010, 3'b100}: data <= 6;
                    {4'b0100, 3'b001}: data <= 7;
                    {4'b0100, 3'b010}: data <= 8;
                    {4'b0100, 3'b100}: data <= 9;
                    {4'b1000, 3'b010}: data <= 0;
                    {4'b1000, 3'b001}: key_type <= 2'b11;   // * clear
                    {4'b1000, 3'b100}: key_type <= 2'b10;   // # enter
                endcase
            end
        end
    end
endmodule