module calcNumHitsBig
    (input logic [3:0] X, Y,
    output logic F);

    logic [8:0] out;
    CalcHitNormal S0(.X(X - 4'd1), .Y(Y + 4'd1), .HitNormal(out[0]));
    CalcHitNormal S1(.X(X), .Y(Y + 4'd1), .HitNormal(out[1]));
    CalcHitNormal S2(.X(X + 4'd1), .Y(Y + 4'd1), .HitNormal(out[2]));

    CalcHitNormal S3(.X(X - 4'd1), .Y(Y), .HitNormal(out[3]));
    CalcHitNormal S4(.X(X), .Y(Y), .HitNormal(out[4]));
    CalcHitNormal S5(.X(X + 4'd1), .Y(Y), .HitNormal(out[5]));

    CalcHitNormal S6(.X(X - 4'd1), .Y(Y - 4'd1), .HitNormal(out[6]));
    CalcHitNormal S7(.X(X), .Y(Y - 4'd1), .HitNormal(out[7]));
    CalcHitNormal S8(.X(X + 4'd1), .Y(Y - 4'd1), .HitNormal(out[8]));

    assign F= out[0] + out[1] + out[2] + out[3] + out[4] +
              out[5] + out[6] + out[7] + out[8];

endmodule : calcNumHitsBig

module calcNumHits
    (input logic [3:0] X, Y,
     input logic Hit, Big,
     output logic NumHits);

    logic F;
    calcNumHitsBig NumHitsBig(.*);

    always_comb begin
        if(Hit)
            begin
            if(Big)
                NumHits= F;
            else
                NumHits= 1;
            end
        else
            NumHits= 0;

    end
endmodule : calcNumHits

module calcBiggestShipHitNormal
    (input logic [3:0] X, Y,
     output logic F);

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
            8'b0010_0100: F = 5'b1_0000;
            8'b0010_0101: F = 5'b1_0000;
            8'b0010_0110: F = 5'b1_0000;

            default : F= 5'd0;
        endcase
    end


endmodule : calcBiggestShipHitNormal

module calcBiggestShipHit
    (input logic [3:0] X, Y,
     input logic Big, Hit, ScoreThis
     output logic [4:0] BiggestShipHit);

    logic [4:0] out0, out1, out2, out3, out4, out5, out5, out7, out8;

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
    aggreg= out0 | out1 | out2 | out3 | out4 | out5 | out6 | out7 | out8;

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
