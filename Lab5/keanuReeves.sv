module NeoPixels
    (input logic [11:0] pattern, guess, feedback,
     input logic [3:0] loaded_i,
     input logic [2:0] status,
     input logic clock, reset,
     output logic done_displaying);

     logic sel1, sel2, sel3, sel4;
     logic en_ct, ld_px;
     logic ld_color, cl_color;
     logic load, go, ready;
     logic allValid, endBottom, endTop;

     logic [2:0] pixel;
     fsm_final control(.*);

     logic [11:0] loaded_white;
     loadedToWhite cnvrt1(.*);

     logic [7:0] red, green, blue;
     RGB cnvrt2(.*);

     logic [11:0] tmp, w2, w3, w4, w8;
     logic [2:0] rgb, w5, w6, w7;


    Mux2to1 #(12) mux1(.I0(w4), .I1(w3), .S(sel1), .Y(w2)),
                  mux2(.I0(guess), .I1(feedback), .S(sel2), .Y(w3)),
                  mux3(.I0(pattern), .I1(loaded_white), .S(sel3), .Y(w4));

    Mux2to1 #(3)  mux4(.I0(w6), .I1(w7), .S(pixel[1]), .Y(rgb)),
                  mux5(.I0(tmp[2:0]), .I1(tmp[5:3]), .S(pixel[0]), .Y(w6)),
                  mux6(.I0(tmp[8:6]), .I1(tmp[11:9]), .S(pixel[0]), .Y(w7));

    Register #(12) reg1(.en(ld_color), .D(w2), .Q(tmp), .clock, .clear(cl_color));

endmodule : NeoPixels

module fsm
    (input logic [2:0] status,
     input logic ready, allValid, endTop, endBottom,
     output logic sel1, sel2, sel3, sel4,
     output logic en_ct, ld_px, ld_color, cl_color, load, go,
     output logic done_displaying,
     input logic clock, reset);

    enum {waitState, A, B, C, D} cs, ns;

    always_comb begin
        case(cs)
            waitState: begin
                case(status)
                    3'b000: ns= A;
                    3'b001: ns= B;
                    3'b010: ns= B;
                    3'b011: ns= B;
                endcase
            end
            A: ns= endBottom ? C : A;
            B: ns= endTop ? A : B;
            C: ns= ready ? waitState : C;
        endcase
    end

    always_comb begin
        {sel1, sel2, sel3, sel4}= 4'b0000;
        load=0; go=0;
        cl_color= 0; ld_color=0;
        done_displaying=0;
        case(cs)
            waitState: begin
                case(status)
                    3'b000: {sel4, ld_px, ld_color, load}= 4'b1111;
                    3'b001: {ld_px, cl_color, load}= 4'b1111;
                    3'b010: {sel3, ld_color, ld_px, load}= 4'b1111;
                    3'b011: {sel1, sel2, ld_color, ld_px, load}= 5'b1_1111;
                endcase
            end
            A: {en_ct, load, go, done_displaying}= endBottom ? 4'b0010 : 4'b1100;
            B: begin
                if(endTop) begin
                    case(status)
                        3'b001: {sel4, cl_color, ld_px, load}= 4'b1111;
                        3'b010: {sel4, ld_color, ld_px, load}= 4'b1111;
                        3'b011: {sel1, sel4, ld_color, ld_px, load}= 5'b1_1111;
                    endcase
                end
                else
                    {en_ct, load}= 2'b11;
            end
            C: done_displaying= ready ? 1 : 0;
        endcase
    end

    always_ff @ (posedge clock, posedge reset)
        if(reset)
            cs <= waitState;
        else
            cs <= ns;
endmodule : fsm

module fsm_final
    (input logic ready, clock, reset,
     output logic load, go, sel1, sel2, sel3, ld_color, cl_color,
     output logic [2:0] pixel,
     output logic done_displaying);

    enum {waitState, px0, px1, px2, px3, px4, px5, px6, px7, display} cs, ns;

    always_comb begin
        case(cs)
            waitState: ns= px0;
            px0: ns= px1;
            px1: ns= px2;
            px2: ns= px3;
            px3: ns= px4;
            px4: ns= px5;
            px5: ns= px6;
            px6: ns= px7;
            px7: ns= display;
            display: ns= waitState;
        endcase
    end

    always_comb begin
        {sel1, sel2, sel3}= 3'b000;
        load=1; go=0;
        cl_color= 0; ld_color=0;
        done_displaying=0;
        case(cs)
            waitState: begin {ld_color, load}= 2'b00; pixel=0; end
            px0: pixel=3'd1;
            px1: pixel=3'd1;
            px2: pixel=3'd1;
            px3: pixel=3'd1;
            px4: pixel=3'd1;
            px5: pixel=3'd1;
            px6: pixel=3'd1;
            px7: go=1 load=0;
            display: done_displaying= ready ? 1 : 0;
        endcase
    end

    always_ff @ (posedge clock, posedge reset)
        if(reset)
            cs <= waitState;
        else
            cs <= ns;
endmodule : fsm_final

module loadedToWhite
    (input logic [3:0] loaded_i,
     output logic [11:0] loaded_white);

    always_comb begin
        case(loaded_i)
            4'b0000: loaded_white= 12'o7777;
            4'b0001: loaded_white= 12'o7770;
            4'b0010: loaded_white= 12'o7707;
            4'b0011: loaded_white= 12'o7700;
            4'b0100: loaded_white= 12'o7077;
            4'b0101: loaded_white= 12'o7070;
            4'b0110: loaded_white= 12'o7007;
            4'b0111: loaded_white= 12'o7000;
            4'b1000: loaded_white= 12'o0777;
            4'b1001: loaded_white= 12'o0770;
            4'b1010: loaded_white= 12'o0707;
            4'b1011: loaded_white= 12'o0700;
            4'b1100: loaded_white= 12'o0077;
            4'b1101: loaded_white= 12'o0070;
            4'b1110: loaded_white= 12'o0007;
            4'b1111: loaded_white= 12'o0000;
        endcase
    end
endmodule : loadedToWhite
module RGB
    (input logic [2:0] rgb,
     output logic [7:0] red, green, blue);

    always_comb begin
        case(rgb)
           3'b000: begin red= 8'd32; green= 8'd32; blue= 8'd32; end
           3'b001: begin red= 8'd0; green= 8'd32; blue= 8'd0; end
           3'b010: begin red= 8'd32; green= 8'd32; blue= 8'd0; end
           3'b011: begin red= 8'd32; green= 8'd0; blue= 8'd0; end
           3'b100: begin red= 8'd0; green= 8'd0; blue= 8'd32; end
           default: begin red= 8'd0; green= 8'd0; blue= 8'd0; end
        endcase
    end
endmodule : RGB
