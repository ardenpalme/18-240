`default_nettype none

module Task2
  (input logic start_game, grade_it,
   input logic [11:0] guess,
   output logic [2:0] feedback0, feedback1, feedback2, feedback3,
   output logic [3:0] round_number,
   output logic won, lost,
   input  logic clock, reset);

  logic [11:0] pattern;
  assign pattern= 12'o0501;

  logic tenthRound, load, preWon, ready;
  fsm control(.*);

  logic [2:0] red, white;
  Grader scoreThis(.guess0(guess[2:0]), .guess1(guess[5:3]),
                   .guess2(guess[8:6]), .guess3(guess[11:9]),
                   .pattern0(pattern[2:0]), .pattern1(pattern[5:3]),
                   .pattern2(pattern[8:6]), .pattern3(pattern[11:9]),
                   .red(red), .white(white));

  logic [4:0] redVal, whiteVal;
  calcFeedback feedback(.*);

  assign lost = ~won & tenthRound;

  logic increment;
  assign increment = ready & grade_it;

  /* Datapath */
  Counter #(4) roundCount(.Q(round_number), .D(4'd1), .clear(1'b0),
                          .load(load), .en(increment), .up(1'b1), .clock);
  MagComp #(4) cmp0(.AeqB(tenthRound), .A(4'd11), .B(round_number), .AltB(), .AgtB());
  MagComp #(3) cmp1(.AeqB(preWon), .A(3'd4), .B(red), .AltB(), .AgtB());
  Decoder #(5) redDecode(.D(redVal), .I({2'b00, red}), .en(1'b1)),
               whiteDecode(.D(whiteVal), .I({2'b00, white}), .en(1'b1));

  logic [2:0] prefeedback0, prefeedback1, prefeedback2, prefeedback3;
  logic enable, clear;
  assign enable = increment;
  assign clear = load;

  Register #(3) feed3(.D(prefeedback0), .Q(feedback3), .en(enable), .*),
                feed2(.D(prefeedback1), .Q(feedback2), .en(enable), .*),
                feed1(.D(prefeedback2), .Q(feedback1), .en(enable), .*),
                feed0(.D(prefeedback3), .Q(feedback0), .en(enable), .*);
  Register #(1) holdWon(.D(preWon), .Q(won), .en(enable), .*);

endmodule : Task2

module calcFeedback
  (input logic [11:0] guess,
    input logic [4:0] redVal, whiteVal,
    output logic [2:0] prefeedback0, prefeedback1, prefeedback2, prefeedback3);

  logic [11:0] tmp;
  always_comb begin
    tmp = 12'b0;
    case(redVal)
      5'b0_0001: begin
        case(whiteVal)
          5'b0_0001: tmp= 12'b0;
          5'b0_0010: tmp= 12'o1000;
          5'b0_0100: tmp= 12'o1100;
          5'b0_1000: tmp= 12'o1110;
          5'b1_0000: tmp= 12'o1111;
        endcase
      end

      5'b0_0010: begin
        case(whiteVal)
          5'b0_0001: tmp= 12'o7000;
          5'b0_0010: tmp= 12'o7100;
          5'b0_0100: tmp= 12'o7110;
          5'b0_1000: tmp= 12'o7111;
        endcase
      end

      5'b0_0100: begin
        case(whiteVal)
          5'b0_0001: tmp= 12'o7700;
          5'b0_0010: tmp= 12'o7710;
          5'b0_0100: tmp= 12'o7711;
        endcase
      end

      5'b0_1000: begin
        case(whiteVal)
          5'b0_0001: tmp= 12'o7770;
          5'b0_0010: tmp= 12'o7771;
        endcase
      end

      5'b1_0000: tmp= 12'o7777;
    endcase
    {prefeedback0, prefeedback1, prefeedback2, prefeedback3}= tmp;
  end
endmodule : calcFeedback

module fsm
  (input logic grade_it, start_game, tenthRound, preWon,
   output logic load, ready,
   input logic clock, reset);

  enum {start, scoring, roundOver, hold} currState, nextState;

  /* Next State Logic */
  always_comb begin
    case(currState)
      start: nextState = (grade_it) ? scoring : start;
      scoring: begin
        if(tenthRound | preWon & grade_it)
          nextState = roundOver;
        else
          nextState = grade_it ? hold : scoring;
      end
      hold: nextState = grade_it ? hold : scoring;
      roundOver: nextState = start_game ? start : roundOver;
    endcase
  end

  /* Output Logic */
  always_comb begin
    load = 1'b0;
    ready = 1'b0;
    case(currState)
      start: load = ~grade_it;
      scoring: ready = 1'b1;
      hold: ready = 1'b0;
      roundOver: load = (start_game) ? 1'b1 : 1'b0;
    endcase
  end

  always_ff @ (posedge clock)
    if(reset)
      currState <= start;
    else
      currState <= nextState;

endmodule : fsm

