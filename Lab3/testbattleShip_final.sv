`default_nettype none;

module CalcHitNormal
  (output logic HitNormal,
   input logic [3:0] X, Y);

  always_comb
      case ({X, Y})

          8'b0010_1010: HitNormal = 1'b1; // sub: (2, 10)
          8'b0010_1001: HitNormal = 1'b1; // sub: (2, 9)
          8'b0010_1000: HitNormal = 1'b1; // sub: (2, 8)

          8'b0111_0110: HitNormal = 1'b1; // patrol: (7, 6)
          8'b1000_0110: HitNormal = 1'b1; // patrol: (8, 6)

          8'b0010_0011: HitNormal = 1'b1; // aircraft: (2, 3)
          8'b0011_0011: HitNormal = 1'b1; // aircraft: (3, 3)
          8'b0100_0011: HitNormal = 1'b1; // aircraft: (4, 3)
          8'b0101_0011: HitNormal = 1'b1; // aircraft: (5, 3)
          8'b0110_0011: HitNormal = 1'b1; // aircraft: (6, 3)

          8'b0001_0010: HitNormal = 1'b1; // battleship: (1, 2)
          8'b0010_0010: HitNormal = 1'b1; // battleship: (2, 2)
          8'b0011_0010: HitNormal = 1'b1; // battleship: (3, 2)
          8'b0100_0010: HitNormal = 1'b1; // battleship: (4, 2)

          8'b0010_0001: HitNormal = 1'b1; // cruiser: (2, 1)
          8'b0011_0001: HitNormal = 1'b1; // cruiser: (3, 1)
          8'b0100_0001: HitNormal = 1'b1; // cruiser: (4, 1)

          8'b1001_0001: HitNormal = 1'b1; // patrol: (9, 1)
          8'b1010_0001: HitNormal = 1'b1; // patrol: (10, 1)

          default: HitNormal = 1'b0;

      endcase

endmodule: CalcHitNormal

module CalcHitBig
  (output logic HitBig,
   input logic [3:0] X, Y);

  logic [8:0] HitNormal;

  CalcHitNormal HN1(.HitNormal(HitNormal[0]), .X(X), .Y(Y));
  CalcHitNormal HN2(.HitNormal(HitNormal[1]), .X(X+4'd1), .Y(Y));
  CalcHitNormal HN3(.HitNormal(HitNormal[2]), .X(X-4'd1), .Y(Y));
  CalcHitNormal HN4(.HitNormal(HitNormal[3]), .X(X), .Y(Y+4'd1));
  CalcHitNormal HN5(.HitNormal(HitNormal[4]), .X(X), .Y(Y-4'd1));
  CalcHitNormal HN6(.HitNormal(HitNormal[5]), .X(X+4'd1), .Y(Y+4'd1));
  CalcHitNormal HN7(.HitNormal(HitNormal[6]), .X(X-4'd1), .Y(Y-4'd1));
  CalcHitNormal HN8(.HitNormal(HitNormal[7]), .X(X+4'd1), .Y(Y-4'd1));
  CalcHitNormal HN9(.HitNormal(HitNormal[8]), .X(X-4'd1), .Y(Y+4'd1));

  assign HitBig = HitNormal[0] | HitNormal[1] | HitNormal[2] |
              HitNormal[3] | HitNormal[4] | HitNormal[5] |
              HitNormal[6] | HitNormal[7] | HitNormal[8];

endmodule: CalcHitBig

module CalcHit
  (output logic Hit,
  input logic [3:0] X, Y,
  input logic Big);

  logic HitNormal, HitBig;

  CalcHitNormal HN(.HitNormal(HitNormal), .X(X), .Y(Y));
  CalcHitBig HB(.HitBig(HitBig), .X(X), .Y(Y));

  assign Hit = Big ? HitBig : HitNormal;

endmodule: CalcHit



module CalcMissNormal
  (output logic MissNormal,
   input logic [3:0] X, Y);

  always_comb
      case ({X, Y})

          8'b0010_1010: MissNormal = 1'b0; // sub: (2, 10)
          8'b0010_1001: MissNormal = 1'b0; // sub: (2, 9)
          8'b0010_1000: MissNormal = 1'b0; // sub: (2, 8)

          8'b0111_0110: MissNormal = 1'b0; // patrol: (7, 6)
          8'b1000_0110: MissNormal = 1'b0; // patrol: (8, 6)

          8'b0010_0011: MissNormal = 1'b0; // aircraft: (2, 3)
          8'b0011_0011: MissNormal = 1'b0; // aircraft: (3, 3)
          8'b0100_0011: MissNormal = 1'b0; // aircraft: (4, 3)
          8'b0101_0011: MissNormal = 1'b0; // aircraft: (5, 3)
          8'b0110_0011: MissNormal = 1'b0; // aircraft: (6, 3)

          8'b0001_0010: MissNormal = 1'b0; // battleship: (1, 2)
          8'b0010_0010: MissNormal = 1'b0; // battleship: (2, 2)
          8'b0011_0010: MissNormal = 1'b0; // battleship: (3, 2)
          8'b0100_0010: MissNormal = 1'b0; // battleship: (4, 2)

          8'b0010_0001: MissNormal = 1'b0; // cruiser: (2, 1)
          8'b0011_0001: MissNormal = 1'b0; // cruiser: (3, 1)
          8'b0100_0001: MissNormal = 1'b0; // cruiser: (4, 1)

          8'b1001_0001: MissNormal = 1'b0; // patrol: (9, 1)
          8'b1010_0001: MissNormal = 1'b0; // patrol: (10, 1)

          default: MissNormal = 1'b1;

      endcase

endmodule: CalcMissNormal

module CalcMissBig
  (output logic MissBig,
   input logic [3:0] X, Y);

  logic [8:0] MissNormal;

  CalcMissNormal MN1(.MissNormal(MissNormal[0]), .X(X), .Y(Y));
  CalcMissNormal MN2(.MissNormal(MissNormal[1]), .X(X+4'd1), .Y(Y));
  CalcMissNormal MN3(.MissNormal(MissNormal[2]), .X(X-4'd1), .Y(Y));
  CalcMissNormal MN4(.MissNormal(MissNormal[3]), .X(X), .Y(Y+4'd1));
  CalcMissNormal MN5(.MissNormal(MissNormal[4]), .X(X), .Y(Y-4'd1));
  CalcMissNormal MN6(.MissNormal(MissNormal[5]), .X(X+4'd1), .Y(Y+4'd1));
  CalcMissNormal MN7(.MissNormal(MissNormal[6]), .X(X-4'd1), .Y(Y-4'd1));
  CalcMissNormal MN8(.MissNormal(MissNormal[7]), .X(X+4'd1), .Y(Y-4'd1));
  CalcMissNormal MN9(.MissNormal(MissNormal[8]), .X(X-4'd1), .Y(Y+4'd1));

  assign MissBig = MissNormal[0] &  MissNormal[1] &  MissNormal[2] &
                  MissNormal[3] & MissNormal[4] & MissNormal[5] &
                  MissNormal[6] & MissNormal[7] & MissNormal[8];

endmodule: CalcMissBig


module CalcMiss
  (output logic Miss,
  input logic [3:0] X, Y,
  input logic Big);

  logic MissNormal, MissBig;

  CalcMissNormal MN(.MissNormal(MissNormal), .X(X), .Y(Y));
  CalcMissBig MB(.MissBig(MissBig), .X(X), .Y(Y));

  assign Miss = Big ? MissBig : MissNormal;

endmodule: CalcMiss


module CalcNearMissNormal
  (output logic NearMissNormal,
   input logic [3:0] X, Y);

  always_comb
      case ({X, Y})

          8'b0001_1010: NearMissNormal = 1'b1; // sub: (1, 10)
          8'b0001_1001: NearMissNormal = 1'b1; // sub: (1, 9)
          8'b0001_1000: NearMissNormal = 1'b1; // sub: (1, 8)
          8'b0011_1010: NearMissNormal = 1'b1; // sub: (3, 10)
          8'b0011_1001: NearMissNormal = 1'b1; // sub: (3, 9)
          8'b0011_1000: NearMissNormal = 1'b1; // sub: (3, 8)
          8'b0010_0111: NearMissNormal = 1'b1; // sub: (2, 7)

          8'b0111_0111: NearMissNormal = 1'b1; // patrol: (7, 7)
          8'b1000_0111: NearMissNormal = 1'b1; // patrol: (8, 7)
          8'b0111_0101: NearMissNormal = 1'b1; // patrol: (7, 5)
          8'b1000_0101: NearMissNormal = 1'b1; // patrol: (8, 5)
          8'b0110_0110: NearMissNormal = 1'b1; // patrol: (6, 6)
          8'b1001_0110: NearMissNormal = 1'b1; // patrol: (9, 6)

          8'b0001_0011: NearMissNormal = 1'b1; // aircraft: (1, 3)
          8'b0111_0011: NearMissNormal = 1'b1; // aircraft: (7, 3)
          8'b0010_0100: NearMissNormal = 1'b1; // aircraft: (2, 4)
          8'b0011_0100: NearMissNormal = 1'b1; // aircraft: (3, 4)
          8'b0100_0100: NearMissNormal = 1'b1; // aircraft: (4, 4)
          8'b0101_0100: NearMissNormal = 1'b1; // aircraft: (5, 4)
          8'b0110_0100: NearMissNormal = 1'b1; // aircraft: (6, 4)
          8'b0110_0010: NearMissNormal = 1'b1; // aircraft: (6, 2)
          8'b0101_0010: NearMissNormal = 1'b1; // aircraft: (5, 2)

          8'b0001_0001: NearMissNormal = 1'b1; // battleship: (1, 1)

          8'b0101_0001: NearMissNormal = 1'b1; // cruiser: (5, 1)

          8'b1000_0001: NearMissNormal = 1'b1; // patrol: (8, 1)
          8'b1001_0010: NearMissNormal = 1'b1; // patrol: (9, 2)
          8'b1010_0010: NearMissNormal = 1'b1; // patrol: (10, 2)

          default: NearMissNormal = 1'b0;

      endcase

endmodule: CalcNearMissNormal


module CalcNearMissBig
  (output logic NearMissBig,
   input logic [3:0] X, Y);

  logic [8:0] NearMissNormal;
  logic HitBig;

  CalcHitBig HB(.HitBig(HitBig), .X(X), .Y(Y));

  CalcNearMissNormal NMN1(.NearMissNormal(NearMissNormal[0]), .X(X), .Y(Y));
  CalcNearMissNormal NMN2(.NearMissNormal(NearMissNormal[1]), .X(X+4'd1), .Y(Y));
  CalcNearMissNormal NMN3(.NearMissNormal(NearMissNormal[2]), .X(X-4'd1), .Y(Y));
  CalcNearMissNormal NMN4(.NearMissNormal(NearMissNormal[3]), .X(X), .Y(Y+4'd1));
  CalcNearMissNormal NMN5(.NearMissNormal(NearMissNormal[4]), .X(X), .Y(Y-4'd1));
  CalcNearMissNormal NMN6(.NearMissNormal(NearMissNormal[5]), .X(X+4'd1), .Y(Y+4'd1));
  CalcNearMissNormal NMN7(.NearMissNormal(NearMissNormal[6]), .X(X-4'd1), .Y(Y-4'd1));
  CalcNearMissNormal NMN8(.NearMissNormal(NearMissNormal[7]), .X(X+4'd1), .Y(Y-4'd1));
  CalcNearMissNormal NMN9(.NearMissNormal(NearMissNormal[8]), .X(X-4'd1), .Y(Y+4'd1));

  assign NearMissBig = (NearMissNormal[0] | NearMissNormal[1] | NearMissNormal[2] |
           NearMissNormal[3] | NearMissNormal[4] | NearMissNormal[5] |
           NearMissNormal[6] | NearMissNormal[7] | NearMissNormal[8]) & ~HitBig;

endmodule: CalcNearMissBig


module CalcNearMiss
  (output logic NearMiss,
  input logic [3:0] X, Y,
  input logic Big);

  logic NearMissNormal, NearMissBig;

  CalcNearMissNormal NMN(.NearMissNormal(NearMissNormal), .X(X), .Y(Y));
  CalcNearMissBig NMB(.NearMissBig(NearMissBig), .X(X), .Y(Y));

  assign NearMiss = Big ? NearMissBig : NearMissNormal;

endmodule: CalcNearMiss

module IsSomethingWrong
  (output logic SomethingIsWrong,
  input logic [3:0] X, Y,
  input logic Big, ScoreThis,
  input logic [1:0] BigLeft);

  logic XisValid, YisValid, BigLeftisValid, BigisValid;

  assign XisValid = (X >= 4'b0001) & (X <= 4'b1010);
  assign YisValid = (Y >= 4'b0001) & (Y <= 4'b1010);
  assign BigLeftisValid = (BigLeft >= 2'b00) & (BigLeft <= 2'b10);
  assign BigisValid = ((BigLeft > 2'b00) & Big) | ~Big;

  assign SomethingIsWrong = ScoreThis & (~XisValid | ~YisValid | ~BigLeftisValid | ~BigisValid);

endmodule: IsSomethingWrong




/* ---- BEGIN NumHits ---- */

module calcNumHitNormal
  (output logic [6:0] G,
   input logic [3:0] X, Y);

  always_comb
      case ({X, Y})

          8'b0010_1010: G = 7'd1; // sub: (2, 10)
          8'b0010_1001: G = 7'd1; // sub: (2, 9)
          8'b0010_1000: G = 7'd1; // sub: (2, 8)

          8'b0111_0110: G = 7'd1; // patrol: (7, 6)
          8'b1000_0110: G = 7'd1; // patrol: (8, 6)

          8'b0010_0011: G = 7'd1; // aircraft: (2, 3)
          8'b0011_0011: G = 7'd1; // aircraft: (3, 3)
          8'b0100_0011: G = 7'd1; // aircraft: (4, 3)
          8'b0101_0011: G = 7'd1; // aircraft: (5, 3)
          8'b0110_0011: G = 7'd1; // aircraft: (6, 3)

          8'b0001_0010: G = 7'd1; // battleship: (1, 2)
          8'b0010_0010: G = 7'd1; // battleship: (2, 2)
          8'b0011_0010: G = 7'd1; // battleship: (3, 2)
          8'b0100_0010: G = 7'd1; // battleship: (4, 2)

          8'b0010_0001: G = 7'd1; // cruiser: (2, 1)
          8'b0011_0001: G = 7'd1; // cruiser: (3, 1)
          8'b0100_0001: G = 7'd1; // cruiser: (4, 1)

          8'b1001_0001: G = 7'd1; // patrol: (9, 1)
          8'b1010_0001: G = 7'd1; // patrol: (10, 1)

          default: G = 7'd0;
      endcase
endmodule: calcNumHitNormal
module calcNumHitsBig
   (input logic [3:0] X, Y,
   output logic [6:0] F);

   logic [6:0] out0, out1, out2, out3, out4, out5, out6, out7, out8;
   calcNumHitNormal S0(.X(X - 4'd1), .Y(Y + 4'd1), .G(out0));
   calcNumHitNormal S1(.X(X), .Y(Y + 4'd1), .G(out1));
   calcNumHitNormal S2(.X(X + 4'd1), .Y(Y + 4'd1), .G(out2));
   calcNumHitNormal S3(.X(X - 4'd1), .Y(Y), .G(out3));
   calcNumHitNormal S4(.X(X), .Y(Y), .G(out4));
   calcNumHitNormal S5(.X(X + 4'd1), .Y(Y), .G(out5));
   calcNumHitNormal S6(.X(X - 4'd1), .Y(Y - 4'd1), .G(out6));
   calcNumHitNormal S7(.X(X), .Y(Y - 4'd1), .G(out7));
   calcNumHitNormal S8(.X(X + 4'd1), .Y(Y - 4'd1), .G(out8));

   assign F= out0 + out1 + out2 + out3 + out4 + out5 + out6 + out7 + out8;

endmodule : calcNumHitsBig

module calcNumHits
   (input logic [3:0] X, Y,
    input logic Big, ScoreThis,
    output logic [6:0] NumHits);

   logic [6:0] F;
   logic Hit;
   calcNumHitsBig NumHitsBig(.X, .Y, .F);
   CalcHit tmp(.X, .Y, .Big, .Hit);

   always_comb begin
       if(Hit && ScoreThis)
           begin
           if(Big)
               NumHits= F;
           else
               NumHits= 7'd1;
           end
       else
           NumHits= 7'd0;
   end
endmodule : calcNumHits

/* ---- END NumHits ---- */

/* ---- BEGIN BiggestShipHit ---- */
module calcBiggestShipHitNormal
   (input logic [3:0] X, Y,
    output logic [4:0] F);

   always_comb begin
       case ({X,Y})
           /* Patrol Boats */
           8'b0111_0110: F = 5'b0_0001;
           8'b1000_0110: F = 5'b0_0001;
           8'b1001_0001: F = 5'b0_0001;
           8'b1010_0001: F = 5'b0_0001;

           /* Submarine */
           8'b0010_1010: F = 5'b0_0010;
           8'b0010_1001: F = 5'b0_0010;
           8'b0010_1000: F = 5'b0_0010;

           /* Cruiser */
           8'b0010_0001: F = 5'b0_0100;
           8'b0011_0001: F = 5'b0_0100;
           8'b0100_0001: F = 5'b0_0100;

           /* Battleship */
           8'b0001_0010: F = 5'b0_1000;
           8'b0010_0010: F = 5'b0_1000;
           8'b0011_0010: F = 5'b0_1000;
           8'b0100_0010: F = 5'b0_1000;

           /* Aircraft Carrier */
           8'b0010_0011: F = 5'b1_0000;
           8'b0011_0011: F = 5'b1_0000;
           8'b0100_0011: F = 5'b1_0000;
           8'b0101_0011: F = 5'b1_0000;
           8'b0110_0011: F = 5'b1_0000;

           default : F= 5'd0;
       endcase
   end
endmodule : calcBiggestShipHitNormal
module calcBiggestShipHit
   (input logic [3:0] X, Y,
    input logic Big, ScoreThis,
    output logic [4:0] BiggestShipHit);

    logic Hit;
    CalcHit tmp1(.X, .Y, .Big, .Hit);

   logic [4:0] out0, out1, out2, out3, out4, out5, out6, out7, out8;

   calcBiggestShipHitNormal S0(.X(X - 4'd1), .Y(Y + 4'd1), .F(out0));
   calcBiggestShipHitNormal S1(.X(X), .Y(Y + 4'd1), .F(out1));
   calcBiggestShipHitNormal S2(.X(X + 4'd1), .Y(Y + 4'd1), .F(out2));
   calcBiggestShipHitNormal S3(.X(X - 4'd1), .Y(Y), .F(out3));
   calcBiggestShipHitNormal S4(.X(X), .Y(Y), .F(out4));
   calcBiggestShipHitNormal S5(.X(X + 4'd1), .Y(Y), .F(out5));
   calcBiggestShipHitNormal S6(.X(X - 4'd1), .Y(Y - 4'd1), .F(out6));
   calcBiggestShipHitNormal S7(.X(X), .Y(Y - 4'd1), .F(out7));
   calcBiggestShipHitNormal S8(.X(X + 4'd1), .Y(Y - 4'd1), .F(out8));

   logic [4:0] aggreg, tmp;
   assign aggreg= out0 | out1 | out2 | out3 | out4 | out5 | out6 | out7 | out8;

   always_comb begin
       casez(aggreg)
           5'b1_????: tmp= 5'b1_0000;
           5'b0_1???: tmp= 5'b0_1000;
           5'b0_01??: tmp= 5'b0_0100;
           5'b0_001?: tmp= 5'b0_0010;
           5'b0_0001: tmp= 5'b0_0001;

           default : tmp= 5'd0;
       endcase

       if(Hit && ScoreThis) begin
           if(Big)
               BiggestShipHit= tmp;
           else
               BiggestShipHit= out4;
       end
       else
           BiggestShipHit= 5'd0;
   end
endmodule : calcBiggestShipHit
/* ---- END BiggestShipHit ---- */

module Battleship
    (output logic Hit, NearMiss, Miss, SomethingIsWrong,
    output logic [6:0] NumHits,
    output logic [4:0] BiggestShipHit,
    input logic [3:0] X, Y,
    input logic Big, ScoreThis,
    input logic [1:0] BigLeft);

    CalcHit CH(.Big(Big), .Hit(Hit), .X(X), .Y(Y));
    CalcNearMiss CNM(.Big(Big), .NearMiss(NearMiss), .X(X), .Y(Y));
    CalcMiss CM(.Big(Big), .Miss(Miss), .X(X), .Y(Y));
    calcNumHits CNH(.*);
    calcBiggestShipHit CBSH(.*);
    IsSomethingWrong ISW(.SomethingIsWrong(SomethingIsWrong), .X(X), .Y(Y),
                         .Big(Big), .ScoreThis(ScoreThis), .BigLeft(BigLeft));

endmodule: Battleship

module BattleShip_tb ();
    logic [6:0] NumHits;
    logic [4:0] BiggestShipHit;
    logic [3:0] X, Y;
    logic [1:0] BigLeft;
    logic Hit, NearMiss, Miss, SomethingIsWrong;
    logic Big, ScoreThis;

    Battleship DUT(.*);

    initial begin
        $display("(X, Y) [Hit Miss NearMiss]");
        $monitor($time,,
                 "(%d, %d) [%b%b%b] NumHits= %d, BiggestShipHit= %b -- BigLeft= %d OK?: %b",
                 X, Y, Hit, Miss, NearMiss, NumHits, BiggestShipHit, BigLeft, ~SomethingIsWrong);

        ScoreThis= 1;
        BigLeft= 2;
        Big= 1;
        X= 3; Y= 2; #3;
        X= 1; Y= 1; #3;
        BigLeft= 0; Big=1; X= 7; Y= 2; #3; //SomethingIsWrong is asserted
        BigLeft= 1; X= 5; Y= 5; #3;

        Big= 0;
        ScoreThis= 0; X= 3; Y= 2; #3;
        ScoreThis= 1; X= 1; Y= 1; #3;
        X= 7; Y= 2; #3;
        X= 5; Y= 5; #3;


        $finish;
    end
endmodule : BattleShip_tb
