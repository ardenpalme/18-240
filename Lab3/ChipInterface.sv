`default_nettype none

module ChipInterface
    (output logic [ 6:0] HEX9, HEX7, HEX6,
    output logic [17:0] LEDR,
    output logic [ 7:0] LEDG,
    input logic [17:0] SW,
    input logic [ 7:0] KEY);

    logic hit, nearmiss, miss, notOk;
    logic [6:0] sevenSegout;

    Battleship b(.X(SW[7:4]), .Y(SW[3:0]), .ScoreThis(~KEY[4]), .Big(SW[17]), .BigLeft(SW[15:14]), .Hit(hit), .Miss(miss), .NearMiss(nearmiss), .NumHits(sevenSegout), .BiggestShipHit(LEDG[4:0]), .SomethingIsWrong(notOk));

    /* Hit */
    logic [5:0] tmp2;
    assign tmp2= (hit) ? 6'b11_1111 : 6'b00_0000;

    /* Miss */
    logic [5:0] tmp3;
    assign tmp3= (miss) ? 6'b11_1111 : 6'b00_0000;

    /* Near Miss */
    logic [5:0] tmp4;
    assign tmp4= (nearmiss) ? 6'b11_1111 : 6'b00_0000;

    assign LEDR[5:0]= tmp3; //miss
    assign LEDR[11:6]= tmp4; //nearmiss
    assign LEDR[17:12]= tmp2; //hit

    /* NumHits */
    logic [3:0] tmp;
    assign tmp= {sevenSegout[3], sevenSegout[2], sevenSegout[1], sevenSegout[0]};
    SevenSegmentDigit H9(.bcd(tmp), .segment(HEX9), .blank(KEY[4]));

    /* SomethingisWrong */
    logic tmp1;
    SevenSegmentDigit H7(.bcd(4'd8), .segment(HEX7), .blank(tmp1));
    SevenSegmentDigit H6(.bcd(4'd8), .segment(HEX6), .blank(tmp1));

    always_comb begin
        if(notOk) tmp1= 1'b0;
        else tmp1= 1'b1;
    end

endmodule : ChipInterface
