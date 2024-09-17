`default_nettype none

module Task3
  (input logic start_game, grade_it, load_color,
   input logic [2:0] color_to_load,
   input logic [1:0] color_location,
   input logic [11:0] guess,
   output logic neopixel_data,
   output logic [3:0] round_number,
   output logic won, lost,
   input  logic clock, reset);

  logic [11:0] pattern;

  logic done;
  logic [1:0] st;

  logic tenthRound, load, preWon, ready, clearColors;
  logic loaded0, loaded1, loaded2, loaded3;
  logic start_neo;
  fsm control(.*);

  logic [2:0] red, white;
  Grader scoreThis(.guess0(guess[2:0]), .guess1(guess[5:3]),
                   .guess2(guess[8:6]), .guess3(guess[11:9]),
                   .pattern0(pattern[2:0]), .pattern1(pattern[5:3]),
                   .pattern2(pattern[8:6]), .pattern3(pattern[11:9]),
                   .red(red), .white(white));

  logic [4:0] redVal, whiteVal;
  calcFeedback feedbackModule(.*);

  assign lost = ~won & tenthRound;

  logic increment;
  assign increment = ready & grade_it;

  logic load0, load1, load2, load3, valid;

  /* Datapath */
  Counter #(4) roundCount(.Q(round_number), .D(4'd1), .clear(reset),
                          .load(load), .en(increment), .up(1'b1), .clock);

  MagComp #(4) cmp0(.AeqB(tenthRound), .A(4'd11), .B(round_number));

  MagComp #(3) cmp1(.AeqB(preWon), .A(3'd4), .B(red)),
               colors0(.A(color_to_load), .B(3'b110), .AltB(valid));

  MagComp #(2) loadc0(.B(2'b00), .A(color_location), .AeqB(load0)),
               loadc1(.B(2'b01), .A(color_location), .AeqB(load1)),
               loadc2(.B(2'b10), .A(color_location), .AeqB(load2)),
               loadc3(.B(2'b11), .A(color_location), .AeqB(load3));

  Decoder #(5) redDecode(.D(redVal), .I(red), .en(1'b1)),
               whiteDecode(.D(whiteVal), .I(white), .en(1'b1));

  logic [2:0] prefeedback0, prefeedback1, prefeedback2, prefeedback3;
  logic [2:0] feedback0, feedback1, feedback2, feedback3;
  logic enable, clear;
  logic [2:0] color0, color1, color2, color3;
  logic enP0, enP1, enP2, enP3;
  assign enable = increment;
  assign clear = load | reset;
  assign enP0 = load0 & valid & ~loaded0 & load_color;
  assign enP1 = load1 & valid & ~loaded1 & load_color;
  assign enP2 = load2 & valid & ~loaded2 & load_color;
  assign enP3 = load3 & valid & ~loaded3 & load_color;

  logic clearCol;
  assign clearCol = reset | clearColors;

  Register #(3) feed3(.D(prefeedback0), .Q(feedback3), .en(enable), .*),
                feed2(.D(prefeedback1), .Q(feedback2), .en(enable), .*),
                feed1(.D(prefeedback2), .Q(feedback1), .en(enable), .*),
                feed0(.D(prefeedback3), .Q(feedback0), .en(enable), .*),
                p3(.D(color_to_load), .Q(color3), .en(enP3), .clear(clearCol), .*),
                p2(.D(color_to_load), .Q(color2), .en(enP2), .clear(clearCol), .*),
                p1(.D(color_to_load), .Q(color1), .en(enP1), .clear(clearCol), .*),
                p0(.D(color_to_load), .Q(color0), .en(enP0), .clear(clearCol), .*);
  assign pattern = {color3, color2, color1, color0};

  logic lv0, lv1, lv2, lv3;
  assign lv0 = load0 & valid & load_color;
  assign lv1 = load1 & valid & load_color;
  assign lv2 = load2 & valid & load_color;
  assign lv3 = load3 & valid & load_color;

  Register #(1) holdWon(.D(preWon), .Q(won), .en(enable), .clear(clearCol), .*),
                loadCheck0(.D(lv0), .Q(loaded0), .en(enP0), .clear(clearCol), .*),
                loadCheck1(.D(lv1), .Q(loaded1), .en(enP1), .clear(clearCol), .*),
                loadCheck2(.D(lv2), .Q(loaded2), .en(enP2), .clear(clearCol), .*),
                loadCheck3(.D(lv3), .Q(loaded3), .en(enP3), .clear(clearCol), .*);

  logic [3:0] loaded_i;
  assign loaded_i = {loaded3, loaded2, loaded1, loaded0};
  logic [11:0] feedback;
  assign feedback = {feedback3, feedback2, feedback1, feedback0};


 neopixelGameController NPCntrl(.*, .start(start_neo), .CLOCK_50(clock));

endmodule : Task3

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
   input logic loaded0, loaded1, loaded2, loaded3, load_color,
   output logic load, ready, clearColors, start_neo,
   input logic clock, reset,
   input logic done,
   output logic [1:0] st);

  enum {start, start_int, pattern_int, loaded, scoring, results, hold}
       currState, nextState;

  /* Next State Logic */
  always_comb begin
    case(currState)
      start: nextState = (start_game & loaded0 & loaded1 & loaded2 & loaded3) ? start_int : pattern_int;
      pattern_int: nextState= done? start : pattern_int;
      start_int: nextState= done? loaded : start_int;
      loaded: nextState = grade_it ? scoring : loaded;
      scoring: begin
        if(tenthRound | preWon & grade_it)
          nextState = start;
        else
          nextState = grade_it ? results : scoring;
      end
      results: nextState = done? hold : results;
      hold: nextState = grade_it ? hold : scoring;
    endcase
  end

  /* Output Logic */
  always_comb begin
    load = 1'b0;
    ready = 1'b0;
    clearColors = 1'b0;
    st= 2'b01;
     start_neo=0;
    case(currState)
      start: {start_neo, load, st}= (start_game & loaded0 & loaded1 & loaded2
              & loaded3) ? 4'b1100: (load_color ? 4'b1010 : 4'b1001);
      scoring: begin
        if(tenthRound | preWon & grade_it) begin
          ready = 1'b1;
          clearColors = 1'b1;
          st= 2'b00;
             start_neo=1;
        end
        else
          ready = 1'b1;
          st= 2'b11;
             start_neo=1;
      end
    endcase
  end

  always_ff @ (posedge clock)
    if(reset)
      currState <= start;
    else
      currState <= nextState;

endmodule : fsm


