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

module calcBiggestShipHit_tb ();
   logic [3:0] X, Y;
   logic [4:0] BiggestShipHit;
   logic Big, ScoreThis;

   calcBiggestShipHit DUT(.*);

   initial begin
       $monitor($time,,
                "(%d, %d) Big= %b, ScoreThis= %b, BiggestShipHit= %b",
                X, Y, Big, ScoreThis, BiggestShipHit);

        ScoreThis= 1;
        X= 3; Y= 2; Big= 1; #3;
        X= 6; Y= 6; Big= 1; #3;
        X= 3; Y= 9; Big= 1; #3;
        X= 9; Y= 2; Big= 1; #3;
        X= 9; Y= 2; Big= 0; #3;
        X= 9; Y= 1; Big= 0; #3;
        X= 9; Y= 3; Big= 1; #3;
        X= 5; Y= 2; Big= 1; #3;
        X= 6; Y= 2; Big= 1; #3;
        X= 7; Y= 2; Big= 1; #3;
        X= 8; Y= 2; Big= 1; #3;

        ScoreThis= 0; #3;
        $finish;
   end
endmodule : calcBiggestShipHit_tb
