`default_nettype none

module BCDtoSevenSegment
    (input logic [3:0] bcd,
    output logic [6:0] segment);

    always_comb
        case (bcd)
            4'b0000: segment = 7'b100_0000;
            4'b0001: segment = 7'b111_1001;
            4'b0010: segment = 7'b010_0100;
            4'b0011: segment = 7'b011_0000;
            4'b0100: segment = 7'b001_1001;
            4'b0101: segment = 7'b001_0010;
            4'b0110: segment = 7'b000_0010;
            4'b0111: segment = 7'b111_1000;
            4'b1000: segment = 7'b000_0000;
            4'b1001: segment = 7'b001_1000;
            default: segment = 7'b111_1111; // Display is off by default
        endcase
endmodule: BCDtoSevenSegment


module SevenSegmentDigit
    (input logic [3:0] bcd,
    output logic [6:0] segment,
    input logic blank);

    logic [3:0] input_bcd;

    BCDtoSevenSegment b2ss(.bcd(input_bcd), .segment(segment));
    // other stuff added here
    // when blank is active, none of LEDs should be glowing
    always_comb begin
        input_bcd = blank ? 4'b1111 : bcd;
    end
endmodule: SevenSegmentDigit


module BCDtoSevenSegment_test();

    logic [3:0] bcd;
    logic [6:0] segment;
    logic blank;

    SevenSegmentDigit ssdT(.bcd(bcd), .segment(segment), .blank(blank));

    initial begin
        $monitor($time,, "bcd:%b, blank:%b, segment: %b", bcd, blank, segment);
        blank = 0;
        for (bcd=4'd0; bcd < 4'd10; bcd++) begin
            #1;
        end
        blank = 1;
        for (bcd=4'd0; bcd < 4'd10; bcd++) begin
            #1;
        end
        #10 $finish;
    end
endmodule: BCDtoSevenSegment_test



module SevenSegmentControl
    (output logic [6:0] HEX9, HEX8, HEX7, HEX6,
     output logic [6:0] HEX3, HEX2, HEX1, HEX0,
     input  logic [3:0] BCD9, BCD8, BCD7, BCD6,
     input  logic [3:0] BCD3, BCD2, BCD1, BCD0,
     input  logic [7:0] turn_on);
    // want to display values on ALL 10 displays
    // wire connections to a bunch of ssd modules

    SevenSegmentDigit ssd0(.bcd(BCD0), .segment(HEX0), .blank(turn_on[0])),
                      ssd1(.bcd(BCD1), .segment(HEX1), .blank(turn_on[1])),
                      ssd2(.bcd(BCD2), .segment(HEX2), .blank(turn_on[2])),
                      ssd3(.bcd(BCD3), .segment(HEX3), .blank(turn_on[3])),
                      ssd6(.bcd(BCD6), .segment(HEX6), .blank(turn_on[4])),
                      ssd7(.bcd(BCD7), .segment(HEX7), .blank(turn_on[5])),
                      ssd8(.bcd(BCD8), .segment(HEX8), .blank(turn_on[6])),
                      ssd9(.bcd(BCD9), .segment(HEX9), .blank(turn_on[7]));
endmodule: SevenSegmentControl

