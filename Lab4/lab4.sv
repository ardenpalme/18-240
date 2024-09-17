`default_nettype none

module abstractFSM(
  input  logic [3:0] hMove,
  input  logic valid,
  input  logic newGame,
  output logic [3:0] cMove,
  output logic [15:0] HHEX,
  output logic [15:0] CHEX,
  output logic       win,
  input  logic       clock, reset_N
);

  enum logic [4:0] {new_game, new_game_int,
                    cStart, cStart_int,
                    first, first_int,
                    second,
                    win12, win12_int,
                    win13, win13_int,
                    win14, win14_int,
                    win17, win17_int,
                    win18, win18_int,

                    win22, win22_int,
                    win24, win24_int,
                    win27, win27_int,
                    win28, win28_int}
    currState, nextState;

  // Next State Generator
  always_comb begin
    case (currState)
      new_game: nextState= (valid && newGame) ? new_game_int : new_game;
      new_game_int: nextState= (~valid && ~newGame) ? cStart : new_game_int;

      cStart: nextState = (valid && hMove == 4'd6) ? cStart_int: cStart;
      cStart_int: nextState = (~valid) ? first : cStart_int;

      first: begin
        if(valid) begin
            case(hMove)
                4'd2: nextState= win12_int;
                4'd3: nextState= win13_int;
                4'd4: nextState= win14_int;
                4'd7: nextState= win17_int;
                4'd8: nextState= win18_int;
                4'd9: nextState= first_int;
                default: nextState= first;
            endcase
        end
        else nextState= first;
      end
      first_int: nextState= (~valid) ? second : first_int;

      second: begin
        if(valid) begin
            case(hMove)
                4'd2: nextState= win22_int;
                4'd4: nextState= win24_int;
                4'd7: nextState= win27_int;
                4'd8: nextState= win28_int;
                default: nextState= second;
            endcase
        end
        else nextState= second;
      end

      win12_int: nextState= (~valid) ? win12 : win12_int;
      win12: nextState= newGame ? new_game : win12;

      win13_int: nextState= (~valid) ? win13 : win13_int;
      win13: nextState= newGame ? new_game : win13;

      win14_int: nextState= (~valid) ? win14 : win14_int;
      win14: nextState= newGame ? new_game : win14;

      win17_int: nextState= (~valid) ? win17 : win17_int;
      win17: nextState= newGame ? new_game : win17;

      win18_int: nextState= (~valid) ? win18 : win18_int;
      win18: nextState= newGame ? new_game : win18;



      win22_int: nextState= (~valid) ? win22 : win22_int;
      win22: nextState= newGame ? new_game : win22;

      win24_int: nextState= (~valid) ? win24 : win24_int;
      win24: nextState= newGame ? new_game : win24;

      win27_int: nextState= (~valid) ? win27 : win27_int;
      win27: nextState= newGame ? new_game : win27;

      win28_int: nextState= (~valid) ? win28 : win28_int;
      win28: nextState= newGame ? new_game : win28;



      default: nextState = cStart; //never exec'd
    endcase
  end

  // Output Generator
  always_comb begin
    win = 1'b0;
    HHEX = 16'h00_00;
    unique case (currState)
      new_game, new_game_int: begin
        cMove= 4'd15; //invalid
        HHEX= 16'd0;
        CHEX= 16'd0;
      end
      cStart, cStart_int: begin
          cMove= 4'd5;
          CHEX= 16'h50_00;
      end

      first, first_int: begin
          cMove = 4'd1;
          HHEX= 16'h60_00;
          CHEX= 16'h15_00;
      end

      win12, win12_int: begin
        cMove = 4'd9;
        HHEX= 16'h26_00;
        CHEX= 16'h15_90;
        win = 1'b1;
      end

      win13, win13_int: begin
        cMove = 4'd9;
        HHEX= 16'h36_00;
        CHEX= 16'h15_90;
        win = 1'b1;
      end

      win14, win14_int: begin
        cMove = 4'd9;
        HHEX= 16'h46_00;
        CHEX= 16'h15_90;
        win = 1'b1;
      end

      win17, win17_int: begin
        cMove = 4'd9;
        HHEX= 16'h67_00;
        CHEX= 16'h15_90;
        win = 1'b1;
      end

      win18, win18_int: begin
        cMove = 4'd9;
        HHEX= 16'h68_00;
        CHEX= 16'h15_90;
        win = 1'b1;
      end




      second: begin
          cMove = 4'd3;
          HHEX= 16'h69_00;
          CHEX= 16'h13_50;
      end

      win22, win22_int: begin
          cMove = 4'd2;
          HHEX= 16'h26_90;
          CHEX= 16'h12_35;
          win = 1'b1;
      end

      win24, win24_int: begin
          cMove = 4'd2;
          HHEX= 16'h46_90;
          CHEX= 16'h12_35;
          win = 1'b1;
      end

      win27, win27_int: begin
          cMove = 4'd2;
          HHEX= 16'h67_90;
          CHEX= 16'h12_35;
          win = 1'b1;
      end

      win28, win28_int: begin
          cMove = 4'd2;
          HHEX= 16'h68_90;
          CHEX= 16'h12_35;
          win = 1'b1;
      end

    endcase
  end

  always_ff @(posedge clock)
    if (~reset_N)
      currState <= cStart;
    else
      currState <= nextState;
endmodule: abstractFSM
