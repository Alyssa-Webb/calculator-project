module DIS #( parameter int SLOT = 16 ) (
    input  logic               clk,
    input  logic               rst,
    input  logic signed [10:0] Result,          
    output logic        [3:0]  D0_AN,           
    output logic        [7:0]  D0_SEG,    
    output logic        [15:0] led
);
    assign led = {5'b0, Result};

    logic sign_res;
    logic [10:0] dis_result;
    assign sign_res = Result[10];
    assign dis_result = sign_res ? -Result : Result;


    // Timer
    logic [SLOT+1:0] count;
    logic [1:0] place;
    logic [1:0] phase;
    assign place = count[SLOT+1:SLOT];
    assign phase = count[SLOT-1:SLOT-2];

    always_ff @(posedge clk) begin
        if (rst) count <= 0;
        else     count <= count + 1;
    end

    logic [3:0] digit;
    always_comb begin
        case (place)
            2'd0: digit = dis_result % 10;              // ones
            2'd1: digit = (dis_result / 10) % 10;       // tens
            2'd2: digit = (dis_result / 100) % 10;      // hundreds
            2'd3: digit = sign_res ? 4'd10 : dis_result / 1000;  // (-) or thousands
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
            default: D0_SEG <= 8'b10111111;   // minus sign (only G on)
        endcase

        // Digit to display
        if (rst || phase == 2'd0 || phase == 2'd3)
            D0_AN <= 4'b1111;                  // all off
        else begin
            case (place)
                2'd0: D0_AN <= 4'b1110;        // rightmost digit on
                2'd1: D0_AN <= 4'b1101;
                2'd2: D0_AN <= 4'b1011;
                2'd3: D0_AN <= 4'b0111;        // leftmost digit on
            endcase
        end
    end
endmodule