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




/*
module calcNumHitsBig_tb ();
    logic [3:0] X, Y;
    logic [6:0] F;
    calcNumHitsBig(.*);
    initial begin
        $monitor($time,,
                 "F(%d, %d)= %b", X, Y, F);
        X= 3; Y= 9; #1;
        $finish;
    end
endmodule : calcNumHitsBig_tb
*/

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

module calcNumHits_tb ();
    logic [3:0] X, Y;
    logic [6:0] NumHits;
    logic Big, ScoreThis;

    calcNumHits DUT(.X, .Y, .*);

    initial begin
    $monitor($time,,
             "(%d, %d) Big= %b ScoreThis= %b, NumHits= %d",
             X, Y, Big, ScoreThis, NumHits);

    ScoreThis= 1'b1;

    Big= 0; X=5; Y=2; #3;
    Big= 0; X=5; Y=3; #3;
    Big= 1; X=5; Y=3; #3;

    Big= 0; X=3; Y=2; #3;
    Big= 1; X=3; Y=2; #3;

    Big= 0; X=3; Y=9; #3;
    Big= 1; X=3; Y=9; #3;

    Big= 0; X=5; Y=4; #3;
    Big= 1; X=5; Y=4; #3;

    ScoreThis= 1'b0;
    Big= 1; X=5; Y=4; #3;

    $finish;
    end
endmodule : calcNumHits_tb
