module Display #( parameter int SLOT = 16 ) (
    input  logic               clk,
    input  logic               rst,
    input  logic signed [10:0] Result,
    output logic        [3:0]  D0_AN,
    output logic        [7:0]  D0_SEG,
    output logic        [15:0] led
);

    // Moved LED lights to Display instead of Top
    assign led = {5'b0, Result};

    // Size of the number (drop the minus sign)
    logic [10:0] unsigned_result;
    assign unsigned_result = Result[10] ? -Result : Result;

    // Refresh counter: top 2 bits pick the digit, next 2 bits pick the phase
    logic [SLOT+1:0] count;
    always_ff @(posedge clk) begin
        if (rst) count <= '0;
        else     count <= count + 1;
    end

    logic [1:0] place;
    assign place = count[SLOT+1:SLOT];

    // Which number goes on the current digit (10 = minus sign)
    logic [3:0] digit;
    always_comb begin
        case (place)
            2'd0: digit = unsigned_result % 10;
            2'd1: digit = (unsigned_result / 10) % 10;
            2'd2: digit = (unsigned_result / 100) % 10;
            2'd3: digit = Result[10] ? 4'd10 : unsigned_result / 1000;
        endcase
    end

    always_ff @(posedge clk) begin
        case (digit)
            4'd0:    D0_SEG <= 8'b11000000;
            4'd1:    D0_SEG <= 8'b11111001;
            4'd2:    D0_SEG <= 8'b10100100;
            4'd3:    D0_SEG <= 8'b10110000;
            4'd4:    D0_SEG <= 8'b10011001;
            4'd5:    D0_SEG <= 8'b10010010;
            4'd6:    D0_SEG <= 8'b10000010;
            4'd7:    D0_SEG <= 8'b11111000;
            4'd8:    D0_SEG <= 8'b10000000;
            4'd9:    D0_SEG <= 8'b10010000;
            default: D0_SEG <= 8'b10111111;     // minus sign
        endcase

        if (rst || count[SLOT-1:SLOT-2] == 2'd0 || count[SLOT-1:SLOT-2] == 2'd3)
            D0_AN <= 4'b1111;
        else
            D0_AN <= ~(4'b0001 << place);
    end
endmodule