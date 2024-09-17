`default_nettype none

module ChipInterface(
  input  logic [7:0]  KEY,
  input  logic [17:0] SW,
  input  logic        CLOCK_50,
  output logic [6:0]  HEX9, HEX8, HEX7, HEX6, HEX5, HEX3, HEX2, HEX1, HEX0,
  output logic [7:0]  LEDG);

  logic [3:0] hMove, cMove;
  logic [15:0] HHEX, CHEX;
  logic win, clock, reset, reset_N, enter, newGame;
  logic [6:0] segment0, segment1, segment2, segment3, segment4, segment5,
              segment6, segment7, segment8;
  
  logic newGame_int, newGame_sync, enter_int, enter_sync;

  assign clock = CLOCK_50;
  assign reset = SW[17];
  assign reset_N = ~reset;
  assign hMove = SW[3:0];
  assign enter = ~KEY[3];
  assign newGame = ~KEY[0];

  assign HEX5 = segment0;
  assign HEX3 = segment1;
  assign HEX2 = segment2;
  assign HEX1 = segment3;
  assign HEX0 = segment4;
  assign HEX9 = segment5;
  assign HEX8 = segment6;
  assign HEX7 = segment7;
  assign HEX6 = segment8;
  assign LEDG[7:0] = {8{win}};

  BCDtoSevenSegment BSS0 (.bcd(cMove), .segment(segment0)),
                    BSS1 (.bcd(CHEX[15:12]), .segment(segment1)),
                    BSS2 (.bcd(CHEX[11:8]), .segment(segment2)),
                    BSS3 (.bcd(CHEX[7:4]), .segment(segment3)),
                    BSS4 (.bcd(CHEX[3:0]), .segment(segment4)),
                    BSS5 (.bcd(HHEX[15:12]), .segment(segment5)),
                    BSS6 (.bcd(HHEX[11:8]), .segment(segment6)),
                    BSS7 (.bcd(HHEX[7:4]), .segment(segment7)),
                    BSS8 (.bcd(HHEX[3:0]), .segment(segment8));
  abstractFSM fsm (.hMove, .valid(enter_sync), .newGame(newGame_sync), .cMove,
                   .HHEX, .CHEX, .win, .clock, .reset_N);

  always_ff @(posedge clock)
    newGame_int <= newGame;
  
  always_ff @(posedge clock)
    newGame_sync <= newGame_int;

  always_ff @(posedge clock)
    enter_int <= enter;

  always_ff @(posedge clock)
    enter_sync <= enter_int;

endmodule: ChipInterface

module BCDtoSevenSegment
    (input logic [3:0] bcd,
    output logic [6:0] segment);

    always_comb
        case (bcd)
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